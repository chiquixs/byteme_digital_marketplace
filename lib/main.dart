import 'package:flutter/material.dart';
import 'views/home/home_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Digital Marketplace',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF6B7FD7),
        // Kamu bisa memindahkan setting font/warna di sini nanti
      ),
      home: const HomePage(), // Menjalankan halaman utama
    );
  }
}