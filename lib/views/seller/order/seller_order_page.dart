import 'package:flutter/material.dart';

class SellerOrderPage extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const SellerOrderPage({super.key, this.onBackPressed});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  // 1. DATA DARI BUYER (Backend Ready) - Status selalu Active
  final List<Map<String, dynamic>> _incomingOrders = [
    {
      'id': 'ORD-001',
      'productName': 'Mobile App UI Kit',
      'buyerName': 'Mery',
      'date': '12 Maret 2026',
      'price': '50.000',
      'total': '50.000',
      'status': 'Active',
    },
    {
      'id': 'ORD-002',
      'productName': 'E-Book Flutter Pro',
      'buyerName': 'Lovie',
      'date': '14 Maret 2026',
      'price': '75.000',
      'total': '75.000',
      'status': 'Active',
    },
    {
      'id': 'ORD-003',
      'productName': 'Dashboard UI Kit',
      'buyerName': 'Oktavia',
      'date': '15 Maret 2026',
      'price': '60.000',
      'total': '60.000',
      'status': 'Active',
    },
  ];

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF6B7FD7);
    const Color backgroundColor = Color(0xFFF0F2F8);

    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            // --- HEADER SECTION ---
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCircleBackButton(context),
                    const SizedBox(height: 20),
                    const Text(
                      'My Order',
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Color(0xFF1A1D2E)),
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
            ),

            // --- ORDER LIST ---
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final order = _incomingOrders[index];
                    return _buildOrderCard(order, primaryColor);
                  },
                  childCount: _incomingOrders.length,
                ),
              ),
            ),
          ],
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

  Widget _buildOrderCard(Map<String, dynamic> order, Color primaryColor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail Produk
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.image_outlined, color: primaryColor, size: 30),
          ),
          const SizedBox(width: 15),
          
          // Detail Order
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(order['productName'], style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                    // Badge Status
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8F5E9),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Active',
                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.green),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                
                // --- INFO 2 BARIS (KANAN KIRI) ---
                // Baris 1: Pembeli & Tanggal
                Row(
                  children: [
                    Expanded(child: _buildOrderInfoText('Pembeli', order['buyerName'])),
                    Expanded(child: _buildOrderInfoText('Tanggal', order['date'])),
                  ],
                ),
                const SizedBox(height: 6),
                // Baris 2: Harga & Total
                Row(
                  children: [
                    Expanded(child: _buildOrderInfoText('Harga', 'Rp ${order['price']}')),
                    Expanded(child: _buildOrderInfoText('Total', 'Rp ${order['total']}')),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderInfoText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 9, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(fontSize: 11, color: Color(0xFF1A1D2E), fontWeight: FontWeight.w600),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}