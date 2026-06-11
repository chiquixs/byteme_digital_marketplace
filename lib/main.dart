import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:app_links/app_links.dart';

// Controller Imports
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/controller/buyer/order_controller.dart';
import 'package:byteme_digital_marketplace/controller/buyer/product_controller.dart' as buyerProduct;
import 'package:byteme_digital_marketplace/controller/seller/product_controller.dart' as sellerProduct;
import 'package:byteme_digital_marketplace/controller/buyer/cart_controller.dart';
import 'package:byteme_digital_marketplace/controller/buyer/favorit_controller.dart'; // Controller baru kita

// Views & Utils Imports
import 'package:byteme_digital_marketplace/views/auth/login_page.dart';
import 'package:byteme_digital_marketplace/utils/navigator_key.dart';
import 'package:byteme_digital_marketplace/utils/notif_helper.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserController()),
        ChangeNotifierProvider(create: (_) => buyerProduct.ProductController()),
        ChangeNotifierProvider(create: (_) => sellerProduct.ProductController()),
        ChangeNotifierProvider(create: (_) => OrderController()),
        ChangeNotifierProvider(create: (_) => KeranjangController()),
        ChangeNotifierProvider(create: (_) => FavoritController()), // 🌟 SEKARANG SUDAH DIDAFTARKAN DI SINI!
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final _appLinks = AppLinks();

  @override
  void initState() {
    super.initState();
    _initDeepLinks();
  }

  void _initDeepLinks() {
    _appLinks.uriLinkStream.listen((uri) {
      if (!mounted) return;

      final host = uri.host;
      final path = uri.path;
      final transactionStatus = uri.queryParameters['transaction_status'];

      if (host == 'payment') {
        final ctx = navigatorKey.currentContext;
        if (ctx == null) return;

        if (path == '/finish') {
          if (transactionStatus == 'capture' ||
              transactionStatus == 'settlement') {
            NotifHelper.showSuccess(
              ctx,
              '🎉 Pembayaran berhasil! Cek email untuk link akses produk.',
            );
          } else {
            NotifHelper.showWarning(
              ctx,
              'Pembayaran sedang diproses. Cek riwayat pesanan untuk statusnya.',
            );
          }
        } else if (path == '/unfinish') {
          NotifHelper.showWarning(
            ctx,
            'Pembayaran belum selesai. Selesaikan sebelum kadaluarsa.',
          );
        } else if (path == '/error') {
          NotifHelper.showError(
            ctx,
            'Pembayaran gagal. Silakan coba lagi.',
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: navigatorKey,
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