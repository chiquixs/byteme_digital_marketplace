import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Untuk TextInputFormatter titik otomatis
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/services/api_service.dart';

class EarningsPage extends StatefulWidget {
  final VoidCallback? onBackPressed;

  const EarningsPage({super.key, this.onBackPressed});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final TextEditingController _amountController = TextEditingController();
  bool _isLoadingHistory = true;
  bool _isSubmitting = false;
  List<dynamic> _withdrawHistory = [];

  @override
  void initState() {
    super.initState();
    _fetchWithdrawHistory();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // ── 1. AMBIL DATA RIWAYAT DARI API INDEX LARAVEL ──
  Future<void> _fetchWithdrawHistory() async {
    if (!mounted) return;
    setState(() => _isLoadingHistory = true);
    
    try {
      final response = await ApiService.get('/withdraws');
      
      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        setState(() {
          _withdrawHistory = decoded is List ? decoded : [];
        });
      }
    } catch (e) {
      debugPrint('Error fetch history: $e');
    } finally {
      if (mounted) setState(() => _isLoadingHistory = false);
    }
  }

  // ── 2. KIRIM REQUEST WITHDRAW BARU ──
  Future<void> _submitWithdraw(double amount, String username) async {
    setState(() => _isSubmitting = true);
    try {
      final response = await ApiService.postAuth(
        '/withdraws', 
        {
          'amount': amount,
          'bank_name': 'BCA - Bank Central Asia',
          'bank_account_number': '123456789012',
          'bank_account_name': username, 
        },
      );

      if (!mounted) return;
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final double newBalance = (decoded['balance'] as num).toDouble();
        Provider.of<UserController>(context, listen: false).updateBalance(newBalance);
        
        _showProcessingDialog();
        _fetchWithdrawHistory(); 
      } else {
        String errMsg = decoded['message'] ?? 'Failed to process withdrawal';
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(errMsg)));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Connection error to server.')));
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  String _formatRupiah(double amount) {
    if (amount == 0) return 'Rp 0';
    final str = amount.toStringAsFixed(0);
    final buffer = StringBuffer();
    for (int i = 0; i < str.length; i++) {
      if (i > 0 && (str.length - i) % 3 == 0) buffer.write('.');
      buffer.write(str[i]);
    }
    return 'Rp ${buffer.toString()}';
  }

  void _showProcessingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Withdraw Processed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3D4270)),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Your withdrawal request has been sent to Supabase! Please wait 1–2 business days for validation.',
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

    final userController = Provider.of<UserController>(context);
    final double currentBalance = userController.balance;

    // total pendapatan kotor tanpa pengurangan
    double totalWithdrawalAmount = 0.0;
    for (var item in _withdrawHistory) {
      final dynamic rawAmount = item['amount'];
      final double amt = rawAmount is num
          ? rawAmount.toDouble()
          : (double.tryParse(rawAmount.toString()) ?? 0.0);
      totalWithdrawalAmount += amt;
    }
    // Pendapatan Kotor = Saldo aktif saat ini + Semua nominal uang yang pernah ditarik/sedang ditarik
    double totalGrossEarnings = currentBalance + totalWithdrawalAmount;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F2F8),
      body: SafeArea(
        child: RefreshIndicator(
          onRefresh: _fetchWithdrawHistory,
          color: accentColor,
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
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

                // --- BALANCE CARD (Mengirim data total kotor ke widget) ---
                _buildBalanceCard(accentColor, currentBalance, totalGrossEarnings),
                const SizedBox(height: 25),

                // --- INPUT AMOUNT ---
                const Text('Withdraw Amount', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor)),
                const SizedBox(height: 12),
                _buildAmountInput(),
                const SizedBox(height: 8),
                const Text('Minimum withdraw amount Rp 50.000', style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),

                // --- AUTOMATIC NOTICE ---
                _buildNoticeBox(accentColor),
                const SizedBox(height: 25),

                // --- SUMMARY CARD ---
                _buildSummaryCard(userController.displayName.isEmpty ? userController.username : userController.displayName),
                const SizedBox(height: 30),

                // --- CONFIRM BUTTON ---
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            if (_amountController.text.isNotEmpty) {
                              final String cleanText = _amountController.text.replaceAll('.', '');
                              final double? inputAmount = double.tryParse(cleanText);
                              
                              if (inputAmount == null) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter a valid amount!')));
                              } else if (inputAmount < 50000) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Minimum withdraw amount is Rp 50.000!')));
                              } else if (inputAmount > currentBalance) {
                                ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Insufficient balance!')));
                              } else {
                                _submitWithdraw(inputAmount, userController.username);
                              }
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please enter the amount first!')));
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Confirm Withdraw', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 30),

                // --- RECENT HISTORY FROM LARAVEL ---
                const Text('Recent History', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor)),
                const SizedBox(height: 12),
                _buildDynamicHistorySection(),
                const SizedBox(height: 30),
              ],
            ),
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

  //Total Earnings dinamis hasil kalkulasi otomatis
  Widget _buildBalanceCard(Color color, double balance, double totalGross) {
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
          Text(_formatRupiah(balance), style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 15),
          // Mengganti tulisan Verification Type menjadi Total Earnings kotor
          const Text('Total Earnings (Gross Revenue)', style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 2),
          Text(
            _formatRupiah(totalGross), 
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
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
        
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorInputFormatter(),
        ],
        
        decoration: InputDecoration(
          prefixIcon: const Padding(
            padding: EdgeInsets.all(15),
            child: Text('Rp', style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFB0B8CC))),
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
              'Withdrawal will be sent automatically to your registered bank account',
              style: TextStyle(fontSize: 11, color: Color(0xFF3D4270)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryCard(String accountName) {
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
          Text(accountName, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 13, color: Color(0xFF6B7FD7))),
          const Text('1234 5678 9012', style: TextStyle(color: Colors.grey, fontSize: 12)),
          const Divider(height: 25),
          const Text('Processing Time', style: TextStyle(color: Colors.grey, fontSize: 11)),
          const Text('1 - 2 Business Days', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Color(0xFF3D4270))),
        ],
      ),
    );
  }

  Widget _buildDynamicHistorySection() {
    if (_isLoadingHistory) {
      return const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()));
    }

    if (_withdrawHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
        child: const Center(
          child: Text('Belum ada riwayat penarikan', style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic, fontSize: 13)),
        ),
      );
    }

    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: _withdrawHistory.length,
      itemBuilder: (context, index) {
        final item = _withdrawHistory[index];
        
        final dynamic rawAmount = item['amount'];
        final double amt = rawAmount is num
            ? rawAmount.toDouble()
            : (double.tryParse(rawAmount.toString()) ?? 0.0);

        final String status = item['status'] ?? 'pending';
        
        String rawDate = item['created_at'] ?? '';
        String formattedDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : 'Recent';

        Color statusColor = Colors.orangeAccent;
        if (status == 'approved' || status == 'success') statusColor = Colors.green;
        if (status == 'rejected' || status == 'failed') statusColor = Colors.redAccent;

        return Container(
          margin: const EdgeInsets.only(bottom: 10),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16)),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: statusColor.withOpacity(0.1),
              child: Icon(Icons.outbound, color: statusColor, size: 20),
            ),
            title: const Text('Withdrawal Request', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            subtitle: Text('$formattedDate • ${status.toUpperCase()}', style: TextStyle(fontSize: 11, color: statusColor, fontWeight: FontWeight.bold)),
            trailing: Text('-${_formatRupiah(amt)}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.redAccent)),
          ),
        );
      },
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String cleanString = newValue.text.replaceAll('.', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleanString.length; i++) {
      if (i > 0 && (cleanString.length - i) % 3 == 0) {
        buffer.write('.');
      }
      buffer.write(cleanString[i]);
    }

    String formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}