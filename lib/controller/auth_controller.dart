import 'dart:convert';
import 'package:byteme_digital_marketplace/models/user_model.dart';
import 'package:byteme_digital_marketplace/services/api_service.dart';

class AuthResult {
  final bool success;
  final String message;
  final UserModel? user;
  final String? accountStatus; // 'active' | 'warning' | 'banned' | 'suspended'

  AuthResult({
    required this.success,
    required this.message,
    this.user,
    this.accountStatus,
  });
}

class AuthController {
  static Future<AuthResult> login({
    required String username,
    required String password,
    required String role,
  }) async {
    try {
      final response = await ApiService.post('/auth/login', {
        'username': username,
        'password': password,
        'role': role.toLowerCase(),
      });

      final data = jsonDecode(response.body);
      final status = data['status'] as String?;

      if (response.statusCode == 200) {
        // Backend returns 200 for both 'active' and 'warning' accounts.
        // 'warning' accounts still receive a token and can log in.
        if (data['token'] != null) {
          await ApiService.saveToken(data['token']);
          await ApiService.saveRole(role);
        }

        final user = UserModel.fromJson(data['user']);

        return AuthResult(
          success: true,
          message: data['message'] ?? 'Login berhasil',
          user: user,
          accountStatus: status ?? 'active',
        );
      }

      if (response.statusCode == 403) {
        // banned / suspended — no token issued
        final msg = data['message'] ?? 'Akun Anda telah diblokir.';
        return AuthResult(
          success: false,
          message: msg,
          accountStatus: status, // 'banned' or 'suspended'
        );
      }

      // 401 wrong credentials, or other errors
      return AuthResult(
        success: false,
        message: data['message'] ?? 'Login gagal',
      );
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksimu.',
      );
    }
  }

  static Future<AuthResult> register({
    required String username,
    required String password,
    required String email,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await ApiService.post('/auth/register', {
        'username': username,
        'password': password,
        'password_confirmation': password,
        'email': email,
        'phone': phone,
        'role': role.toLowerCase(),
      });

      final data = jsonDecode(response.body);

      if (response.statusCode == 200 || response.statusCode == 201) {
        await ApiService.saveToken(data['token']);
        await ApiService.saveRole(role);
        final user = UserModel.fromJson(data['user']);
        return AuthResult(success: true, message: 'Registrasi berhasil', user: user);
      }

      if (data['errors'] != null) {
        final errors = data['errors'] as Map<String, dynamic>;
        final firstError = errors.values.first;
        final msg = firstError is List ? firstError.first : firstError.toString();
        return AuthResult(success: false, message: msg);
      }

      return AuthResult(success: false, message: data['message'] ?? 'Registrasi gagal');
    } catch (e) {
      return AuthResult(
        success: false,
        message: 'Tidak dapat terhubung ke server. Periksa koneksimu.',
      );
    }
  }

  static Future<AuthResult> forgotPassword({required String email}) async {
    try {
      final response = await ApiService.post('/auth/forgot-password', {'email': email});
      final data = jsonDecode(response.body);
      if (response.statusCode == 200) {
        return AuthResult(success: true, message: data['message'] ?? 'Email reset telah dikirim');
      }
      return AuthResult(success: false, message: data['message'] ?? 'Gagal mengirim email reset');
    } catch (e) {
      return AuthResult(success: false, message: 'Tidak dapat terhubung ke server.');
    }
  }

  static Future<void> logout() async {
    try {
      await ApiService.postAuth('/auth/logout', {});
    } catch (_) {}
    await ApiService.clearToken();
  }
}