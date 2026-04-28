import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../produk/product_page.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';

class SellerHomePage extends StatelessWidget {
  const SellerHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final userController = Provider.of<UserController>(context);
    const Color accentColor = Color(0xFF3D4270);
    const Color primaryBlue = Color(0xFF6B7FD7);

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8F0),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- HEADER ---
              Row(
                children: [
                  // DEFAULT PROFILE PICTURE
                  CircleAvatar(
                    radius: 28,
                    backgroundColor: accentColor.withOpacity(0.2),
                    child: const Icon(Icons.person, color: accentColor, size: 30),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // SUDAH DIHAPUS EMOTICON-NYA
                      const Text('Welcome back,', style: TextStyle(color: Colors.grey, fontSize: 12)),
                      Text(
                        userController.displayName.isEmpty ? userController.username : userController.displayName, 
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
                      ),
                    ],
                  ),
                  const Spacer(),
                  _buildIconButton(Icons.notifications_outlined),
                ],
              ),
              const SizedBox(height: 24),

              const Text('Vendor Homepage', style: TextStyle(color: accentColor, fontWeight: FontWeight.bold, fontSize: 18)),
              const SizedBox(height: 16),

              // --- BALANCE CARD ---
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF6B7FD7), Color(0xFF8B90C1)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF6B7FD7).withOpacity(0.3),
                      blurRadius: 15,
                      offset: const Offset(0, 8)
                    )
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Balance', style: TextStyle(color: Colors.white70, fontSize: 14)),
                        Icon(Icons.visibility_outlined, color: Colors.white.withOpacity(0.5), size: 20),
                      ],
                    ),
                    const Text('\$1,250.80', style: TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: const [
                            Text('Available for Withdraw', style: TextStyle(color: Colors.white70, fontSize: 12)),
                            Text('\$1,120.40', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                          ],
                        ),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: accentColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            elevation: 0,
                          ),
                          child: const Text('Withdraw', style: TextStyle(fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),

              // --- STATS ---
              Row(
                children: [
                  _buildStatCard('Total Sales', '39', Icons.shopping_bag_outlined),
                  const SizedBox(width: 16),
                  _buildStatCard('Total Product', '12', Icons.inventory_2_outlined),
                ],
              ),
              const SizedBox(height: 24),

              // --- PRODUCT SECTION ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Discover Product', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  TextButton(onPressed: () {}, child: const Text('more >', style: TextStyle(color: Color(0xFF6B7FD7)))),
                ],
              ),
              SizedBox(
                height: 160,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    _buildProductItem('E-Book Material', 'Rp 59.000', Colors.blue.shade100),
                    _buildProductItem('Girls E-Book', 'Rp 78.000', Colors.pink.shade50),
                    _buildProductItem('Course Module', 'Rp 120.000', Colors.green.shade50),
                    _buildProductItem('Digital Asset', 'Rp 45.000', Colors.orange.shade50),
                    _buildProductItem('UI Kit Pro', 'Rp 250.000', Colors.purple.shade50),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      
      // --- BOTTOM NAVIGATION BAR SESUAI FIGMA ---
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
          child: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.white,
            selectedItemColor: primaryBlue,
            unselectedItemColor: Colors.grey.shade400,
            selectedFontSize: 12,
            unselectedFontSize: 12,
            currentIndex: 0,
              onTap: (index) {
                if (index == 1) {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (_) => const SellerProductPage()),
                  );
                }
              },
              items: const [
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.home_rounded, size: 28),
                ),
                label: 'Dashboard',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.grid_view_rounded, size: 26),
                ),
                label: 'Product',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.shopping_bag_outlined, size: 26),
                ),
                label: 'My Order',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.ios_share_rounded, size: 26),
                ),
                label: 'Earnings',
              ),
              BottomNavigationBarItem(
                icon: Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(Icons.person_rounded, size: 28),
                ),
                label: 'Profile',
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIconButton(IconData icon) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
      child: Icon(icon, color: const Color(0xFF3D4270), size: 24),
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
                Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
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

  Widget _buildProductItem(String name, String price, Color color) {
    return Container(
      width: 150,
      margin: const EdgeInsets.only(right: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 90, 
            decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(12)),
            child: const Center(child: Icon(Icons.description_outlined, color: Colors.white)),
          ),
          const SizedBox(height: 8),
          Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), maxLines: 1, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 2),
          Text(price, style: const TextStyle(color: Color(0xFF6B7FD7), fontSize: 12, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}