import 'dart:convert';
import 'package:byteme_digital_marketplace/services/api_service.dart';

class CheckoutResult {
  final bool success;
  final String message;
  final String? pesananId;
  final String? snapToken;
  final String? redirectUrl;

  CheckoutResult({
    required this.success,
    required this.message,
    this.pesananId,
    this.snapToken,
    this.redirectUrl,
  });
}

class CheckoutService {
  /// Submits selected cart item IDs to the backend and returns
  /// a Midtrans redirect URL to open in the browser.
  static Future<CheckoutResult> checkout({
    required List<String> detailKeranjangIds,
  }) async {
    if (detailKeranjangIds.isEmpty) {
      return CheckoutResult(success: false, message: 'Tidak ada item yang dipilih');
    }

    try {
      final body = <String, dynamic>{
        'detail_keranjang_ids': detailKeranjangIds,
      };

      final response = await ApiService.postAuth('/checkout', body);
      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return CheckoutResult(
          success: true,
          message: data['message'] ?? 'Checkout berhasil',
          pesananId: data['pesanan_id'],
          snapToken: data['snap_token'],
          redirectUrl: data['redirect_url'],
        );
      }

      return CheckoutResult(
        success: false,
        message: data['message'] ?? 'Checkout gagal',
      );
    } catch (e) {
      return CheckoutResult(
        success: false,
        message: 'Tidak dapat terhubung ke server.',
      );
    }
  }
}