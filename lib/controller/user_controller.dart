import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserController extends ChangeNotifier {
  // Default user data
  String _username = 'Burung Camar';
  String _email = 'camar12345@gamil.com';
  String? _profileImagePath;

  // Getters
  String get username => _username;
  String get email => _email;
  String? get profileImagePath => _profileImagePath;

  // Image picker instance
  final ImagePicker _picker = ImagePicker();

  /// Update username
  void updateUsername(String newUsername) {
    _username = newUsername;
    notifyListeners();
  }

  /// Update email
  void updateEmail(String newEmail) {
    _email = newEmail;
    notifyListeners();
  }

  /// Pick image from gallery and update profile photo
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

  /// Update full profile
  void updateProfile({
    String? username,
    String? email,
    String? profileImagePath,
  }) {
    if (username != null) _username = username;
    if (email != null) _email = email;
    if (profileImagePath != null) _profileImagePath = profileImagePath;
    notifyListeners();
  }

  /// Clear profile image (reset to default)
  void clearProfileImage() {
    _profileImagePath = null;
    notifyListeners();
  }
}
