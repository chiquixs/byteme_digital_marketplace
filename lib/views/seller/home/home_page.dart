import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/views/seller/profile/seller_profile_page.dart';
import 'package:byteme_digital_marketplace/views/seller/earnings/earnings_page.dart';

class SellerHomePage extends StatefulWidget {
  const SellerHomePage({super.key});

  @override
  State<SellerHomePage> createState() => _SellerHomePageState();
}

class _SellerHomePageState extends State<SellerHomePage> {
  int _currentIndex = 0;

  void _switchTab(int index) {
    setState(() => _currentIndex = index);
  }

  // DAFTAR HALAMAN
  List<Widget> get _pages => [
        const SellerHomeContent(),
        const Center(child: Text('Product Management')), 
        const Center(child: Text('My Orders')),
        const EarningsPage(),
        const SellerProfilePage(), 
      ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: _pages[_currentIndex],
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  // --- BOTTOM NAV BAR ---
  Widget _buildBottomNavBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
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
              _buildNavItem(0, Icons.home_rounded, 'Dashboard'),
              _buildNavItem(1, Icons.grid_view_rounded, 'Product'),
              _buildNavItem(2, Icons.shopping_bag_outlined, 'My Order'),
              _buildNavItem(3, Icons.auto_graph_rounded, 'Earnings'),
              _buildNavItem(4, Icons.person_rounded, 'Profile'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(int index, IconData icon, String label) {
    final bool isSelected = _currentIndex == index;
    return GestureDetector(
      onTap: () => _switchTab(index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF6B7FD7).withOpacity(0.1) : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF6B7FD7) : const Color(0xFFB0B8CC),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                color: isSelected ? const Color(0xFF6B7FD7) : const Color(0xFFB0B8CC),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CONTENT DASHBOARD SELLER
// ============================================================
class SellerHomeContent extends StatelessWidget {
  const SellerHomeContent({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    const Color accentColor = Color(0xFF3D4270);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- HEADER ---
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor: accentColor.withOpacity(0.1),
                  child: const Icon(Icons.person, color: accentColor),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Welcome 😊,', style: TextStyle(color: Colors.grey, fontSize: 12)),
                    Text(
                      userController.displayName.isEmpty ? userController.username : userController.displayName,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ],
                ),
                const Spacer(),
                _buildCircleIconButton(Icons.notifications_none_rounded),
              ],
            ),
            const SizedBox(height: 24),

            const Text('Vendor Dashboard', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18)),
            const SizedBox(height: 16),

            // --- BALANCE CARD ---
            _buildBalanceCard(),

            const SizedBox(height: 20),

            // --- STATS ROW ---
            Row(
              children: [
                _buildStatCard('Total Sales', '39', Icons.shopping_bag_outlined),
                const SizedBox(width: 16),
                _buildStatCard('Total Product', '12', Icons.inventory_2_outlined),
              ],
            ),

            const SizedBox(height: 28),

            // --- DISCOVER PRODUCT ---
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Discover Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: accentColor)),
                GestureDetector(
                  onTap: () {},
                  child: const Text('more >', style: TextStyle(color: Color(0xFF6B7FD7), fontSize: 13)),
                ),
              ],
            ),
            const SizedBox(height: 16),

            // GRID PRODUK
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 4, // Contoh 4 produk
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                childAspectRatio: 0.75, // Disesuaikan agar pas tanpa button
              ),
              itemBuilder: (context, index) {
                return _buildProductCard(
                  index == 0 ? 'E-Book Material' : 'Girls E-Book',
                  index == 0 ? 'Rp 59.000' : 'Rp 78.000',
                  index == 0 ? Colors.blue.shade50 : Colors.pink.shade50,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildBalanceCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF6B7FD7), Color(0xFF8B90C1)]),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: const Color(0xFF6B7FD7).withOpacity(0.3), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
              Icon(Icons.visibility_outlined, color: Colors.white.withOpacity(0.5), size: 20),
            ],
          ),
          const Text('\$1,250.80', style: TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Available for Withdraw', style: TextStyle(color: Colors.white70, fontSize: 11)),
                  Text('\$1,120.40', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                ],
              ),
              ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: const Color(0xFF3D4270),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                child: const Text('Withdraw', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
                Icon(icon, size: 16, color: const Color(0xFF6B7FD7)),
              ],
            ),
            const SizedBox(height: 8),
            Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard(String name, String price, Color bgColor) {
    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(color: bgColor, borderRadius: const BorderRadius.vertical(top: Radius.circular(16))),
              child: const Icon(Icons.image_outlined, color: Colors.white, size: 40),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 4),
                const Row(
                  children: [
                    Icon(Icons.star, color: Colors.amber, size: 12),
                    SizedBox(width: 4),
                    Text('4.5 | 1.2k Reviews', style: TextStyle(color: Colors.grey, fontSize: 10)),
                  ],
                ),
                const SizedBox(height: 4),
                Text(price, style: const TextStyle(color: Color(0xFF6B7FD7), fontWeight: FontWeight.bold, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCircleIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
      child: Icon(icon, color: const Color(0xFF3D4270), size: 22),
    );
  }
}