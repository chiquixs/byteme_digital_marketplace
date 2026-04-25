import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserController extends ChangeNotifier {
  // ── DATA DASAR (Dipakai Buyer & Seller) ──────────────────────────────────
  String _username = 'Burung Camar';
  String _displayName = ''; // Nama Toko / Nama Publik Seller
  String _email = 'camar12345@gmail.com';
  String _phoneNumber = '(+62) 812-5555-7777'; 
  String? _profileImagePath;
  String _role = 'Buyer'; // Default role

  // ── DATA KHUSUS (Dipakai sesuai Role) ─────────────────────────────────────
  List<Map<String, dynamic>> _pendingOrders = [];

  // ── GETTERS ──────────────────────────────────────────────────────────────
  String get username => _username;
  String get displayName => _displayName;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String? get profileImagePath => _profileImagePath;
  String get role => _role;
  List<Map<String, dynamic>> get pendingOrders => _pendingOrders;

  final ImagePicker _picker = ImagePicker();

  // ── METHODS PROFIL ────────────────────────────────────────────────────────
  void updateUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void updateDisplayName(String newName) {
    _displayName = newName;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  void updatePhoneNumber(String newPhone) {
    _phoneNumber = newPhone;
    notifyListeners();
  }

  Future<void> pickProfileImage() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 500,
        maxHeight: 500,
        imageQuality: 80,
      );

      if (image != null) {
        _profileImagePath = image.path;
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error picking image: $e');
    }
  }

  // Method Update Profile Lengkap
  void updateProfile({
    String? username,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
    String? role,
  }) {
    if (username != null) _username = username;
    if (displayName != null) _displayName = displayName;
    if (email != null) _email = email;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (profileImagePath != null) _profileImagePath = profileImagePath;
    if (role != null) _role = role;
    notifyListeners();
  }

  void clearProfileImage() {
    _profileImagePath = null;
    notifyListeners();
  }

  // ── LOGIC PEMBAYARAN (Buyer) ──────────────────────────────────────────────
  void addPendingOrder(List<Map<String, dynamic>> items, int total) {
    _pendingOrders.add({
      'id': 'ORD-${DateTime.now().millisecondsSinceEpoch}',
      'items': items,
      'total': total,
      'deadline': DateTime.now().add(const Duration(hours: 24)),
      'status': 'Pending',
    });
    notifyListeners();
  }

  void clearPendingOrder(String orderId) {
    _pendingOrders.removeWhere((order) => order['id'] == orderId);
    notifyListeners();
  }
}