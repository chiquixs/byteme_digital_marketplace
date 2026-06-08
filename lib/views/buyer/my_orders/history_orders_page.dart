import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../models/buyer/order_item.dart';
import '../../../controller/buyer/order_controller.dart';

class HistoryOrdersPage extends StatefulWidget {
  const HistoryOrdersPage({super.key});

  @override
  State<HistoryOrdersPage> createState() => _HistoryOrdersPageState();
}

class _HistoryOrdersPageState extends State<HistoryOrdersPage> {
  bool _isSubmitting = false; // State loading saat kirim ulasan

  @override
  void initState() {
    super.initState();
    // Fetch orders otomatis saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderController>().fetchHistoryOrders();
    });
  }

  // ── FUNGSI REFRESH DATA ──
  Future<void> _handleRefresh() async {
    await context.read<OrderController>().fetchHistoryOrders();
  }

  // ── FUNGSI NOTIFIKASI SUKSES (Popup di tengah) ──
  void _showSuccessNotification() {
    showDialog(
      context: context,
      barrierDismissible: false, // Wajib tekan tombol Got It
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 70),
                const SizedBox(height: 20),
                const Text(
                  'Thank You!',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3D4270)),
                ),
                const SizedBox(height: 10),
                const Text(
                  'Your review has been submitted successfully.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 13),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D4270),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      _handleRefresh(); // Refresh data agar status berubah jadi Rated History
                    },
                    child: const Text(
                      'Got it!',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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

  // ── DIALOG INPUT RATING & REVIEW ──
  void _showRatingDialog(OrderItem order) {
    int selectedStars = 0;
    final TextEditingController reviewController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: !_isSubmitting, // Gak bisa ditutup sembarangan pas loading submit
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              title: const Text(
                'Give Rating',
                style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3D4270)),
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'How was your experience with ${order.productName}?',
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  // Bintang Interaktif
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        onPressed: _isSubmitting 
                            ? null 
                            : () => setDialogState(() => selectedStars = index + 1),
                        icon: Icon(
                          index < selectedStars
                              ? Icons.star_rounded
                              : Icons.star_border_rounded,
                          color: index < selectedStars
                              ? const Color(0xFFFFB800)
                              : Colors.grey.shade400,
                          size: 36,
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  // Input Teks Ulasan
                  TextField(
                    controller: reviewController,
                    enabled: !_isSubmitting,
                    decoration: InputDecoration(
                      hintText: 'Write your review here...',
                      hintStyle: const TextStyle(fontSize: 13, color: Colors.grey),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFF6B7FD7)),
                      ),
                    ),
                    maxLines: 3,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: _isSubmitting ? null : () => Navigator.pop(context),
                  child: const Text(
                    'Cancel',
                    style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
                  ),
                ),
                // ✅ TOMBOL SUBMIT SEKARANG FIX TERHUBUNG AMAN KE BACKEND
                SizedBox(
                  height: 40,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF3D4270),
                      disabledBackgroundColor: Colors.grey.shade300,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: (selectedStars == 0 || _isSubmitting)
                        ? null
                        : () async {
                            setDialogState(() => _isSubmitting = true);
                            
                            try {
                              // Mengirimkan data ulasan ke backend Angga lewat rute Controller
                              await context.read<OrderController>().submitRating(
                                    order.id, 
                                    selectedStars,
                                    reviewController.text,
                                  );
                              
                              if (!mounted) return;
                              setDialogState(() => _isSubmitting = false);
                              
                              Navigator.pop(context); // Tutup dialog input ulasan
                              _showSuccessNotification(); // Munculkan popup terima kasih
                            } catch (e) {
                              if (!mounted) return;
                              setDialogState(() => _isSubmitting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Failed to submit review. Try again.')),
                              );
                            }
                          },
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 20, 
                            height: 20, 
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text(
                            'Submit',
                            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<OrderController>(
      builder: (context, orderController, child) {
        final orders = orderController.historyOrders;

        // Memisahkan data ulasan (logika rating null atau 0)
        final List<OrderItem> unratedOrders = orders
            .where((o) => o.rating == null || o.rating == 0)
            .toList();
        final List<OrderItem> ratedOrders = orders
            .where((o) => o.rating != null && o.rating! > 0)
            .toList();

        return Scaffold(
          backgroundColor: const Color(0xFFF0F2F8),
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
            title: const Text(
              'My Orders History',
              style: TextStyle(color: Color(0xFF3D4270), fontWeight: FontWeight.bold, fontSize: 16),
            ),
            leading: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Container(
                decoration: BoxDecoration(color: const Color(0xFFF0F2F8), borderRadius: BorderRadius.circular(10)),
                child: IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Color(0xFF3D4270), size: 16),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ),
          ),
          // Pull-to-Refresh data dari API
          body: RefreshIndicator(
            onRefresh: _handleRefresh,
            color: const Color(0xFF6B7FD7),
            child: orders.isEmpty
                ? _buildEmptyState()
                : ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    children: [
                      // --- SEKSI WAITING FOR RATING ---
                      if (unratedOrders.isNotEmpty) ...[
                        const Text(
                          'Waiting for Rating', 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3D4270)),
                        ),
                        const SizedBox(height: 12),
                        ...unratedOrders.map(
                          (order) => _OrderCard(
                            order: order,
                            onTap: () => _showRatingDialog(order),
                          ),
                        ),
                      ],
                      
                      if (unratedOrders.isNotEmpty && ratedOrders.isNotEmpty)
                        const Padding(
                          padding: EdgeInsets.symmetric(vertical: 16), 
                          child: Divider(thickness: 1, color: Colors.white),
                        ),
                      
                      // --- SEKSI RATED HISTORY ---
                      if (ratedOrders.isNotEmpty) ...[
                        const Text(
                          'Rated History', 
                          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Color(0xFF3D4270)),
                        ),
                        const SizedBox(height: 12),
                        ...ratedOrders.map((order) => _OrderCard(order: order)),
                      ],
                    ],
                  ),
          ),
        );
      },
    );
  }

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      children: [
        SizedBox(height: MediaQuery.of(context).size.height * 0.3),
        const Center(
          child: Column(
            children: [
              Icon(Icons.receipt_long_rounded, size: 60, color: Colors.grey),
              SizedBox(height: 16),
              Text('No orders history yet', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
              SizedBox(height: 8),
              Text('Pull down to refresh data', style: TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ),
      ],
    );
  }
}

// ── CUSTOM WIDGET CARD ORDER ──
class _OrderCard extends StatelessWidget {
  final OrderItem order;
  final VoidCallback? onTap;

  const _OrderCard({required this.order, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10, offset: const Offset(0, 4)),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ✅ FIX IMAGES: Thumbnail Gambar Produk mengambil URL asli Supabase
          Container(
            width: 65,
            height: 65,
            decoration: BoxDecoration(
              color: const Color(0xFFF0F2F8),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: order.imagePath.isNotEmpty && order.imagePath.startsWith('http')
                  ? Image.network(
                      order.imagePath,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => 
                          const Icon(Icons.image_not_supported_outlined, color: Color(0xFF8B90C1), size: 28),
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF6B7FD7)),
                        );
                      },
                    )
                  : const Icon(Icons.shopping_bag_outlined, color: Color(0xFF8B90C1), size: 28),
            ),
          ),
          const SizedBox(width: 14),
          
          // Informasi Konten Utama
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  order.productName,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3D4270)),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                _buildReviewContent(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewContent(BuildContext context) {
    // JIKA BELUM DIBERI RATING
    if (order.rating == null || order.rating == 0) {
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Expanded(
            child: Text(
              'Give Rating & Review',
              style: TextStyle(fontSize: 12, color: Color(0xFF8B90C1), fontWeight: FontWeight.w500),
            ),
          ),
          SizedBox(
            height: 32,
            child: ElevatedButton(
              onPressed: onTap,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B7FD7),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                padding: const EdgeInsets.symmetric(horizontal: 12),
              ),
              child: const Text(
                'Tulis Ulasan',
                style: TextStyle(fontSize: 11, color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }
    
    // JIKA SUDAH PERNAH DIBERI RATING (Tampilkan Bintang)
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(
            5,
            (i) => Icon(
              i < (order.rating ?? 0)
                  ? Icons.star_rounded
                  : Icons.star_border_rounded,
              size: 18,
              color: i < (order.rating ?? 0)
                  ? const Color(0xFFFFB800)
                  : Colors.grey.shade300,
            ),
          ),
        ),
        if (order.reviewText != null && order.reviewText!.isNotEmpty) ...[
          const SizedBox(height: 4),
          Text(
            order.reviewText!,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600, fontStyle: FontStyle.italic),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }
}