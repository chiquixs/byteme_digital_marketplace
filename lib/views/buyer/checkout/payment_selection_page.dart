import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PaymentSelectionPage extends StatelessWidget {
  final int totalAmount;

  const PaymentSelectionPage({super.key, required this.totalAmount});

  // Format ke Rupiah
  String _formatCurrency(int number) {
    return NumberFormat.currency(locale: 'id_ID', symbol: 'Rp ', decimalDigits: 0).format(number);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8E8F0),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Select Payment',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // --- SECTION 1: VIRTUAL ACCOUNT ---
            _buildGroup(
              title: 'Virtual Account',
              icon: Icons.account_balance_wallet_outlined,
              items: [
                _buildBankItem(context, 'Mandiri Virtual Account', Icons.account_balance),
                _buildBankItem(context, 'BCA Virtual Account', Icons.account_balance),
                _buildBankItem(context, 'BRI Virtual Account', Icons.account_balance),
                _buildBankItem(context, 'BNI Virtual Account', Icons.account_balance, isLast: true),
              ],
            ),
            
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'OR',
                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 2),
              ),
            ),

            // --- SECTION 2: QRIS ---
            _buildGroup(
              title: 'QRIS',
              icon: Icons.qr_code_scanner_rounded,
              items: [
                _buildBankItem(context, 'QRIS', Icons.qr_code_2_rounded, isLast: true),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGroup({required String title, required IconData icon, required List<Widget> items}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Column(
        children: [
          ListTile(
            leading: Icon(icon, color: const Color(0xFF3D4270)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
          ),
          const Divider(height: 1),
          ...items,
        ],
      ),
    );
  }

  Widget _buildBankItem(BuildContext context, String name, IconData icon, {bool isLast = false}) {
    return Column(
      children: [
        ListTile(
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: const Color(0xFFE8E8F0), borderRadius: BorderRadius.circular(8)),
            child: Icon(icon, color: const Color(0xFF3D4270), size: 20),
          ),
          title: Text(name, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          trailing: const Icon(Icons.chevron_right, size: 20, color: Colors.grey),
          onTap: () {
            // Jalankan simulasi instruksi sebelum balik ke checkout
            _showPaymentInstruction(context, name);
          },
        ),
        if (!isLast) const Divider(height: 1, indent: 60),
      ],
    );
  }

  // --- FUNGSI SIMULASI INSTRUKSI PEMBAYARAN ---
  void _showPaymentInstruction(BuildContext context, String bankName) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10))),
              const SizedBox(height: 20),
              Text('Pay using $bankName', style: const TextStyle(fontSize: 14, color: Colors.grey)),
              const SizedBox(height: 12),
              const Text(
                '8801 2441 0706 0018', // Nomor VA simulasi (pakai NIM kamu biar keren)
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, letterSpacing: 2, color: Color(0xFF3D4270)),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: const Color(0xFFF5F6FA), borderRadius: BorderRadius.circular(12)),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Total Payment:', style: TextStyle(fontWeight: FontWeight.w500)),
                    Text(_formatCurrency(totalAmount), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Color(0xFF5A72C6))),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              const Align(
                alignment: Alignment.centerLeft,
                child: Text('Payment Instructions:', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
              const SizedBox(height: 8),
              _instructionStep('1', 'Open your banking app and select Transfer.'),
              _instructionStep('2', 'Choose Virtual Account and enter the number above.'),
              _instructionStep('3', 'Ensure the amount matches and click Confirm.'),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF3D4270),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    // Tutup Bottom Sheet
                    Navigator.pop(context);
                    // Kembalikan nama bank ke halaman Checkout
                    Navigator.pop(context, bankName);
                  },
                  child: const Text('Confirm & I have Paid', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _instructionStep(String num, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('$num. ', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: Colors.black87))),
        ],
      ),
    );
  }
}