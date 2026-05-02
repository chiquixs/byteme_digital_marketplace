class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String role; // 'buyer' atau 'seller'

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',        // ← UUID string
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',              // ← pakai ?? '' agar tidak crash
      role: json['role'] ?? 'buyer',
    );
  }
}