import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

// ============================================================
// FAVORIT SERVICE - Penghubung ke API Laravel/Supabase
// ============================================================

class FavoritService {
  // TODO: Sesuaikan dengan URL Base API kamu!
  // - Jika pakai Emulator Android bawaan, ganti ke: 'http://10.0.2.2:8000/api'
  // - Jika pakai HP Fisik/iOS Simulator, gunakan IP lokal laptopmu, misal: 'http://192.168.1.xx:8000/api'
  final String _baseUrl = 'https://backend-laravel-byteme-production.up.railway.app/api';

  // Helper untuk mengambil token auth Sanctum yang disimpan saat login
  // Kita buat super aman dengan memeriksa beberapa key SharedPreferences yang paling umum!
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Scan satu per satu key yang mungkin dipakai oleh AuthController / UserController kamu
    final token = prefs.getString('token') ?? 
                  prefs.getString('auth_token') ?? 
                  prefs.getString('access_token');
                  
    if (token != null) {
      return token;
    }

    // Fallback cadangan: Jika ternyata data user disimpan dalam bentuk JSON String utuh di local storage
    try {
      final userString = prefs.getString('user') ?? prefs.getString('user_data');
      if (userString != null) {
        final Map<String, dynamic> userMap = json.decode(userString);
        if (userMap.containsKey('token')) return userMap['token']?.toString();
        if (userMap.containsKey('access_token')) return userMap['access_token']?.toString();
      }
    } catch (e) {
      debugPrint('Gagal parsing fallback token dari object user: $e');
    }

    return null;
  }

  // Header wajib untuk Sanctum & JSON API
  Future<Map<String, String>> _getHeaders() async {
    final token = await _getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 1. Ambil daftar favorit buyer (GET /favorit)
  // Berdasarkan Laravel FavoritController::index
  Future<List<Map<String, dynamic>>> getFavorites() async {
    final url = Uri.parse('$_baseUrl/favorit');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        final List<dynamic> rawList = body['data'] ?? [];
        
        // Memetakan struktur data Laravel 'produk' ke format yang dikenali UI Flutter kita
        return rawList.map<Map<String, dynamic>>((item) {
          final produk = item['produk'] ?? {};
          return {
            'favorit_id': item['favorit_id']?.toString(),
            'id': produk['produk_id']?.toString(),
            'produk_id': produk['produk_id']?.toString(),
            'title': produk['nama_produk'] ?? '',
            'nama_produk': produk['nama_produk'] ?? '',
            'price': produk['harga'] ?? 0,
            'priceLabel': 'Rp ${produk['harga'] ?? 0}',
            'image': produk['file_path'] ?? 'assets/images/e-book.jpeg',
            'file_path': produk['file_path'] ?? 'assets/images/e-book.jpeg',
            'category': 'Produk ByteMe', // default fallback kategori
            'rating': 4.5, // default rating visual
            'reviews': 0,
          };
        }).toList();
      } else {
        debugPrint('Error GET /favorit: ${response.statusCode} - ${response.body}');
        throw Exception('Gagal memuat daftar favorit');
      }
    } catch (e) {
      debugPrint('Koneksi bermasalah pada GET /favorit: $e');
      rethrow;
    }
  }

  // 2. Tambah ke favorit (POST /favorit)
  // Berdasarkan Laravel FavoritController::store
  Future<bool> addToFavorite(String produkId) async {
    final url = Uri.parse('$_baseUrl/favorit');
    try {
      final headers = await _getHeaders();
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode({'produk_id': produkId}),
      );

      // Status 201 (Created), 200 (OK), atau 409 (Conflict - jika sudah difavoritkan sebelumnya)
      if (response.statusCode == 201 || response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 409) {
        debugPrint('Produk sudah ada di daftar favorit database.');
        return true; // Kita anggap sukses karena memang tujuannya ada di sana
      } else {
        debugPrint('Error POST /favorit: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Koneksi bermasalah pada POST /favorit: $e');
      return false;
    }
  }

  // 3. Hapus dari favorit (DELETE /favorit/{produkId})
  // Berdasarkan Laravel FavoritController::destroy
  Future<bool> deleteFromFavorite(String produkId) async {
    final url = Uri.parse('$_baseUrl/favorit/$produkId');
    try {
      final headers = await _getHeaders();
      final response = await http.delete(url, headers: headers);

      if (response.statusCode == 200) {
        return true;
      } else {
        debugPrint('Error DELETE /favorit: ${response.statusCode} - ${response.body}');
        return false;
      }
    } catch (e) {
      debugPrint('Koneksi bermasalah pada DELETE /favorit: $e');
      return false;
    }
  }

  // 4. Cek status ke-favorit-an produk (GET /favorit/check/{produkId})
  // Berdasarkan Laravel FavoritController::check
  Future<bool> checkIfFavorite(String produkId) async {
    final url = Uri.parse('$_baseUrl/favorit/check/$produkId');
    try {
      final headers = await _getHeaders();
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        return body['is_favorit'] ?? false;
      } else {
        debugPrint('Error GET /favorit/check: ${response.statusCode}');
        return false;
      }
    } catch (e) {
      debugPrint('Koneksi bermasalah pada GET /favorit/check: $e');
      return false;
    }
  }
}