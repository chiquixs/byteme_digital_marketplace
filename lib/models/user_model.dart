class UserModel {
  final String? id;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final double? balance;
  final DateTime? createdAt; // ← TAMBAH

  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.balance,
    this.createdAt, // ← TAMBAH
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      username: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? json['no_hp'] ?? '',
      role: json['role'] ?? 'Buyer',
      profileImage: json['profile_image'] ?? json['avatar_url'] ?? json['avatar'],
      balance: json['balance'] != null
          ? (json['balance'] as num).toDouble()
          : 0.0,
      // ← TAMBAH: parse created_at dari Laravel
      createdAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'].toString())
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_image': profileImage,
      'balance': balance,
      'created_at': createdAt?.toIso8601String(), // ← TAMBAH
    };
  }
}