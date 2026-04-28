import 'package:flutter/material.dart';

class SellerProductPage extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const SellerProductPage({super.key, this.onBackPressed});

  @override
  State<SellerProductPage> createState() => _SellerProductPageState();
}

class _SellerProductPageState extends State<SellerProductPage> {
  int _selectedTab = 0; // 0: All, 1: Active, 2: Inactive

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6B7FD7);
    const Color backgroundColor = Color(0xFFF0F2F8);
    const Color textDark = Color(0xFF1A1D2E);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // --- HEADER ---
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCircleBackButton(context),
                  const SizedBox(height: 20),
                  const Text(
                    'My Products',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: textDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                  
                  // --- SEARCH & FILTER ICON ---
                  Row(
                    children: [
                      Expanded(child: _buildSearchBar()),
                      const SizedBox(width: 12),
                      _buildFilterIcon(primaryColor),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // --- TAB SEGMENTED ---
                  _buildTabSegmented(primaryColor),
                ],
              ),
            ),

            // --- PRODUCT LIST ---
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(20),
                children: [
                  _buildProductCard(
                    title: 'Mobile App UI Kit',
                    price: '\$29',
                    sales: '1.2k sales',
                    rating: 4.8,
                    status: 'Active',
                    primaryColor: primaryColor,
                  ),
                  _buildProductCard(
                    title: 'Lightroom Presets Bundle',
                    price: '\$15',
                    sales: '980 sales',
                    rating: 4.7,
                    status: 'Active',
                    primaryColor: primaryColor,
                  ),
                  _buildProductCard(
                    title: 'Dashboard UI Kit',
                    price: '\$19',
                    sales: '620 sales',
                    rating: 4.6,
                    status: 'Active',
                    primaryColor: primaryColor,
                  ),
                  _buildProductCard(
                    title: 'Icon Pack - Minimal',
                    price: '\$9',
                    sales: '430 sales',
                    rating: 4.5,
                    status: 'Inactive',
                    primaryColor: primaryColor,
                  ),
                  const SizedBox(height: 80), // Space for button
                ],
              ),
            ),
          ],
        ),
      ),
      
      // --- ADD NEW PRODUCT BUTTON ---
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SizedBox(
          width: double.infinity,
          height: 55,
          child: ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              elevation: 0,
            ),
            child: const Text(
              '+ Add New Product',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ),
      ),
    );
  }

  // --- WIDGET COMPONENTS ---

  Widget _buildCircleBackButton(BuildContext context) {
    return GestureDetector(
      onTap: widget.onBackPressed ?? () => Navigator.pop(context),
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
        ),
        child: const Icon(Icons.arrow_back, color: Colors.black, size: 22),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      height: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const TextField(
        decoration: InputDecoration(
          hintText: 'Search product',
          hintStyle: TextStyle(color: Color(0xFFB0B8CC), fontSize: 14),
          prefixIcon: Icon(Icons.search, color: Color(0xFFB0B8CC)),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(vertical: 15),
        ),
      ),
    );
  }

  Widget _buildFilterIcon(Color color) {
    return Container(
      height: 50,
      width: 50,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Icon(Icons.tune_rounded, color: color),
    );
  }

  Widget _buildTabSegmented(Color primary) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          _buildTabItem(0, 'All Products', primary),
          _buildTabItem(1, 'Active', primary),
          _buildTabItem(2, 'Inactive', primary),
        ],
      ),
    );
  }

  Widget _buildTabItem(int index, String label, Color primary) {
    bool isSelected = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () => setState(() => _selectedTab = index),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isSelected ? primary : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: isSelected ? Colors.white : Colors.grey,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProductCard({
    required String title,
    required String price,
    required String sales,
    required double rating,
    required String status,
    required Color primaryColor,
  }) {
    bool isActive = status == 'Active';
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          // Thumbnail
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Icon(Icons.image_outlined, color: primaryColor, size: 30),
          ),
          const SizedBox(width: 15),
          // Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                    const Icon(Icons.more_horiz, color: Color(0xFF6B7FD7)),
                  ],
                ),
                const SizedBox(height: 4),
                Text('$price  •  $sales', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: Colors.amber, size: 14),
                    const SizedBox(width: 4),
                    Text('$rating', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                    const SizedBox(width: 4),
                    Row(
                      children: List.generate(5, (index) => Icon(
                        Icons.star, 
                        size: 12, 
                        color: index < rating.floor() ? Colors.amber : Colors.grey.shade300
                      )),
                    ),
                    const Spacer(),
                    // Status Badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: isActive ? const Color(0xFFE8F5E9) : const Color(0xFFEEEEEE),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        status,
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isActive ? Colors.green : Colors.grey.shade600,
                        ),
                      ),
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
}