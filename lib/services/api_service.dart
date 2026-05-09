import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Ganti dengan IP lokal kamu saat development
  // Jika pakai emulator Android: http://10.0.2.2:8000/api
  // Jika pakai device fisik: http://IP_LAPTOP_KAMU:8000/api
 static const String baseUrl = 'http://192.168.50.230:8000/api';

  // ── Simpan token ke local storage
  static Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // ── Ambil token dari local storage
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // ── Hapus token (logout)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
    await prefs.remove('user_role');
  }

  // ── Simpan role user
  static Future<void> saveRole(String role) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('user_role', role);
  }

  // ── Header dengan token
  static Future<Map<String, String>> _authHeaders() async {
    final token = await getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // ── POST tanpa auth
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

  // ── POST dengan auth token
  static Future<http.Response> postAuth(
    String endpoint,
    Map<String, dynamic> body,
  ) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _authHeaders();
    return await http.post(uri, headers: headers, body: jsonEncode(body));
  }

  // ── GET dengan auth token
  static Future<http.Response> get(String endpoint) async {
    final uri = Uri.parse('$baseUrl$endpoint');
    final headers = await _authHeaders();
    return await http.get(uri, headers: headers);
  }

  // POST multipart (for file uploads like products)
static Future<http.Response> postMultipart(
  String endpoint,
  Map<String, String> fields,
  {Map<String, String>? filePaths}
  ) async {
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
        request.files.add(await http.MultipartFile.fromPath(entry.key, entry.value));
      }
    }
    final streamed = await request.send();
    return await http.Response.fromStream(streamed);
  }
}