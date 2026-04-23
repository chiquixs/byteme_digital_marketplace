import 'package:flutter/material.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Data model
// ─────────────────────────────────────────────────────────────────────────────
class OrderItem {
  final String storeName;
  final String productName;
  final String? reviewText;   
  final int rating;           
  final String imagePath;     

  const OrderItem({
    required this.storeName,
    required this.productName,
    this.reviewText,
    required this.rating,
    this.imagePath = '',
  });
}

// ─────────────────────────────────────────────────────────────────────────────
// Page
// ─────────────────────────────────────────────────────────────────────────────
class HistoryOrdersPage extends StatelessWidget {
  const HistoryOrdersPage({super.key});

  // Dummy data
  static const List<OrderItem> _orders = [
    OrderItem(
      storeName: 'Official Store',
      productName: 'Girls  E-Book',
      rating: 0,
      imagePath: '',
    ),
    OrderItem(
      storeName: 'Official Store',
      productName: 'Materials E-Book',
      reviewText: 'Terima kasih atas penilaianmu',
      rating: 5,
      imagePath: '',
    ),
    OrderItem(
      storeName: 'Official Store',
      productName: 'Personal Branding E-Book',
      reviewText: 'Terima kasih atas penilaianmu',
      rating: 3,
      imagePath: '',
    ),
    OrderItem(
      storeName: 'Official Store',
      productName: 'Template Canva',
      rating: 0,
      imagePath: '',
    ),
    OrderItem(
      storeName: 'Official Store',
      productName: 'Project Proposal',
      rating: 0,
      imagePath: '',
    ),
    OrderItem(
      storeName: 'Official Store',
      productName: 'Web Design',
      reviewText: 'Terima kasih atas penilaianmu',
      rating: 3,
      imagePath: '',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final List<OrderItem> unratedOrders = _orders.where((o) => o.rating == 0).toList();
    final List<OrderItem> ratedOrders = _orders.where((o) => o.rating > 0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8F0),
      appBar: _buildAppBar(context),
      body: _orders.isEmpty
          ? _buildEmpty()
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                
                // --- BAGIAN 1: MENUNGGU PENILAIAN ---
                if (unratedOrders.isNotEmpty) ...[
                  const Padding(
                    padding: EdgeInsets.only(bottom: 12, left: 4),
                    child: Text(
                      'Menunggu Penilaian',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2A2A2A), // Warna teks menyesuaikan temamu
                      ),
                    ),
                  ),
                  // Tampilkan card untuk setiap item yang belum dinilai
                  ...unratedOrders.map((order) => _OrderCard(order: order)),
                ],

                // --- BAGIAN 2: GARIS PEMISAH --
                if (unratedOrders.isNotEmpty && ratedOrders.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 24),
                    child: Row(
                      children: [
                        Expanded(child: Divider(color: Color(0xFFD0D0E0), thickness: 1)),
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 12),
                          child: Text(
                            'Selesai Dinilai',
                            style: TextStyle(
                              color: Color(0xFF8B90C1),
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        Expanded(child: Divider(color: Color(0xFFD0D0E0), thickness: 1)),
                      ],
                    ),
                  ),

                // --- BAGIAN 3: RIWAYAT / SUDAH DINILAI ---
                if (ratedOrders.isNotEmpty) ...[
                  if (unratedOrders.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 12, left: 4),
                      child: Text(
                        'Riwayat Penilaian',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                    ),
                  
                  ...ratedOrders.map((order) => _OrderCard(order: order)),
                ],
                
              ],
            ),
    );
  }
  PreferredSizeWidget _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
      leading: Container(
          margin: const EdgeInsets.all(8.0),
          decoration: BoxDecoration(
            color: Color(0xFFE8E8F0),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded,
              color: Color(0xFF2A2A2A), size: 20),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      title: const Text(
        'My Orders',
        style: TextStyle(
          color: Color(0xFF2A2A2A),
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return const Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.receipt_long_outlined,
              size: 64, color: Color(0xFF8B90C1)),
          SizedBox(height: 12),
          Text(
            'Belum ada pesanan',
            style: TextStyle(
              fontSize: 15,
              color: Color(0xFF8B90C1),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Order card widget
// ─────────────────────────────────────────────────────────────────────────────
class _OrderCard extends StatelessWidget {
  final OrderItem order;
  const _OrderCard({required this.order});

  static const Color _accent = Color(0xFF3D4270);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 1),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Store label row
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined,
                    size: 16, color: _accent),
                const SizedBox(width: 6),
                Text(
                  order.storeName,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _accent,
                  ),
                ),
              ],
            ),
          ),

          const Divider(height: 1, thickness: 0.5, color: Color(0xFFE0E0E0)),

          // Product row
          Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Thumbnail
                _buildThumbnail(),
                const SizedBox(width: 12),

                // Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.productName,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF2A2A2A),
                        ),
                      ),
                      const SizedBox(height: 6),
                      _buildReviewRow(),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThumbnail() {
    if (order.imagePath.isNotEmpty) {
      return ClipRRect(
        borderRadius: BorderRadius.circular(6),
        child: order.imagePath.startsWith('http')
            ? Image.network(
                order.imagePath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderBox(),
              )
            : Image.asset(
                order.imagePath,
                width: 72,
                height: 72,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _placeholderBox(),
              ),
      );
    }
    return _placeholderBox();
  }

  Widget _placeholderBox() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        color: const Color(0xFFE8E8F0),
        borderRadius: BorderRadius.circular(6),
      ),
      child: const Icon(Icons.image_outlined,
          color: Color(0xFF8B90C1), size: 28),
    );
  }

  Widget _buildReviewRow() {
    final bool hasRating = order.rating > 0;

    if (!hasRating) {
      // Belum dirating
      return Row(
        children: [
          ...List.generate(
            5,
            (_) => const Icon(Icons.star_border_rounded,
                size: 18, color: Color(0xFFB0B0C8)),
          ),
          const SizedBox(width: 8),
          const Text(
            'Beri Penilaian & Rating',
            style: TextStyle(fontSize: 12, color: Color(0xFF8B90C1)),
          ),
        ],
      );
    }

    // Sudah dirating
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) {
            return Icon(
              i < order.rating
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              size: 18,
              color: i < order.rating
                  ? const Color(0xFFFFB800)
                  : const Color(0xFFB0B0C8),
            );
          }),
        ),
        if (order.reviewText != null) ...[
          const SizedBox(height: 4),
          Text(
            order.reviewText!,
            style: const TextStyle(
              fontSize: 12,
              color: Color(0xFF8B90C1),
            ),
          ),
        ],
      ],
    );
  }
}