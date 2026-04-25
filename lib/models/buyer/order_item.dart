import 'package:flutter/material.dart';

class OrderItem {
  final int id; 
  final String storeName;
  final String productName;
  final String? reviewText;   
  final int rating;           
  final String imagePath;     

  const OrderItem({
    required this.id,
    required this.storeName,
    required this.productName,
    this.reviewText,
    required this.rating,
    this.imagePath = '',
  });

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
    );
  }
}