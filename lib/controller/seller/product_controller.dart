// ============================================================
// PRODUCT CONTROLLER
// Letakkan file ini di: lib/controller/seller/product_controller.dart
//
// Meniru pola UserController di lib/controller/user_controller.dart:
// - extends ChangeNotifier
// - data disimpan di private field
// - diakses lewat getter
// - diubah lewat method yang memanggil notifyListeners()
// ============================================================

import 'package:flutter/material.dart';

class ProductController extends ChangeNotifier {
  // ── DATA PRODUK SELLER ────────────────────────────────────
  // Disimpan di sini (bukan di State widget) agar tidak reset
  // saat berpindah halaman — meniru pola _pendingOrders di UserController
  // TODO(backend): Ganti dengan data dari API / database
  final List<Map<String, dynamic>> _products = [
    {
      'title': 'Mobile App UI Kit',
      'price': '\$29',
      'sales': '13k sales',
      'rating': 4.8,
      'status': 'active',
      'image': 'assets/images/ebook1.png',
    },
    {
      'title': 'Lightroom Presets Bundle',
      'price': '\$15',
      'sales': '900 sales',
      'rating': 4.7,
      'status': 'active',
      'image': 'assets/images/e-book.jpeg',
    },
    {
      'title': 'Dashboard UI Kit',
      'price': '\$19',
      'sales': '601 sales',
      'rating': 4.6,
      'status': 'active',
      'image': 'assets/images/ebook1.png',
    },
    {
      'title': 'Icon Pack - Minimal',
      'price': '\$9',
      'sales': '435 sales',
      'rating': 4.5,
      'status': 'inactive',
      'image': 'assets/images/e-book.jpeg',
    },
  ];

  // ── GETTER ───────────────────────────────────────────────
  // Meniru pola getter di UserController (misal: get pendingOrders)
  // Kembalikan salinan list agar tidak bisa diubah dari luar langsung
  List<Map<String, dynamic>> get products => List.unmodifiable(_products);

  // ── TOGGLE STATUS (Active <-> Inactive) ──────────────────
  // Meniru pola method di UserController yang memanggil notifyListeners()
  void toggleStatus(String title) {
    final index = _products.indexWhere((p) => p['title'] == title);
    if (index == -1) return;

    _products[index] = {
      ..._products[index],
      'status': _products[index]['status'] == 'active' ? 'inactive' : 'active',
    };

    notifyListeners(); // beritahu semua widget yang listen agar rebuild
  }

  // ── HAPUS PRODUK ─────────────────────────────────────────
  void deleteProduct(String title) {
    _products.removeWhere((p) => p['title'] == title);
    notifyListeners();
  }

  // ── TAMBAH PRODUK ────────────────────────────────────────
  // TODO: Dipakai nanti saat halaman Add Product dibuat
  void addProduct(Map<String, dynamic> product) {
    _products.add(product);
    notifyListeners();
  }

  // ── UPDATE PRODUK ────────────────────────────────────────
  // TODO: Dipakai nanti saat halaman Edit Product dibuat
  void updateProduct(String title, Map<String, dynamic> updatedData) {
    final index = _products.indexWhere((p) => p['title'] == title);
    if (index == -1) return;

    _products[index] = {
      ..._products[index],
      ...updatedData,
    };

    notifyListeners();
  }
}