import 'dart:convert';
import 'package:flutter/material.dart';
import '../../services/api_service.dart';
import '../../models/buyer/order_item.dart';

class OrderController extends ChangeNotifier {
  List<OrderItem> _currentOrders = [];
  List<OrderItem> _historyOrders = [];
  bool _isLoading = false;

  List<OrderItem> get currentOrders => _currentOrders;
  List<OrderItem> get historyOrders => _historyOrders;
  bool get isLoading => _isLoading;

  // ── 1. AMBIL PESANAN AKTIF (Dibatasi Cuma Muncul Maksimal 2) ──
  Future<void> fetchCurrentOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/pesanan');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        final List rawData = decoded is List 
            ? decoded 
            : (decoded['orders'] ?? decoded['data'] ?? []);

        // Memetakan data dari Angga ke Model
        final List<OrderItem> allOrders = rawData.map((item) => OrderItem.fromJson(item)).toList();
        
        // ✅ KUNCI SAKTI: Cuma ambil maksimal 2 data teratas untuk pesanan aktif
        _currentOrders = allOrders.take(2).toList();
      } else {
        _currentOrders = [];
      }
    } catch (e) {
      _currentOrders = [];
      debugPrint('Error fetching current orders: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── 2. AMBIL RIWAYAT PEMBELIAN (Tetap Muncul Semua) ──
  Future<void> fetchHistoryOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/history/pembelian');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        
        final List rawData = decoded is List 
            ? decoded 
            : (decoded['orders'] ?? decoded['data'] ?? []);

        _historyOrders = rawData.map((item) => OrderItem.fromJson(item)).toList();
      } else {
        _historyOrders = [];
      }
    } catch (e) {
      _historyOrders = [];
      debugPrint('Error fetching history orders: $e');
    }
    _isLoading = false;
    notifyListeners();
  }

  // ── 3. SUBMIT RATING BARU ──
  Future<void> submitRating(int orderId, int rating, String review) async {
    try {
      final response = await ApiService.postAuth('/review', {
        'order_id': orderId, 
        'rating': rating,
        'review': review,
      });
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final index = _historyOrders.indexWhere((o) => o.id == orderId);
        if (index != -1) {
          _historyOrders[index] = _historyOrders[index].copyWith(rating: rating, reviewText: review);
          notifyListeners();
        }
      }
    } catch (e) {
      debugPrint('Error submitting rating: $e');
    }
  }

  // ── 4. CHECKOUT ──
  Future<void> checkout(List<Map<String, dynamic>> items) async {
    try {
      final response = await ApiService.postAuth('/checkout', {
        'items': items,
      });
      if (response.statusCode == 200 || response.statusCode == 201) {
        await fetchCurrentOrders();
      }
    } catch (e) {
      debugPrint('Error during checkout: $e');
    }
  }
}