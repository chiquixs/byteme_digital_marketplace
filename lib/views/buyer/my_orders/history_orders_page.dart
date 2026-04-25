import 'package:flutter/material.dart';
import '../../../models/buyer/order_item.dart';

class HistoryOrdersPage extends StatefulWidget {
  const HistoryOrdersPage({super.key});

  @override
  State<HistoryOrdersPage> createState() => _HistoryOrdersPageState();
}

class _HistoryOrdersPageState extends State<HistoryOrdersPage> {
  List<OrderItem> orders = [
    OrderItem(id: 1, storeName: 'Official Store', productName: 'Girls E-Book', rating: 0),
    OrderItem(id: 2, storeName: 'Official Store', productName: 'Materials E-Book', reviewText: 'Very helpful!', rating: 5),
    OrderItem(id: 3, storeName: 'Official Store', productName: 'Personal Branding E-Book', reviewText: 'Good content', rating: 3),
    OrderItem(id: 4, storeName: 'Official Store', productName: 'Template Canva', rating: 0),
    OrderItem(id: 5, storeName: 'Official Store', productName: 'Project Proposal', rating: 0),
    OrderItem(id: 6, storeName: 'Official Store', productName: 'Web Design', reviewText: 'Nice design', rating: 3),
  ];

  // FUNGSI NOTIFIKASI
  void _showSuccessNotification() {
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.check_circle, 
                  color: Colors.green,
                  size: 70,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Thank You!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your review has been submitted.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D4270),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Close', style: TextStyle(color: Colors.white)),
                  ),
                )
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRatingDialog(OrderItem order) {
    int selectedStars = 0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( 
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
              title: const Text('Give Rating', style: TextStyle(fontWeight: FontWeight.bold)),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('How was your experience with ${order.productName}?', style: const TextStyle(fontSize: 13)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: () => setDialogState(() => selectedStars = index + 1),
                        icon: Icon(
                          index < selectedStars ? Icons.star_rounded : Icons.star_border_rounded,
                          color: index < selectedStars ? const Color(0xFFFFB800) : Colors.grey,
                          size: 32,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: reviewController,
                    decoration: InputDecoration(
                      hintText: 'Write your review here...',
                      hintStyle: const TextStyle(fontSize: 13),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D4270),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: selectedStars == 0 ? null : () {
                    _updateOrderRating(order.id, selectedStars, reviewController.text);
                    Navigator.pop(context); // Tutup dialog rating
                    _showSuccessNotification(); // Munculkan notifikasi sukses di tengah
                  },
                  child: const Text('Submit', style: TextStyle(color: Colors.white)),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _updateOrderRating(int id, int rating, String review) {
    setState(() {
      int index = orders.indexWhere((o) => o.id == id);
      if (index != -1) {
        orders[index] = orders[index].copyWith(rating: rating, reviewText: review);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<OrderItem> unratedOrders = orders.where((o) => o.rating == 0).toList();
    final List<OrderItem> ratedOrders = orders.where((o) => o.rating > 0).toList();

    return Scaffold(
      backgroundColor: const Color(0xFFE8E8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('My Orders', style: TextStyle(color: Color(0xFF2A2A2A), fontWeight: FontWeight.bold, fontSize: 18)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF2A2A2A), size: 20),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: orders.isEmpty
          ? const Center(child: Text('No orders yet'))
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (unratedOrders.isNotEmpty) ...[
                  const Text('Waiting for Rating', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...unratedOrders.map((order) => _OrderCard(
                        order: order,
                        onTap: () => _showRatingDialog(order), 
                      )),
                ],
                if (unratedOrders.isNotEmpty && ratedOrders.isNotEmpty)
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Divider(thickness: 1),
                  ),
                if (ratedOrders.isNotEmpty) ...[
                  const Text('Rated History', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  ...ratedOrders.map((order) => _OrderCard(order: order)),
                ],
              ],
            ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  final OrderItem order;
  final VoidCallback? onTap; 

  const _OrderCard({required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap, 
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12)),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 60, height: 60,
              decoration: BoxDecoration(color: const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(8)),
              child: const Icon(Icons.image_outlined, color: Color(0xFF8B90C1)),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(order.productName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  const SizedBox(height: 6),
                  _buildReviewContent(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReviewContent() {
    if (order.rating == 0) {
      return Row(
        children: const [
          Icon(Icons.star_border_rounded, size: 18, color: Colors.grey),
          SizedBox(width: 8),
          Text('Give Rating & Review', style: TextStyle(fontSize: 12, color: Color(0xFF8B90C1))),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) => Icon(
            i < order.rating ? Icons.star_rounded : Icons.star_border_rounded,
            size: 18, color: i < order.rating ? const Color(0xFFFFB800) : Colors.grey,
          )),
        ),
        if (order.reviewText != null)
          Text(order.reviewText!, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}