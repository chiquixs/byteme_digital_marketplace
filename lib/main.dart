import 'package:flutter/material.dart';
// 1. Ubah import ini agar memanggil file home_page.dart
import 'package:byteme_digital_marketplace/views/home/home_page.dart'; 

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteMe Digital Marketplace',
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF5A72C6)),
      ),
      // 2. Arahkan kembali ke HomePage agar Bottom Navigation-nya aktif
      home: const HomePage(), 
    );
  }
}
