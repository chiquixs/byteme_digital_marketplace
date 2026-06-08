import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class ProductController extends ChangeNotifier {
  List<Map<String, dynamic>> _products = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Map<String, dynamic>> get products => List.unmodifiable(_products);
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Map<String, dynamic> _mapProduct(Map<String, dynamic> raw) {
    return {
      'id'         : raw['produk_id'] ?? '',
      'title'      : raw['nama_produk'] ?? '',
      'price'      : _formatPrice(raw['harga']),
      'harga'      : raw['harga'] ?? 0,
      'description': raw['deskripsi'] ?? '',
      'image'      : raw['file_path'] ?? '',
      'category'   : _extractCategory(raw),
      'status'     : raw['status'] ?? 'pending',
      'sales'      : '${raw['total_terjual'] ?? 0} sales',
      'rating'     : (raw['rating'] as num?)?.toDouble() ?? 0.0,
      'access_url' : raw['access_url'] ?? '',
    };
  }

  String _formatPrice(dynamic harga) {
    if (harga == null) return 'Rp 0';
    if (harga is String && harga.startsWith('Rp')) return harga;
    final number = (harga is num
            ? harga
            : num.tryParse(harga.toString()) ?? 0)
        .toInt();
    final formatted = number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'Rp $formatted';
  }

  String _extractCategory(Map<String, dynamic> raw) {
    try {
      final cats = raw['categories'] as List?;
      if (cats != null && cats.isNotEmpty) {
        return cats.first['nama_kategori'] ?? '';
      }
    } catch (_) {}
    return '';
  }

  // ✅ Fetch hanya produk milik seller yang sedang login
  Future<void> fetchMyProducts() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      final response = await ApiService.get('/my-produk');
      debugPrint('fetchMyProducts [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List raw = decoded is List
            ? decoded
            : (decoded['data'] ?? decoded['products'] ?? []);
        _products = raw
            .map((p) => _mapProduct(Map<String, dynamic>.from(p)))
            .toList();
      } else {
        _products = [];
        _errorMessage = 'Gagal memuat produk (${response.statusCode})';
      }
    } catch (e) {
      _products = [];
      _errorMessage = e.toString();
      debugPrint('Error fetchMyProducts: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    try {
      final response = await ApiService.delete('/produk/$id');
      debugPrint('deleteProduct [${response.statusCode}]: ${response.body}');
      if (response.statusCode == 200) {
        _products.removeWhere((p) => p['id'] == id);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error deleteProduct: $e');
    }
  }

  void addProduct(Map<String, dynamic> product) {
    _products.add(_mapProduct(product));
    notifyListeners();
  }

  void updateProduct(String id, Map<String, dynamic> updatedData) {
    final index = _products.indexWhere((p) => p['id'] == id);
    if (index == -1) return;
    _products[index] = {
      ..._products[index],
      ..._mapProduct(updatedData),
    };
    notifyListeners();
  }
}