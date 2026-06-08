import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:byteme_digital_marketplace/models/user_model.dart';

class UserController extends ChangeNotifier {
  String _username = '';
  String _displayName = '';
  String _email = '';
  String _phoneNumber = '';
  String? _profileImagePath; // path file lokal (sementara, sebelum di-upload)
  String? _profileImageUrl;  // ← TAMBAH: URL dari Supabase (permanent)
  String _role = 'Buyer';
  List<Map<String, dynamic>> _pendingOrders = [];

  String get username => _username;
  String get displayName => _displayName;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String? get profileImagePath => _profileImagePath;
  String? get profileImageUrl => _profileImageUrl; // ← TAMBAH getter
  String get role => _role;
  List<Map<String, dynamic>> get pendingOrders => _pendingOrders;

  final ImagePicker _picker = ImagePicker();

  // ── LOAD dari SharedPreferences saat app start
  Future<void> loadUserFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    _username        = prefs.getString('user_username') ?? '';
    _email           = prefs.getString('user_email') ?? '';
    _phoneNumber     = prefs.getString('user_phone') ?? '';
    _role            = prefs.getString('user_role') ?? 'Buyer';
    _displayName     = prefs.getString('user_displayname') ?? _username;
    _profileImageUrl = prefs.getString('user_profile_image'); // ← TAMBAH
    notifyListeners();
  }

  // ── SIMPAN data user dari response login / register / update
  Future<void> setUserFromModel(UserModel user) async {
    final prefs = await SharedPreferences.getInstance();

    _username        = user.username;
    _email           = user.email;
    _phoneNumber     = user.phone;
    _role            = user.role;
    _displayName     = user.username;
    _profileImageUrl = user.profileImage; // ← TAMBAH

    await prefs.setString('user_username', user.username);
    await prefs.setString('user_email', user.email);
    await prefs.setString('user_phone', user.phone);
    await prefs.setString('user_role', user.role);
    await prefs.setString('user_displayname', user.username);

    // ← TAMBAH: simpan / hapus URL foto di SharedPreferences
    if (user.profileImage != null && user.profileImage!.isNotEmpty) {
      await prefs.setString('user_profile_image', user.profileImage!);
    } else {
      await prefs.remove('user_profile_image');
    }

    _profileImagePath = null; // bersihkan path lokal setelah upload berhasil
    notifyListeners();
  }

  // ── CLEAR saat logout
  Future<void> clearUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    _username         = '';
    _email            = '';
    _phoneNumber      = '';
    _role             = 'Buyer';
    _displayName      = '';
    _profileImagePath = null;
    _profileImageUrl  = null; // ← TAMBAH
    _pendingOrders    = [];

    notifyListeners();
  }

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

  void updateProfile({
    String? username,
    String? displayName,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
    String? profileImageUrl, // ← TAMBAH
    String? role,
  }) {
    if (username != null) _username = username;
    if (displayName != null) _displayName = displayName;
    if (email != null) _email = email;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (profileImagePath != null) _profileImagePath = profileImagePath;
    if (profileImageUrl != null) _profileImageUrl = profileImageUrl; // ← TAMBAH
    if (role != null) _role = role;
    notifyListeners();
  }

  void clearProfileImage() {
    _profileImagePath = null;
    notifyListeners();
  }

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
