import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/views/auth/login_page.dart';
// Pastikan kamu mengimpor file edit profile yang akan kita buat di bawah
import 'package:byteme_digital_marketplace/views/seller/profile/edit_profile_page.dart';

class SellerProfilePage extends StatelessWidget {
  const SellerProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    const Color primaryColor = Color(0xFF3D4270);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F6FA),
      body: Column(
        children: [
          // ── HEADER & USER CARD ──
          Stack(
            children: [
              Container(
                height: 220,
                decoration: const BoxDecoration(
                  color: primaryColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(40),
                    bottomRight: Radius.circular(40),
                  ),
                ),
              ),
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(Icons.notifications_none_rounded,
                                color: Colors.white),
                          ),
                        ],
                      ),
                      const SizedBox(height: 25),
                      _buildMainUserCard(context, userController),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // ── MENU LIST ──
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionLabel('Account Information'),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.storefront_rounded,
                      label: 'Display Name',
                      subLabel: userController.displayName.isEmpty
                          ? userController.username
                          : userController.displayName,
                      showChevron: false, // Ikon > dihilangkan
                    ),
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Bank Account',
                      subLabel: 'BCA - Bank Central Asia',
                      showChevron: false, // Ikon > dihilangkan
                    ),
                    _buildMenuItem(
                      icon: Icons.alternate_email_rounded,
                      label: 'Email Address',
                      subLabel: userController.email,
                      showChevron: false, // Ikon > dihilangkan
                    ),
                    _buildMenuItem(
                      icon: Icons.vpn_key_outlined,
                      label: 'Password',
                      subLabel: '••••••••••••',
                      isLast: true,
                      showChevron: false, // Ikon > dihilangkan
                    ),
                  ]),
                  const SizedBox(height: 24),
                  const SizedBox(height: 24),
                  _buildLogoutButton(context),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // MAIN USER CARD (DENGAN TOMBOL EDIT)
  // ----------------------------------------------------------
  Widget _buildMainUserCard(BuildContext context, UserController user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            children: [
              GestureDetector(
                onTap: () => user.pickProfileImage(),
                child: Stack(
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color(0xFF6B7FD7).withOpacity(0.1),
                      backgroundImage: user.profileImagePath != null
                          ? FileImage(File(user.profileImagePath!))
                          : null,
                      child: user.profileImagePath == null
                          ? const Icon(Icons.person,
                              size: 35, color: Color(0xFF3D4270))
                          : null,
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Color(0xFF6B7FD7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.camera_alt,
                            size: 12, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          user.username,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        const SizedBox(width: 5),
                        const Icon(Icons.verified,
                            color: Color(0xFF6B7FD7), size: 18),
                      ],
                    ),
                    Text(
                      user.email,
                      style: TextStyle(
                          color: Colors.grey.shade600, fontSize: 13),
                    ),
                  ],
                ),
              ),
              // TOMBOL EDIT DI SAMPING NAMA
              IconButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const EditProfilePage()),
                  );
                },
                icon: const Icon(Icons.edit_note_rounded, 
                    color: Color(0xFF3D4270), size: 28),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildSimpleStat('Member Since', 'Nov 2, 2026'),
              _buildSimpleStat('Total Sales', '167'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSimpleStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  // ----------------------------------------------------------
  // MENU HELPERS
  // ----------------------------------------------------------
  Widget _buildSectionLabel(String label) {
    return Text(
      label,
      style: const TextStyle(
          fontWeight: FontWeight.bold,
          fontSize: 15,
          color: Color(0xFF3D4270)),
    );
  }

  Widget _buildMenuCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required String subLabel,
    bool isLast = false,
    bool showChevron = true, // Tambahkan parameter ini
    VoidCallback? onTap,
  }) {
    return Column(
      children: [
        ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: const Color(0xFFF4F6FA),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: const Color(0xFF3D4270), size: 20),
          ),
          title: Text(label,
              style: const TextStyle(fontSize: 12, color: Colors.grey)),
          subtitle: Text(subLabel,
              style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87)),
          trailing: showChevron 
              ? const Icon(Icons.chevron_right_rounded, color: Colors.grey)
              : null, // Jika false, trailing dikosongkan
          onTap: onTap,
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
      ],
    );
  }

  // ----------------------------------------------------------
  // LOGOUT BUTTON & DIALOG (SAMA SEPERTI SEBELUMNYA)
  // ----------------------------------------------------------
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFECEE),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: const Color(0xFFFF4D67).withOpacity(0.15),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.logout_rounded,
                  color: Color(0xFFFF4D67), size: 20),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Log Out',
                      style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFFFF4D67))),
                  Text('Logout from this account',
                      style: TextStyle(fontSize: 12, color: Color(0xFFFF8090))),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: Color(0xFFFF4D67)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text("Log Out?"),
        content: const Text("Are you sure you want to log out?"),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(builder: (_) => const LoginPage()),
                (route) => false,
              );
            },
            child: const Text("Log Out", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}