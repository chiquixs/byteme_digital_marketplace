import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';

class KeranjangController extends ChangeNotifier {
  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;
  int get totalItems => _items.length;

  bool isInCart(String productId) {
    return _items.any((item) => item['produk_id'] == productId);
  }

  // Fetch keranjang dari API
  Future<void> fetchKeranjang() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/keranjang');
      debugPrint('fetchKeranjang [${response.statusCode}]: ${response.body}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Laravel return struktur: {keranjang_id, items: [{detail_keranjang_id, produk, ...}]}
        final List rawItems = data['items'] ?? data['detail'] ?? data ?? [];
        _items = rawItems.map((item) => _mapItem(item)).toList();
      } else {
        _items = [];
      }
    } catch (e) {
      _items = [];
      debugPrint('Error fetchKeranjang: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // Tambah produk ke keranjang via API
  Future<bool> addToCart(Map<String, dynamic> product) async {
    final produkId = product['id']?.toString() ?? '';
    if (produkId.isEmpty) return false;
    if (isInCart(produkId)) return false;

    try {
      final response = await ApiService.postAuth('/keranjang', {
        'produk_id': produkId,
        'jumlah': 1,
      });
      debugPrint('addToCart [${response.statusCode}]: ${response.body}');
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchKeranjang(); // refresh dari API
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error addToCart: $e');
      return false;
    }
  }

  // Hapus item dari keranjang via API
  Future<void> removeFromCart(String detailKeranjangId) async {
  try {
    await ApiService.delete('/keranjang/$detailKeranjangId');
    _items.removeWhere((item) => item['detail_keranjang_id'] == detailKeranjangId);
    notifyListeners();
  } catch (e) {
    debugPrint('Error removeFromCart: $e');
  }
}

  // Mapping response API ke format yang dipakai UI
  Map<String, dynamic> _mapItem(Map<String, dynamic> raw) {
    final produk = raw['produk'] ?? {};
    return {
      'detail_keranjang_id': raw['detail_keranjang_id'] ?? '',
      'produk_id'          : raw['produk_id'] ?? produk['produk_id'] ?? '',
      'name'               : produk['nama_produk'] ?? raw['nama_produk'] ?? '',
      'price'              : _formatPrice(produk['harga'] ?? raw['harga_satuan']),
      'harga'              : produk['harga'] ?? raw['harga_satuan'] ?? 0,
      'image'              : produk['file_path'] ?? '',
      'category'           : _extractCategory(produk),
      'store'              : produk['seller']?['username'] ?? 'Official Store',
      'qty'                : raw['jumlah'] ?? 1,
      'selected'           : false,
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

  String _extractCategory(Map<String, dynamic> produk) {
    try {
      final cats = produk['categories'] as List?;
      if (cats != null && cats.isNotEmpty) {
        return cats.first['nama_kategori'] ?? '';
      }
    } catch (_) {}
    return '';
  }
}