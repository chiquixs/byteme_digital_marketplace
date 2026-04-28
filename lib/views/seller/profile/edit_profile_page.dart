import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController; // Field baru
  late TextEditingController _passwordController; // Field baru
  
  bool _obscurePassword = true; // State untuk password visibility

  @override
  void initState() {
    super.initState();
    final user = Provider.of<UserController>(context, listen: false);
    _nameController = TextEditingController(text: user.displayName.isEmpty ? user.username : user.displayName);
    _emailController = TextEditingController(text: user.email);
    _phoneController = TextEditingController(text: user.phoneNumber); // Asumsikan ada properti phone di user controller
    _passwordController = TextEditingController(); // Jangan inisialisasi password
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3D4270);
    final userController = Provider.of<UserController>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile', 
          style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Center(
                child: Text(
                  "Update your profile information",
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),
              
              // ── FOTO PROFIL SECTION ──
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor: const Color(0xFF6B7FD7).withOpacity(0.1),
                      backgroundImage: userController.profileImagePath != null
                          ? FileImage(File(userController.profileImagePath!))
                          : null,
                      child: userController.profileImagePath == null
                          ? const Icon(Icons.person, size: 60, color: Color(0xFF3D4270))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          // Panggil fungsi pick image di user controller
                          await userController.pickProfileImage();
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B7FD7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              
              _buildLabel("Display Name"),
              _buildTextField(
                controller: _nameController,
                hint: "Enter username",
                icon: Icons.person_outline_rounded,
              ),
              
              const SizedBox(height: 20),
              
              _buildLabel("Email Address"),
              _buildTextField(
                controller: _emailController,
                hint: "Enter email",
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              
              const SizedBox(height: 20),
              
              // ── FIELD BARU: PHONE NUMBER ──
              _buildLabel("Phone Number"),
              _buildTextField(
                controller: _phoneController,
                hint: "+62 812 3456 7890",
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
              ),
              
              const SizedBox(height: 20),
              
              // ── FIELD BARU: PASSWORD ──
              _buildLabel("Password"),
              _buildTextField(
                controller: _passwordController,
                hint: "••••••••••••",
                icon: Icons.vpn_key_outlined,
                obscureText: _obscurePassword,
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined, color: Colors.grey),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
                validator: (value) {
                  if (value != null && value.isNotEmpty && value.length < 6) {
                    return 'Password must be at least 6 characters';
                  }
                  return null; // Password opsional, jangan validasi kosong jika tidak diedit
                },
              ),
              
              const SizedBox(height: 40),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      // Logic simpan di sini (panggil UserController dengan semua data baru)
                      // Contoh:
                      // userController.updateUserProfile(
                      //   displayName: _nameController.text,
                      //   email: _emailController.text,
                      //   phone: _phoneController.text,
                      //   password: _passwordController.text.isNotEmpty ? _passwordController.text : null,
                      //   profileImage: userController.profileImagePath != null ? File(userController.profileImagePath!) : null,
                      // );
                      
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Profile updating... (Backend TODO)')),
                      );
                      Navigator.pop(context); // Kembali setelah simpan
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: const Text("Save Changes", 
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text, 
        style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3D4270))),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.grey),
        hintText: hint,
        filled: true,
        fillColor: const Color(0xFFF4F6FA),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 16),
        suffixIcon: suffixIcon,
      ),
      validator: validator ?? (value) => value!.isEmpty ? 'Field cannot be empty' : null,
    );
  }
}