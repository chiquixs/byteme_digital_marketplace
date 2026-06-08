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
      final response = await ApiService.get('/orders/current');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _currentOrders = List<OrderItem>.from(
          (data['orders'] ?? []).map((item) => OrderItem.fromJson(item))
        );
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
      final response = await ApiService.get('/orders/history');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _historyOrders = List<OrderItem>.from(
          (data['orders'] ?? []).map((item) => OrderItem.fromJson(item))
        );
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

  Future<void> submitRating(int orderId, int rating, String review) async {
    try {
      final response = await ApiService.postAuth('/orders/rate', {
        'order_id': orderId,
        'rating': rating,
        'review': review,
      });
      if (response.statusCode == 200) {
        // Update local data
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

  Future<void> checkout(List<Map<String, dynamic>> items) async {
    try {
      final response = await ApiService.postAuth('/orders/checkout', {
        'items': items,
      });
      if (response.statusCode == 200) {
        // Refresh current orders
        await fetchCurrentOrders();
      }
    } catch (e) {
      debugPrint('Error during checkout: $e');
    }
  }
}