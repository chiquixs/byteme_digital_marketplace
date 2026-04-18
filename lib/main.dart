import 'package:flutter/material.dart';
import 'views/profile/profile_page.dart'; // ← import ProfilePage

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ByteMe',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3D4270)),
      ),
      home: const ProfilePage(), // ← langsung tampilkan ProfilePage
    );
  }
}