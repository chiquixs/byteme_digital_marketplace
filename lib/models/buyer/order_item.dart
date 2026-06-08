import 'package:flutter/material.dart';

class OrderItem {
  final int id; 
  final String storeName;
  final String productName;
  final String? reviewText;   
  final int? rating;           
  final String imagePath;
  final int quantity;

  const OrderItem({
    required this.id,
    required this.storeName,
    required this.productName,
    this.reviewText,
    this.rating,
    this.imagePath = '',
    this.quantity = 1,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    // 💡 LOGIKA SAPU JAGAT: Deteksi penamaan ID pesanan/detail dari database Angga
    final dynamic rawId = json['id'] ?? json['pesanan_id'] ?? json['detail_id'] ?? 0;
    
    // 💡 LOGIKA SAPU JAGAT: Deteksi penamaan rating/bintang dari database Angga
    final dynamic rawRating = json['rating'] ?? json['bintang'] ?? json['skor'];

    return OrderItem(
      id: rawId is num ? rawId.toInt() : (int.tryParse(rawId.toString()) ?? 0),
      
      storeName: json['store_name'] ?? json['nama_toko'] ?? json['username_seller'] ?? json['username'] ?? '',
      
      // Deteksi nama produk versi database Angga (nama_produk)
      productName: json['product_name'] ?? json['nama_produk'] ?? '',
      
      reviewText: json['review_text'] ?? json['ulasan'] ?? json['deskripsi_review'],
      
      rating: rawRating is num ? rawRating.toInt() : (int.tryParse(rawRating.toString())),
      
      // Deteksi alamat path file gambar produk dari database Angga (file_path atau image)
      imagePath: json['image_path'] ?? json['file_path'] ?? json['image'] ?? '',
      
      quantity: json['quantity'] ?? json['qty'] ?? json['qty_terjual'] ?? 1,
    );
  }

  OrderItem copyWith({
    int? rating,
    String? reviewText,
  }) {
    return OrderItem(
      id: id,
      storeName: storeName,
      productName: productName,
      rating: rating ?? this.rating,
      reviewText: reviewText ?? this.reviewText,
      imagePath: imagePath,
      quantity: quantity,
    );
  }
}