import 'package:flutter/material.dart';

class EarningsPage extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const EarningsPage({super.key, this.onBackPressed});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  // Controller untuk menangkap inputan user
  final TextEditingController _amountController = TextEditingController();

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Fungsi untuk memunculkan pop-up sukses
  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false, // User gak bisa asal klik luar buat tutup
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.cached_rounded, color: Color(0xFF6B7FD7), size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Withdraw Processed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3D4270)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your withdrawal is being processed. Please wait 1–2 business days!',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context); 
                      _amountController.clear(); 
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6B7FD7),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text('Got it', style: TextStyle(color: Colors.white)),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3D4270);
    const Color accentColor = Color(0xFF6B7FD7);

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              // --- HEADER ---
              Row(
                children: [
                  _buildCircleBackButton(context),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Withdraw',
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 40), 
                ],
              ),
              const SizedBox(height: 25),

              // --- BALANCE CARD ---
              _buildBalanceCard(accentColor),
              const SizedBox(height: 25),

              // --- INPUT AMOUNT ---
              const Text('Withdraw Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor)),
              const SizedBox(height: 12),
              _buildAmountInput(),
              const SizedBox(height: 8),
              const Text('Minimum withdraw amount 10.000', style: TextStyle(color: Colors.grey, fontSize: 11)),
              const SizedBox(height: 20),

              // --- AUTOMATIC NOTICE ---
              _buildNoticeBox(accentColor),
              const SizedBox(height: 25),

              // --- SUMMARY CARD ---
              _buildSummaryCard(primaryColor),
              const SizedBox(height: 30),

              // --- CONFIRM BUTTON ---
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: () {
                    if (_amountController.text.isNotEmpty) {
                      _showProcessingDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Please enter the amount first!'))
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: accentColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    elevation: 0,
                  ),
                  child: const Text('Confirm Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ),
              const SizedBox(height: 30),

              // --- RECENT HISTORY ---
              const Text('Recent History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor)),
              const SizedBox(height: 12),
              _buildSimpleHistory(), 
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // --- WIDGET HELPERS ---

  Widget _buildCircleBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF3D4270), size: 20),
        onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBalanceCard(Color color) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [BoxShadow(color: color.withOpacity(0.2), blurRadius: 15, offset: const Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Balance', style: TextStyle(color: Colors.white70, fontSize: 13)),
          const Text('Rp. 120.000', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 15),
          const Text('Total Earnings', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const Text('RP. 1.000.000', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)],
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF3D4270)),
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.all(15),
            child: Text('RP.', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB0B8CC))),
          ),
          hintText: '0',
          hintStyle: const TextStyle(color: Color(0xFFD0D5E8)),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildNoticeBox(Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'withdraw will be sent automatically to your registred bank account',
              style: TextStyle(fontSize: 11, color: Color(0xFF3D4270)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(Color primary) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('You Will Receive', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(height: 25),
          const Text('Bank Account', style: TextStyle(color: Colors.grey, fontSize: 11)),
          const Text('BCA - Bank Central Asia', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3D4270))),
          const Text('1234 5678 9012', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(height: 25),
          const Text('Processing Time', style: TextStyle(color: Colors.grey, fontSize: 11)),
          const Text('1 - 2 Business Days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3D4270))),
        ],
      ),
    );
  }

  Widget _buildSimpleHistory() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
      child: const ListTile(
        leading: CircleAvatar(backgroundColor: Color(0xFFF0F2F8), child: Icon(Icons.outbound, color: Colors.redAccent, size: 20)),
        title: Text('Withdrawal', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text('24 Apr 2026', style: TextStyle(fontSize: 11)),
        trailing: Text('-Rp 100.000', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
      ),
    );
  }
}