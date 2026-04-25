import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserController extends ChangeNotifier {
  String _username = 'Burung Camar';
  String _email = 'camar12345@gmail.com';
  String _phoneNumber = '(+62) 812-5555-7777'; 
  String? _profileImagePath;

  List<Map<String, dynamic>> _pendingOrders = [];

  String get username => _username;
  String get email => _email;
  String get phoneNumber => _phoneNumber;
  String? get profileImagePath => _profileImagePath;
  List<Map<String, dynamic>> get pendingOrders => _pendingOrders;

  final ImagePicker _picker = ImagePicker();

  void updateUsername(String newUsername) {
    _username = newUsername;
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