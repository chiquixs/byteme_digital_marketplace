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
    return OrderItem(
      id: json['id'] ?? 0,
      storeName: json['store_name'] ?? '',
      productName: json['product_name'] ?? '',
      reviewText: json['review_text'],
      rating: json['rating'],
      imagePath: json['image_path'] ?? '',
      quantity: json['quantity'] ?? 1,
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