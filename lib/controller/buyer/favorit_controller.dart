import 'package:flutter/material.dart';
import '../../services/favorit_service.dart';

// ============================================================
// FAVORIT CONTROLLER - Mengatur State Favorit dengan Provider
// ============================================================

class FavoritController extends ChangeNotifier {
  final FavoritService _apiService = FavoritService();

  List<Map<String, dynamic>> _items = [];
  bool _isLoading = false;

  List<Map<String, dynamic>> get items => List.unmodifiable(_items);
  bool get isLoading => _isLoading;

  // 1. Fetch seluruh item favorit dari API
  Future<void> fetchFavorit() async {
    _isLoading = true;
    notifyListeners();

    try {
      final result = await _apiService.getFavorites();
      _items = result;
    } catch (e) {
      debugPrint('Error fetchFavorit: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // 2. Cek apakah produk tertentu merupakan favorit
  bool isWishlisted(Map<String, dynamic> product) {
    final targetId = product['id']?.toString() ?? product['produk_id']?.toString() ?? '';
    return _items.any((p) => p['produk_id'] == targetId || p['id'] == targetId);
  }

  // 3. Toggle Favorit (Tambah / Hapus) secara asinkron dengan Optimistic UI Update
  // Optimistic UI Update membuat icon hati langsung berubah demi user-experience yang responsif!
  Future<bool> toggleFavorit(Map<String, dynamic> product) async {
    final String produkId = product['id']?.toString() ?? product['produk_id']?.toString() ?? '';
    if (produkId.isEmpty) return false;

    final isCurrentlyFav = isWishlisted(product);
    final backupItems = List<Map<String, dynamic>>.from(_items);

    // [Langkah Optimis] Ubah UI lokal terlebih dahulu tanpa menunggu respon API selesai
    if (isCurrentlyFav) {
      _items.removeWhere((p) => p['id'] == produkId || p['produk_id'] == produkId);
    } else {
      // Masukkan sementara produk ke memori
      _items.add(product);
    }
    notifyListeners();

    bool success = false;
    if (isCurrentlyFav) {
      // Panggil API Hapus
      success = await _apiService.deleteFromFavorite(produkId);
    } else {
      // Panggil API Tambah
      success = await _apiService.addToFavorite(produkId);
    }

    // Jika API gagal, kembalikan state lokal ke versi backup
    if (!success) {
      _items = backupItems;
      notifyListeners();
      return false;
    }

    // Refresh data asli dari database agar state tetap presisi & aman
    await fetchFavorit();
    return true;
  }
}