import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProductController extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  List<Map<String, dynamic>> _banners = [];
  List<Map<String, dynamic>> _mostPurchased = [];
  List<Map<String, dynamic>> _mostSearched = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get products => _products;
  List<Map<String, dynamic>> get banners => _banners;
  List<Map<String, dynamic>> get mostPurchased => _mostPurchased;
  List<Map<String, dynamic>> get mostSearched => _mostSearched;
  bool get isLoading => _isLoading;

  // Mapping nama kolom database → nama field yang dipakai UI
  Map<String, dynamic> _mapProduct(Map<String, dynamic> raw) {
    return {
      'id'          : raw['produk_id'] ?? raw['id'] ?? '',
      'title'       : raw['nama_produk'] ?? raw['title'] ?? '',
      'price'       : _formatPrice(raw['harga'] ?? raw['price']),
      'description' : raw['deskripsi'] ?? raw['description'] ?? '',
      'image'       : raw['file_path'] ?? raw['image'] ?? '',
      'category'    : _extractCategory(raw),
      'rating'      : (raw['rating'] as num?)?.toDouble() ?? 0.0,
      'reviews'     : raw['jumlah_ulasan'] ?? raw['reviews'] ?? 0,
      'badge'       : null,
      'status'      : raw['status'] ?? '',
    };
  }

  String _formatPrice(dynamic harga) {
    if (harga == null) return 'Rp 0';
    if (harga is String && harga.startsWith('Rp')) return harga;
    final number = (harga is num ? harga : num.tryParse(harga.toString()) ?? 0).toInt();
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  // Ambil nama kategori dari relasi categories (array of objects dari Laravel)
  String _extractCategory(Map<String, dynamic> raw) {
    try {
      final cats = raw['categories'] as List?;
      if (cats != null && cats.isNotEmpty) {
        return cats.first['nama_kategori'] ?? cats.first['name'] ?? '';
      }
    } catch (_) {}
    return raw['kategori'] ?? raw['category'] ?? '';
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();
    try {
      // ✅ Endpoint yang benar: /produk (bukan /products)
      final response = await ApiService.get('/produk');
      debugPrint('fetchProducts [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        // Laravel return langsung array, bukan {products: [...]}
        final List raw = decoded is List
            ? decoded
            : (decoded['data'] ?? decoded['products'] ?? []);
        _products = raw
            .map((p) => _mapProduct(Map<String, dynamic>.from(p)))
            .toList();
      } else {
        _products = [];
      }
    } catch (e) {
      _products = [];
      debugPrint('Error fetchProducts: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBanners() async {
    // Endpoint /banners belum ada di Laravel → langsung kosong,
    // home_page.dart sudah handle dengan _fallbackBanners
    _banners = [];
    notifyListeners();
  }

  Future<void> fetchMostPurchased() async {
    // Endpoint /produk/most-purchased belum ada → fallback ke semua produk
    // Ambil 5 produk pertama sebagai "most purchased"
    _mostPurchased = _products.take(5).toList();
    notifyListeners();
  }

  Future<void> fetchMostSearched() async {
    // Endpoint /produk/most-searched belum ada → fallback ke semua produk
    // Ambil produk dari belakang sebagai "most searched"
    _mostSearched = _products.reversed.take(6).toList();
    notifyListeners();
  }

  // fetchProducts HARUS selesai dulu sebelum mostPurchased & mostSearched
  // karena keduanya fallback ke _products
  Future<void> fetchAllData() async {
    await fetchProducts();
    await Future.wait([
      fetchBanners(),
      fetchMostPurchased(),
      fetchMostSearched(),
    ]);
  }
}