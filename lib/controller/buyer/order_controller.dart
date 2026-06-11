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

  Future<void> fetchCurrentOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/pesanan');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List rawData = decoded is List ? decoded : (decoded['orders'] ?? decoded['data'] ?? []);
        final List<OrderItem> allOrders = rawData.map((item) => OrderItem.fromJson(item)).toList();
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

  Future<void> fetchHistoryOrders() async {
    _isLoading = true;
    notifyListeners();
    try {
      final response = await ApiService.get('/history/pembelian');
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List rawData = decoded is List ? decoded : (decoded['orders'] ?? decoded['data'] ?? []);
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

  /// Submit rating — update lokal langsung, TIDAK trigger refresh dari API.
  /// Data lokal sudah benar; biarkan user pull-to-refresh manual jika mau sync.
  Future<bool> submitRating(String productId, int rating, String review, int orderId) async {
    try {
      final response = await ApiService.postAuth('/review', {
        'produk_id': productId,
        'rating': rating,
        'komentar': review,
      });

      debugPrint('Hasil Post Review [${response.statusCode}]: ${response.body}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        // Cari berdasarkan orderId (id transaksi) ATAU productId sebagai fallback
        int index = _historyOrders.indexWhere((o) => o.id == orderId);
        if (index == -1) {
          index = _historyOrders.indexWhere((o) => o.productId == productId);
        }

        if (index != -1) {
          _historyOrders[index] = _historyOrders[index].copyWith(
            rating: rating,
            reviewText: review.isNotEmpty ? review : null,
          );
          notifyListeners();
        }
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error submit ulasan: $e');
      return false;
    }
  }

  Future<void> checkout(List<Map<String, dynamic>> items) async {
    try {
      final response = await ApiService.postAuth('/orders/checkout', {
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