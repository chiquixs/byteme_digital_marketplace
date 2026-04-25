import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/views/my_orders/history_orders_page.dart';
import 'package:byteme_digital_marketplace/views/wishlist/wishlist_page.dart'; 
import 'edit_profile_page.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return const _ProfilePageContent();
  }
}

class _ProfilePageContent extends StatefulWidget {
  const _ProfilePageContent();

  @override
  State<_ProfilePageContent> createState() => _ProfilePageContentState();
}

class _ProfilePageContentState extends State<_ProfilePageContent> {
  // --- Color Palette (from mockup) ---
  static const Color _bgDark = Color(0xFF3D4270);
  static const Color _bgLight = Color(0xFF8B90C1);
  static const Color _cardBg = Color(0xFFF0F0F8);
  static const Color _accentBlue = Color(0xFF3D4270);
  static const Color _white = Colors.white;
  static const Color _iconBg = Color(0xFF3D4270);
  static const Color _starColor = Color(0xFF3D4270);

  @override
  Widget build(BuildContext context) {
    return Consumer<UserController>(
      builder: (context, userController, child) {
        return Container(
          color: _bgLight,
          child: SafeArea(
            child: Column(
              children: [
                _buildHeader(userController),

                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildPurchaseCard(),

                        const SizedBox(height: 16),

                        // MENU FAVORITES (MENGGANTIKAN WISHLIST)
                        _buildMenuItem(
                          icon: Icons.favorite_border,
                          label: 'Favorites',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => const WishlistPage()),
                          ),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildMenuItem(
                          icon: Icons.credit_card_outlined,
                          label: 'Payment',
                          onTap: () => _showMenuSnack('Payment'),
                        ),
                        
                        const SizedBox(height: 12),
                        
                        _buildMenuItem(
                          icon: Icons.history_toggle_off,
                          label: 'History Orders',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const HistoryOrdersPage(),
                            ),
                          ),
                        ),

                        const SizedBox(height: 24),

                        Center(
                          child: Text(
                            'ByteMe',
                            style: TextStyle(
                              color: _accentBlue,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(UserController userController) {
    return Container(
      color: _bgDark,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white24,
              border: Border.all(color: Colors.white38, width: 2),
              image: userController.profileImagePath != null
                  ? DecorationImage(
                      image: FileImage(File(userController.profileImagePath!)),
                      fit: BoxFit.cover,
                    )
                  : null,
            ),
            child: userController.profileImagePath == null
                ? const Icon(Icons.person, color: _white, size: 32)
                : null,
          ),
          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userController.username,
                  style: const TextStyle(
                    color: _white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  userController.email,
                  style: const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),

          IconButton(
            icon: const Icon(
              Icons.manage_accounts_outlined,
              color: _white,
              size: 28,
            ),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseCard() {
    return Container(
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Current Order',
              style: TextStyle(
                color: _accentBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          const Divider(height: 1, thickness: 0.5),

          _buildProductRow(
            title: 'Barang 1',
            rating: 5,
            reviews: '1.2k reviews',
          ),

          const Divider(height: 1, thickness: 0.5, indent: 16),

          _buildProductRow(
            title: 'Barang 2',
            rating: 5,
            reviews: '1.2k reviews',
            isLast: true,
          ),
        ],
      ),
    );
  }

  Widget _buildProductRow({
    required String title,
    required int rating,
    required String reviews,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, isLast ? 14 : 12),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: _accentBlue.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.image_outlined,
              color: _accentBlue.withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF2E2E2E),
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.star_rounded, color: _starColor, size: 16),
                    const SizedBox(width: 4),
                    Text(
                      '$rating  $reviews',
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: _iconBg,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: _white, size: 20),
            ),
            const SizedBox(width: 14),

            Expanded(
              child: Text(
                label,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF2A2A2A),
                ),
              ),
            ),

            const Icon(Icons.chevron_right_rounded, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _showMenuSnack(String label) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Tapped: $label'),
        duration: const Duration(milliseconds: 700),
        backgroundColor: _bgDark,
      ),
    );
  }
}