import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/controller/buyer/order_controller.dart';
import 'package:byteme_digital_marketplace/controller/buyer/product_controller.dart' as buyerProduct;
import 'package:byteme_digital_marketplace/controller/seller/product_controller.dart' as sellerProduct;
import 'package:byteme_digital_marketplace/views/auth/login_page.dart';
import 'package:byteme_digital_marketplace/controller/buyer/cart_controller.dart';

void main() {
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => buyerProduct.ProductController()),
        ChangeNotifierProvider(create: (_) => sellerProduct.ProductController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => KeranjangController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteMe Digital Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF5A72C6),
        ),
      ),
      home: const LoginPage(),
    );
  }
}