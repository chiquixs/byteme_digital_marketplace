class UserModel {
  final String? id; // Gabungan dari versi seller
  final String username;
  final String email;
  final String phone;
  final String role;
  final String? profileImage;
  final double? balance; // Gabungan dari versi buyer
  
  UserModel({
    this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.profileImage,
    this.balance,
  });

  // ── MAPPING DATA DARI JSON BACKEND / LARAVEL SUPABASE ──
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id']?.toString(),
      username: json['username'] ?? json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'] ?? json['phone_number'] ?? json['no_hp'] ?? '',
      role: json['role'] ?? 'Buyer',
      profileImage: json['profile_image'] ?? json['avatar_url'] ?? json['avatar'],
      
      // MEMBACA KOLOM BALANCE DARI SUPABASE
      balance: json['balance'] != null 
          ? (json['balance'] as num).toDouble() 
          : 0.0,
    );
  }

  // ── KONVERSI KEMBALI KE JSON ──
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'profile_image': profileImage,
      'balance': balance,
    };
  }
}