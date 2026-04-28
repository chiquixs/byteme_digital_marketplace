import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/views/auth/login_page.dart';

// ============================================================
// SELLER PROFILE PAGE
// Letakkan file ini di: lib/views/seller/profile/seller_profile_page.dart
// ============================================================

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
                  padding: const EdgeInsets.symmetric(
                      horizontal: 24, vertical: 10),
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
                            child: const Icon(
                                Icons.notifications_none_rounded,
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
                    ),
                    _buildMenuItem(
                      icon: Icons.account_balance_wallet_outlined,
                      label: 'Bank Account',
                      subLabel: 'BCA - Bank Central Asia',
                    ),
                    _buildMenuItem(
                      icon: Icons.alternate_email_rounded,
                      label: 'Email Address',
                      subLabel: userController.email,
                    ),
                    _buildMenuItem(
                      icon: Icons.vpn_key_outlined,
                      label: 'Password',
                      subLabel: '••••••••••••',
                      isLast: true,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  _buildSectionLabel('Store Settings'),
                  const SizedBox(height: 12),
                  _buildMenuCard([
                    _buildMenuItem(
                      icon: Icons.edit_note_rounded,
                      label: 'Store Profile',
                      subLabel: 'Edit store information',
                    ),
                    _buildMenuItem(
                      icon: Icons.notifications_active_outlined,
                      label: 'Notification Settings',
                      subLabel: 'Manage your preferences',
                      isLast: true,
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // ── LOGOUT BUTTON ──
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
  // LOGOUT BUTTON
  // ----------------------------------------------------------
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFFFECEE),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
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
                  Text(
                    'Log Out',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFFFF4D67),
                    ),
                  ),
                  Text(
                    'Logout from this account',
                    style: TextStyle(
                      fontSize: 12,
                      color: Color(0xFFFF8090),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                color: Color(0xFFFF4D67)),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: const Color(0xFFFF4D67).withOpacity(0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.logout_rounded,
                    size: 32, color: Color(0xFFFF4D67)),
              ),
              const SizedBox(height: 16),
              const Text(
                'Log Out?',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1A1D2E),
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Are you sure you want to log out of your account?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF9098B1),
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(ctx),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Color(0xFFD0D5E8)),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Cancel',
                          style: TextStyle(
                              color: Color(0xFF9098B1),
                              fontWeight: FontWeight.w600)),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(ctx);
                        // TODO(backend): Panggil AuthController.logout()
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LoginPage()),
                          (route) => false,
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFFF4D67),
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(vertical: 13),
                      ),
                      child: const Text('Log Out',
                          style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // MAIN USER CARD
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
                      backgroundColor:
                          const Color(0xFF6B7FD7).withOpacity(0.1),
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
        Text(label,
            style: const TextStyle(color: Colors.grey, fontSize: 11)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 14)),
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
          trailing: const Icon(Icons.chevron_right_rounded,
              color: Colors.grey),
          onTap: () {},
        ),
        if (!isLast)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Divider(height: 1, color: Colors.grey.shade100),
          ),
      ],
    );
  }
}
