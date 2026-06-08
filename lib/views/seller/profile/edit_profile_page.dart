import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/models/user_model.dart';
import 'package:byteme_digital_marketplace/services/api_service.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();

  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  late TextEditingController _passwordController;

  bool _obscurePassword = true;
  bool _isLoading       = false;

  @override
  void initState() {
    super.initState();
    final uc = Provider.of<UserController>(context, listen: false);
    _nameController     = TextEditingController(
        text: uc.displayName.isEmpty ? uc.username : uc.displayName);
    _emailController    = TextEditingController(text: uc.email);
    _phoneController    = TextEditingController(text: uc.phoneNumber);
    _passwordController = TextEditingController();
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
    final uc = Provider.of<UserController>(context);

    // Prioritas tampilan: file lokal baru → URL Supabase → icon default
    ImageProvider? imageProvider;
    if (uc.profileImagePath != null) {
      imageProvider = FileImage(File(uc.profileImagePath!));
    } else if (uc.profileImageUrl != null && uc.profileImageUrl!.isNotEmpty) {
      imageProvider = NetworkImage(uc.profileImageUrl!);
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: primaryColor),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Edit Profile',
            style: TextStyle(
                color: primaryColor, fontWeight: FontWeight.bold)),
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
                  'Update your profile information',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
              ),
              const SizedBox(height: 24),

              // ── FOTO PROFIL ──
              Center(
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 60,
                      backgroundColor:
                          const Color(0xFF6B7FD7).withOpacity(0.1),
                      backgroundImage: imageProvider,
                      child: imageProvider == null
                          ? const Icon(Icons.person,
                              size: 60, color: Color(0xFF3D4270))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () async {
                          await uc.pickProfileImage();
                          if (uc.profileImagePath != null && mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                    'Foto dipilih. Tekan Save untuk menyimpan.'),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: const BoxDecoration(
                            color: Color(0xFF6B7FD7),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt,
                              size: 20, color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              _buildLabel('Display Name'),
              _buildTextField(
                controller: _nameController,
                hint: 'Enter username',
                icon: Icons.person_outline_rounded,
              ),
              const SizedBox(height: 20),

              _buildLabel('Email Address'),
              _buildTextField(
                controller: _emailController,
                hint: 'Enter email',
                icon: Icons.alternate_email_rounded,
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 20),

              _buildLabel('Phone Number'),
              _buildTextField(
                controller: _phoneController,
                hint: '+62 812 3456 7890',
                icon: Icons.phone_outlined,
                keyboardType: TextInputType.phone,
                isRequired: false,
              ),
              const SizedBox(height: 20),

              _buildLabel('Password'),
              _buildTextField(
                controller: _passwordController,
                hint: '••••••••••••',
                icon: Icons.vpn_key_outlined,
                obscureText: _obscurePassword,
                isRequired: false,
                suffixIcon: IconButton(
                  icon: Icon(
                    _obscurePassword
                        ? Icons.visibility_off_outlined
                        : Icons.visibility_outlined,
                    color: Colors.grey,
                  ),
                  onPressed: () =>
                      setState(() => _obscurePassword = !_obscurePassword),
                ),
                validator: (value) {
                  if (value != null &&
                      value.isNotEmpty &&
                      value.length < 6) {
                    return 'Password minimal 6 karakter';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 40),

              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                          if (_formKey.currentState!.validate()) {
                            _onSave(uc);
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primaryColor,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15)),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Text(
                          'Save Changes',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 16),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8, left: 4),
      child: Text(text,
          style: const TextStyle(
              fontWeight: FontWeight.bold, color: Color(0xFF3D4270))),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    bool isRequired = true,
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
      validator: validator ??
          (value) {
            if (isRequired && (value == null || value.isEmpty)) {
              return 'Field ini tidak boleh kosong';
            }
            return null;
          },
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  Future<void> _onSave(UserController uc) async {
    setState(() => _isLoading = true);

    try {
      final fields = <String, String>{
        'username': _nameController.text.trim(),
        'email'   : _emailController.text.trim(),
      };
      if (_phoneController.text.trim().isNotEmpty) {
        fields['phone'] = _phoneController.text.trim();
      }
      if (_passwordController.text.isNotEmpty) {
        fields['password']              = _passwordController.text;
        fields['password_confirmation'] = _passwordController.text;
      }

      // Selalu pakai multipart — menghindari "route not found"
      final response = await ApiService.updateProfileMultipart(
        fields,
        imagePath: uc.profileImagePath,
      );

      final data = jsonDecode(response.body) as Map<String, dynamic>;

      if (response.statusCode == 200) {
        final updatedUser = UserModel.fromJson(data['user'] as Map<String, dynamic>);
        await uc.setUserFromModel(updatedUser);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Profil berhasil disimpan!')),
          );
          Navigator.pop(context);
        }
      } else {
        final msg = (data['message'] as String?) ?? 'Gagal menyimpan profil';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(msg),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
}
