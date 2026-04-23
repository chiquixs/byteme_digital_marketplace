import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserController extends ChangeNotifier {
  // Data user (Default)
  String _username = 'Burung Camar';
  String _email = 'camar12345@gmail.com';
  String _phoneNumber = '(+62) 812-5555-7777'; 
  String? _profileImagePath;

  // Getters
  String get username => _username;
  String get email => _email;
  String get phoneNumber => _phoneNumber; // <-- TAMBAHAN BARU
  String? get profileImagePath => _profileImagePath;

  final ImagePicker _picker = ImagePicker();

  void updateUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  // Tambahan baru untuk update No HP
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

  // Update profile lengkap (Ditambah Phone)
  void updateProfile({
    String? username,
    String? email,
    String? phoneNumber,
    String? profileImagePath,
  }) {
    if (username != null) _username = username;
    if (email != null) _email = email;
    if (phoneNumber != null) _phoneNumber = phoneNumber;
    if (profileImagePath != null) _profileImagePath = profileImagePath;
    notifyListeners();
  }

  void clearProfileImage() {
    _profileImagePath = null;
    notifyListeners();
  }
}