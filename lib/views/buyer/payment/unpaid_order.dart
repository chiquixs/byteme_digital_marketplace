import 'dart:async';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UnpaidOrderPage extends StatefulWidget {
  final List<Map<String, dynamic>> items;
  final int totalAmount;

  const UnpaidOrderPage({super.key, required this.items, required this.totalAmount});

  @override
  State<UnpaidOrderPage> createState() => _UnpaidOrderPageState();
}

class _UnpaidOrderPageState extends State<UnpaidOrderPage> {
  late DateTime deadline;
  late Duration remainingTime = const Duration(hours: 24);
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    // Set deadline: 24 hours from now for simulation
    deadline = DateTime.now().add(const Duration(hours: 24));
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      setState(() {
        remainingTime = deadline.difference(now);
      });

      if (remainingTime.isNegative) {
        _timer?.cancel();
        _showExpiredDialog();
      }
    });
  }

  void _showExpiredDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Time\'s Up!', style: TextStyle(fontWeight: FontWeight.bold)),
        content: const Text(
          'Sorry, your order has been automatically cancelled because the payment deadline has passed.',
          style: TextStyle(fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst),
            child: const Text('Return to Home', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF3D4270))),
          ),
        ],
      ),
    );
  }

  // --- FORMAT JAM (HH:mm:ss) ---
  String _formatDuration(Duration duration) {
    if (duration.isNegative) return "00:00:00";
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    
    return "$hours:$minutes:$seconds";
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8F0),
      appBar: AppBar(
        title: const Text(
          'Waiting for Payment', 
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        foregroundColor: Colors.black,
      ),
      body: Column(
        children: [
          // Banner Timer
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: const Color(0xFF3D4270),
            child: Column(
              children: [
                const Text(
                  'Please complete your payment within', 
                  style: TextStyle(color: Colors.white70, fontSize: 13)
                ),
                const SizedBox(height: 8),
                Text(
                  _formatDuration(remainingTime),
                  style: const TextStyle(
                    color: Colors.white, 
                    fontSize: 36, 
                    fontWeight: FontWeight.bold,
                    letterSpacing: 2,
                  ),
                ),
              ],
            ),
          ),
          
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: widget.items.length,
              itemBuilder: (context, index) {
                final item = widget.items[index];
                return Card(
                  elevation: 0,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFE8E8F0),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(Icons.shopping_bag_outlined, color: Color(0xFF3D4270)),
                    ),
                    title: Text(
                      item['name'], 
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)
                    ),
                    subtitle: Text(
                      item['price'], 
                      style: const TextStyle(color: Color(0xFF5A72C6), fontWeight: FontWeight.w600)
                    ),
                  ),
                );
              },
            ),
          ),
          
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),
              boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
            ),
            child: SafeArea(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Total Amount', 
                        style: TextStyle(color: Colors.grey, fontSize: 12)
                      ),
                      const SizedBox(height: 4),
                      Text(
                        NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ').format(widget.totalAmount),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold, 
                          fontSize: 20,
                          color: Color(0xFF3D4270),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF3D4270),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        elevation: 0,
                      ),
                      onPressed: () {
                        _timer?.cancel();
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Payment Successful!'),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          )
                        );
                      },
                      child: const Text(
                        'I Have Paid', 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}