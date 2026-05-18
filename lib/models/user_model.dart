class UserModel {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String role;
  final String? profileImage; // ← TAMBAH: URL foto dari Supabase

  UserModel({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString() ?? '',
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? '',
      role: json['role'] ?? 'buyer',
      profileImage: json['profile_image'], // ← baca dari response Laravel
    );
  }
}
