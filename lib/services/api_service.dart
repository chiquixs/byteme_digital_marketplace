import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl =
      'https://backend-laravel-byteme-production.up.railway.app/api';

  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
  }

  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // POST tanpa auth
  static Future<http.Response> post(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    return await http.post(
      uri,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(body),
    );
  }

  // POST dengan auth token (JSON)
  static Future<http.Response> postAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _authHeaders();
    return await http.post(uri, headers: headers, body: jsonEncode(body));
  }

  // GET dengan auth token
  static Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _authHeaders();
    return await http.get(uri, headers: headers);
  }

  // POST multipart (untuk upload produk)
  static Future<http.Response> postMultipart(
    String endpoint,
    Map<String, String> fields, {
    Map<String, String>? filePaths,
  }) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final token = await getToken();
    final request = http.MultipartRequest('POST', uri);
    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });
    request.fields.addAll(fields);
    if (filePaths != null) {
      for (final entry in filePaths.entries) {
        request.files
            .add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }
    }
    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }

  // ─────────────────────────────────────────────────────────────────────────
  // UPDATE PROFILE — selalu gunakan multipart/form-data (POST)
  // Mengapa selalu multipart? Karena Laravel route sudah di-set POST dan
  // http.MultipartRequest tidak bisa PATCH. Tanpa foto pun tetap multipart
  // agar method dan Content-Type konsisten, menghindari "route not found".
  // ─────────────────────────────────────────────────────────────────────────
  static Future<http.Response> updateProfileMultipart(
    Map<String, String> fields, {
    String? imagePath,
  }) async {
    const endpoint = '/auth/update';
    final uri = Uri.parse('$baseUrl$endpoint');
    final token = await getToken();

    final request = http.MultipartRequest('POST', uri);

    request.headers.addAll({
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    });

    // Kirim semua field teks
    request.fields.addAll(fields);

    // Tambahkan file foto hanya jika ada
    if (imagePath != null) {
      request.files.add(
        await http.MultipartFile.fromPath('profile_image', imagePath),
      );
    }

    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }

  // DELETE dengan auth token
  static Future<http.Response> delete(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _authHeaders();
    return await http.delete(uri, headers: headers);
  }
}
