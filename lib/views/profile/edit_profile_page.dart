import 'package:flutter/material.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  // ── Color palette (sama dengan ProfilePage) ──
  static const Color _bgLight   = Color(0xFF8B90C1);
  static const Color _bgDark    = Color(0xFF3D4270);
  static const Color _cardBg    = Color(0xFFF0F0F8);
  static const Color _accent    = Color(0xFF6B74B2);
  static const Color _white     = Colors.white;

  // ── Form controllers ──
  final _usernameCtrl  = TextEditingController(text: 'Burung Camar');
  final _emailCtrl     = TextEditingController(text: 'camar12345@gamil.com');
  final _passwordCtrl  = TextEditingController();
  final _phoneCtrl     = TextEditingController();

  bool _obscurePassword = true;

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _phoneCtrl.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bgLight,
      body: SafeArea(
        child: Column(
          children: [
            // ── AppBar custom ──────────────────────────────────────────────
            _buildAppBar(context),

            // ── Scrollable body ───────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Foto profil section
                    _buildPhotoSection(),

                    // Form section
                    _buildFormSection(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      // Bottom nav bar (non-interaktif, dekoratif)
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // AppBar
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildAppBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _white,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: Color(0xFF2A2A2A),
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Photo section (area besar + tombol upload)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPhotoSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      width: double.infinity,
      height: 220,
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 90,
            height: 90,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: _bgLight.withOpacity(0.4),
              border: Border.all(color: _bgDark.withOpacity(0.3), width: 2),
            ),
            child: const Icon(Icons.person, color: _bgDark, size: 48),
          ),
          const SizedBox(height: 20), // ini margin-nya, tinggal atur angkanya
          ElevatedButton.icon(
            onPressed: _onUploadPhoto,
                style: ElevatedButton.styleFrom(
                  backgroundColor: _accent,
                  foregroundColor: _white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                icon: const Icon(Icons.upload_rounded, size: 16),
                label: const Text(
                  'Upload a New Photo',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Form section
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildFormSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
      decoration: BoxDecoration(
        color: _white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Judul
          const Center(
            child: Text(
              'Change Information Here',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Color(0xFF2A2A2A),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Fields
          _buildField(
            label: 'Username*',
            controller: _usernameCtrl,
            keyboardType: TextInputType.name,
          ),
          const SizedBox(height: 16),
          _buildField(
            label: 'Email Address*',
            controller: _emailCtrl,
            keyboardType: TextInputType.emailAddress,
          ),
          const SizedBox(height: 16),
          _buildPasswordField(),
          const SizedBox(height: 16),
          _buildField(
            label: 'No Hp*',
            controller: _phoneCtrl,
            keyboardType: TextInputType.phone,
          ),
          const SizedBox(height: 28),

          // Tombol Update
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              onPressed: _onUpdate,
              style: ElevatedButton.styleFrom(
                backgroundColor: _accent,
                foregroundColor: _white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: const Text(
                'Update',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Field builder
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildField({
    required String label,
    required TextEditingController controller,
    TextInputType keyboardType = TextInputType.text,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: controller,
          keyboardType: keyboardType,
          style: const TextStyle(fontSize: 14, color: Color(0xFF2A2A2A)),
          decoration: InputDecoration(
            filled: true,
            fillColor: _cardBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Password field (dengan toggle show/hide)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildPasswordField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Password*',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: Color(0xFF2A2A2A),
          ),
        ),
        const SizedBox(height: 6),
        TextField(
          controller: _passwordCtrl,
          obscureText: _obscurePassword,
          style: const TextStyle(fontSize: 14, color: Color(0xFF2A2A2A)),
          decoration: InputDecoration(
            filled: true,
            fillColor: _cardBg,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: _accent, width: 1.5),
            ),
            suffixIcon: IconButton(
              icon: Icon(
                _obscurePassword
                    ? Icons.visibility_off_outlined
                    : Icons.visibility_outlined,
                color: Colors.grey,
                size: 20,
              ),
              onPressed: () =>
                  setState(() => _obscurePassword = !_obscurePassword),
            ),
          ),
        ),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Bottom nav bar dekoratif (sama persis dengan app utama)
  // ─────────────────────────────────────────────────────────────────────────
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _navItem(Icons.home_rounded, 'Home', false),
              _navItem(Icons.explore_rounded, 'Explore', false),
              _navItem(Icons.shopping_bag_rounded, 'Cart', false),
              _navItem(Icons.person_rounded, 'Profile', true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navItem(IconData icon, String label, bool active) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: active
            ? const Color(0xFF6B7FD7).withOpacity(0.12)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon,
              color: active
                  ? const Color(0xFF6B7FD7)
                  : const Color(0xFFB0B8CC),
              size: 24),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: active ? FontWeight.w600 : FontWeight.w400,
              color: active
                  ? const Color(0xFF6B7FD7)
                  : const Color(0xFFB0B8CC),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Handlers
  // ─────────────────────────────────────────────────────────────────────────
  void _onUploadPhoto() {
    // TODO: Integrasikan image_picker di sini
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Fitur upload foto belum tersedia'),
        backgroundColor: _bgDark,
        duration: const Duration(milliseconds: 1200),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  void _onUpdate() {
    // TODO: Panggil UserController.updateProfile() di sini
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Profil berhasil diperbarui!'),
        backgroundColor: _bgDark,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}