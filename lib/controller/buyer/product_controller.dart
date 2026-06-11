// ============================================================
// BUYER PRODUCT CONTROLLER - Robust & Live Data Version
// Letakkan file ini di: lib/controller/buyer/product_controller.dart
// ============================================================

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

  // 🌟 MAPPER DATA YANG AMAN (Handles String, Num, Null) 🌟
  Map<String, dynamic> _mapProduct(Map<String, dynamic> raw) {
    return {
      'id': raw['produk_id'] ?? raw['id'] ?? '',
      'nama_produk': raw['nama_produk'] ?? raw['title'] ?? '',
      'title': raw['nama_produk'] ?? raw['title'] ?? '',
      'harga': raw['harga'] ?? raw['price'] ?? 0,          // ← TAMBAH raw harga
      'price': _formatPrice(raw['harga'] ?? raw['price']),
      'priceLabel': _formatPrice(raw['harga'] ?? raw['price']),
      'deskripsi': raw['deskripsi'] ?? raw['description'] ?? '',
      'image': raw['file_path'] ?? raw['image'] ?? '',
      'category': _extractCategory(raw),                    // tetap ada (fallback)
      'categories': raw['categories'] ?? [],                // ← TAMBAH raw list ini

      'rating': double.tryParse(
        (raw['reviews_avg_rating']?.toString() ?? 
        raw['rating']?.toString() ?? '0.0')) ?? 0.0,

      'reviews': int.tryParse(
        (raw['reviews_count']?.toString() ?? 
        raw['reviews']?.toString() ?? '0')) ?? 0,

      'reviews_avg_rating': raw['reviews_avg_rating'],      // ← TAMBAH untuk explore_page
      'reviews_count': raw['reviews_count'],                // ← TAMBAH untuk explore_page
      'status': raw['status'] ?? '',
    };
  }

  String _formatPrice(dynamic harga) {
    if (harga == null) return 'Rp 0';
    if (harga is String && harga.startsWith('Rp')) return harga;
    final number = (harga is num ? harga : num.tryParse(harga.toString()) ?? 0).toInt();
    return 'Rp ${number.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.')}';
  }

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
      final response = await ApiService.get('/produk');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List raw = decoded is List ? decoded : (decoded['data'] ?? decoded['products'] ?? []);
        
        _products = raw.map((p) => _mapProduct(Map<String, dynamic>.from(p))).toList();
      } else {
        _products = [];
      }
    } catch (e) {
      debugPrint('Error fetchProducts: $e');
      _products = [];
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> fetchBanners() async {
    // Placeholder untuk banners
    _banners = [];
    notifyListeners();
  }

  Future<void> fetchMostPurchased() async {
    // Mengambil dari _products yang sudah ter-mapping dengan benar
    _mostPurchased = List<Map<String, dynamic>>.from(_products);
    // Contoh filter: kamu bisa tambah logika sorting di sini jika perlu
    notifyListeners();
  }

  Future<void> fetchMostSearched() async {
    // Mengambil dari _products yang sudah ter-mapping dengan benar
    _mostSearched = List<Map<String, dynamic>>.from(_products);
    notifyListeners();
  }

  // Menjamin semua data siap sebelum UI merender
  Future<void> fetchAllData() async {
    await fetchProducts();
    await fetchBanners();
    await fetchMostPurchased();
    await fetchMostSearched();
  }
}