import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/controller/buyer/order_controller.dart';
import 'package:byteme_digital_marketplace/views/auth/login_page.dart';
import 'package:byteme_digital_marketplace/views/buyer/my_orders/history_orders_page.dart';
import 'package:byteme_digital_marketplace/views/buyer/wishlist/wishlist_page.dart';
import 'package:byteme_digital_marketplace/views/buyer/payment/unpaid_order.dart';
import 'package:byteme_digital_marketplace/models/buyer/order_item.dart';
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
  static const Color _bgDark = Color(0xFF3D4270);
  static const Color _bgLight = Color(0xFF8B90C1);
  static const Color _cardBg = Color(0xFFF0F0F8);
  static const Color _accentBlue = Color(0xFF3D4270);
  static const Color _white = Colors.white;
  static const Color _iconBg = Color(0xFF3D4270);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 🌟 KITA BAJAK API HISTORY ORDER KARENA INI YANG SUDAH TERBUKTI JALAN 🌟
      context.read<OrderController>().fetchHistoryOrders();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<UserController, OrderController>(
      builder: (context, userController, orderController, child) {
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
                        // 🌟 TAMPILAN CARD PESANAN
                        _buildPurchaseCard(orderController),
                        const SizedBox(height: 16),

                        _buildMenuItem(
                          icon: Icons.favorite_border,
                          label: 'Favorites',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const WishlistPage()),
                          ),
                        ),
                        const SizedBox(height: 12),

                        _buildMenuItem(
                          icon: Icons.credit_card_outlined,
                          label: 'Payment',
                          onTap: () {
                            if (userController.pendingOrders.isEmpty) {
                              _showMenuSnack('No pending payments');
                            } else {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) => UnpaidOrderPage(
                                    items: userController.pendingOrders
                                        .last['items'] as List<Map<String, dynamic>>,
                                    totalAmount: userController
                                        .pendingOrders.last['total'] as int,
                                  ),
                                ),
                              );
                            }
                          },
                        ),
                        const SizedBox(height: 12),

                        _buildMenuItem(
                          icon: Icons.history_toggle_off,
                          label: 'History Orders',
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (_) => const HistoryOrdersPage()),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── LOGOUT BUTTON ──
                        _buildLogoutButton(context),

                        const SizedBox(height: 24),

                        const Center(
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

  // ----------------------------------------------------------
  // LOGOUT BUTTON
  // ----------------------------------------------------------
  Widget _buildLogoutButton(BuildContext context) {
    return GestureDetector(
      onTap: () => _showLogoutDialog(context),
      child: Container(
        decoration: BoxDecoration(
          color: const Color(0xFFFFECEE),
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
                color: const Color(0xFFFF4D67),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.logout_rounded,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 14),
            const Expanded(
              child: Text(
                'Log Out',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFFFF4D67),
                ),
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
  // HEADER
  // ----------------------------------------------------------
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
                  : userController.profileImageUrl != null
                      ? DecorationImage(
                          image: NetworkImage(userController.profileImageUrl!),
                          fit: BoxFit.cover,
                        )
                      : null,
            ),
            child: (userController.profileImagePath == null &&
                    userController.profileImageUrl == null)
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
                  style:
                      const TextStyle(color: Colors.white70, fontSize: 13),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.manage_accounts_outlined,
                color: _white, size: 28),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const EditProfilePage()),
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // PURCHASE CARD (KITA AMBIL DARI HISTORY ORDER SEKARANG)
  // ----------------------------------------------------------
  Widget _buildPurchaseCard(OrderController orderController) {
    // 🌟 KUNCI PERUBAHAN: MENGAMBIL DARI HISTORY BUKAN CURRENT 🌟
    final orders = orderController.historyOrders;
    
    // Ambil maksimal 2 data teratas
    final displayOrders = orders.take(2).toList();

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
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 14, 16, 8),
            child: Text(
              'Recent Orders', // Diganti nama agar lebih masuk akal
              style: TextStyle(
                color: _accentBlue,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),
          const Divider(height: 1, thickness: 0.5),
          
          if (displayOrders.isEmpty)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Center(
                child: Text(
                  'No recent orders',
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
              ),
            )
          else
            ...displayOrders.asMap().entries.map((entry) {
              final int index = entry.key;
              final OrderItem order = entry.value;
              final bool isLast = index == displayOrders.length - 1;

              return Column(
                children: [
                  _buildProductRow(
                    order: order,
                    isLast: isLast,
                  ),
                  if (!isLast)
                    const Divider(height: 1, thickness: 0.5, indent: 16),
                ],
              );
            }),
        ],
      ),
    );
  }

  // 🌟 Sama persis dengan HistoryOrdersPage 🌟
  Widget _buildProductRow({
    required OrderItem order,
    bool isLast = false,
  }) {
    return Padding(
      padding: EdgeInsets.fromLTRB(16, 12, 16, isLast ? 14 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(color: const Color(0xFFF0F2F8), borderRadius: BorderRadius.circular(12)),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: order.imagePath.isNotEmpty && order.imagePath.startsWith('http')
                  ? Image.network(
                      order.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported_outlined, color: Color(0xFF8B90C1), size: 28),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B7FD7)));
                      },
                    )
                  : const Icon(Icons.shopping_bag_outlined, color: Color(0xFF8B90C1), size: 28),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName, 
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3D4270)), 
                  maxLines: 1, 
                  overflow: TextOverflow.ellipsis
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // MENU ITEM
  // ----------------------------------------------------------
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
        content: Text(label),
        duration: const Duration(milliseconds: 700),
        backgroundColor: _bgDark,
      ),
    );
  }
}