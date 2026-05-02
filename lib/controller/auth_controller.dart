import 'dart:convert';
import 'package:byteme_digital_marketplace/models/user_model.dart';
import 'package:byteme_digital_marketplace/services/api_service.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;

  AuthResult({
    required this.success,
    required this.message,
    this.user,
  });
}

class AuthController {
  // ── LOGIN
  static Future<AuthResult> login({
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'username': username,   // sesuaikan dengan field di Laravel
        'password': password,
        'role': role.toLowerCase(),
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // Simpan token & role
        await ApiService.saveToken(data['token']);
        await ApiService.saveRole(role);

        final user = UserModel.fromJson(data['user']);
        return AuthResult(success: true, message: 'Login berhasil', user: user);
      } else {
        final msg = data['message'] ?? 'Login gagal';
        return AuthResult(success: false, message: msg);
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksimu.',
      );
    }
  }

  // ── REGISTER
  static Future<AuthResult> register({
    required String username,
    required String password,
    required String email,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'username': username,   // sesuaikan dengan field di Laravel
        'password': password,
        'password_confirmation': password,
        'email': email,
        'phone': phone,         // sesuaikan: no_hp / phone_number / dll
        'role': role.toLowerCase(),
      });

      print('=== REGISTER RESPONSE ===');
      print('Status Code: ${response.statusCode}');
      print('Body: ${response.body}');
      print('=========================');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await ApiService.saveToken(data['token']);
        await ApiService.saveRole(role);

        final user = UserModel.fromJson(data['user']);
        return AuthResult(success: true, message: 'Registrasi berhasil', user: user);
      } else {
        // Tangkap validation errors dari Laravel
        if (data['errors'] != null) {
          final errors = data['errors'] as Map<String, dynamic>;
          final firstError = errors.values.first;
          final msg = firstError is List ? firstError.first : firstError.toString();
          return AuthResult(success: false, message: msg);
        }
        final msg = data['message'] ?? 'Registrasi gagal';
        return AuthResult(success: false, message: msg);
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksimu.',
      );
    }
  }

  // ── FORGOT PASSWORD
  static Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await ApiService.post('/auth/forgot-password', {
        'email': email,
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return AuthResult(
          success: true,
          message: data['message'] ?? 'Email reset telah dikirim',
        );
      } else {
        return AuthResult(
          success: false,
          message: data['message'] ?? 'Gagal mengirim email reset',
        );
      }
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Tidak dapat terhubung ke server.',
      );
    }
  }

  // ── LOGOUT
  static Future<void> logout() async {
    try {
      await ApiService.postAuth('/auth/logout', {});
    } catch (_) {}
    await ApiService.clearToken();
  }
}