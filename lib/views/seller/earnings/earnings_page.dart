import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:byteme_digital_marketplace/controller/user_controller.dart';
import 'package:byteme_digital_marketplace/services/api_service.dart';
import 'package:byteme_digital_marketplace/utils/notif_helper.dart';
import 'package:url_launcher/url_launcher.dart';

// ── Daftar bank dan e-wallet ──────────────────────────────────────────────────
const List<Map<String, dynamic>> kBankList = [
  {'name': 'BCA - Bank Central Asia',    'icon': Icons.account_balance, 'type': 'bank'},
  {'name': 'BRI - Bank Rakyat Indonesia','icon': Icons.account_balance, 'type': 'bank'},
  {'name': 'BNI - Bank Negara Indonesia','icon': Icons.account_balance, 'type': 'bank'},
  {'name': 'Mandiri',                    'icon': Icons.account_balance, 'type': 'bank'},
  {'name': 'CIMB Niaga',                 'icon': Icons.account_balance, 'type': 'bank'},
  {'name': 'BSI - Bank Syariah Indonesia','icon': Icons.account_balance,'type': 'bank'},
  {'name': 'GoPay',   'icon': Icons.wallet, 'type': 'ewallet'},
  {'name': 'OVO',     'icon': Icons.wallet, 'type': 'ewallet'},
  {'name': 'DANA',    'icon': Icons.wallet, 'type': 'ewallet'},
  {'name': 'ShopeePay','icon': Icons.wallet,'type': 'ewallet'},
  {'name': 'LinkAja', 'icon': Icons.wallet, 'type': 'ewallet'},
];

class EarningsPage extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const EarningsPage({super.key, this.onBackPressed});

  @override
  State<EarningsPage> createState() => _EarningsPageState();
}

class _EarningsPageState extends State<EarningsPage> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  bool _isLoadingHistory = true;
  bool _isSubmitting = false;
  List<dynamic> _withdrawHistory = [];

  // State untuk pilihan bank
  Map<String, dynamic>? _selectedBank;

  @override
  void initState() {
    super.initState();
    _fetchWithdrawHistory();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _accountNumberController.dispose();
    super.dispose();
  }

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

  Future<void> _submitWithdraw(double amount, String accountName) async {
    setState(() => _isSubmitting = true);
    try {
      final response = await ApiService.postAuth('/withdraws', {
        'amount': amount,
        'bank_name': _selectedBank!['name'],
        'bank_account_number': _accountNumberController.text.trim(),
        'bank_account_name': accountName,
      });

      if (!mounted) return;
      final decoded = jsonDecode(response.body);

      if (response.statusCode == 201) {
        final double newBalance = (decoded['balance'] as num).toDouble();
        Provider.of<UserController>(context, listen: false).updateBalance(newBalance);
        _showProcessingDialog();
        _fetchWithdrawHistory();
      } else {
        NotifHelper.showError(context, decoded['message'] ?? 'Failed to process withdrawal');
      }
    } catch (e) {
      NotifHelper.showError(context, 'Connection error to server.');
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
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.check_circle_rounded, color: Colors.green, size: 60),
              const SizedBox(height: 20),
              const Text('Withdraw Processed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF3D4270))),
              const SizedBox(height: 12),
              const Text(
                'Your withdrawal request has been sent! Please wait 1–2 business days for processing.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _amountController.clear();
                    _accountNumberController.clear();
                    setState(() => _selectedBank = null);
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
      ),
    );
  }

  // ── Popup detail history ───────────────────────────────────────────────────
  void _showHistoryDetail(Map<String, dynamic> item) {
    final dynamic rawAmount = item['amount'];
    final double amt = rawAmount is num
        ? rawAmount.toDouble()
        : double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;
    final String status = item['status'] ?? 'pending';
    final String rawDate = item['created_at'] ?? '';
    final String formattedDate = rawDate.length >= 10 ? rawDate.substring(0, 10) : '-';
    final String? receiptFile = item['receipt_file'];
    final String bankName = item['bank_name'] ?? '-';
    final String bankAccount = item['bank_account_number'] ?? '-';
    final String bankAccountName = item['bank_account_name'] ?? '-';

    Color statusColor = Colors.orangeAccent;
    if (status == 'success') statusColor = Colors.green;
    if (status == 'handled') statusColor = const Color(0xFF6B7AFF);
    if (status == 'rejected') statusColor = Colors.redAccent;

    showDialog(
      context: context,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  const Icon(Icons.receipt_long_rounded, color: Color(0xFF3D4270), size: 22),
                  const SizedBox(width: 8),
                  const Text('Withdraw Detail',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF3D4270))),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => Navigator.pop(ctx),
                    child: const Icon(Icons.close, color: Colors.grey, size: 20),
                  ),
                ],
              ),
              const Divider(height: 24),

              // Info rows
              _detailRow('Amount', _formatRupiah(amt), valueColor: Colors.redAccent),
              const SizedBox(height: 8),
              _detailRow('Date', formattedDate),
              const SizedBox(height: 8),
              _detailRow('Bank', bankName),
              const SizedBox(height: 8),
              _detailRow('Account No.', bankAccount),
              const SizedBox(height: 8),
              _detailRow('Account Name', bankAccountName),
              const SizedBox(height: 8),
              _detailRow(
                'Status',
                status.toUpperCase(),
                valueColor: statusColor,
                valueBold: true,
              ),
              const Divider(height: 24),

              // Bukti transfer
              const Text('Transfer Receipt',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFF3D4270))),
              const SizedBox(height: 10),

              if (receiptFile != null && receiptFile.isNotEmpty)
                GestureDetector(
                  onTap: () async {
                    final uri = Uri.parse(receiptFile);
                    if (await canLaunchUrl(uri)) {
                      await launchUrl(uri, mode: LaunchMode.externalApplication);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE8F5E9),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.green.shade200),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.file_present_rounded, color: Colors.green, size: 20),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text('Tap to view receipt',
                              style: TextStyle(color: Colors.green, fontWeight: FontWeight.w600, fontSize: 13)),
                        ),
                        Icon(Icons.open_in_new, color: Colors.green, size: 16),
                      ],
                    ),
                  ),
                )
              else
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF8FAFC),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.grey, size: 18),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'There is no receipt of transfer yet. Please contact the admin via email.',
                          style: TextStyle(color: Colors.grey, fontSize: 12, height: 1.4),
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _detailRow(String label, String value,
      {Color? valueColor, bool valueBold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontSize: 13,
              fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
              color: valueColor ?? const Color(0xFF3D4270),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    const Color primaryColor = Color(0xFF3D4270);
    const Color accentColor = Color(0xFF6B7FD7);

    final userController = Provider.of<UserController>(context);
    final double currentBalance = userController.balance;

    double totalWithdrawalAmount = 0.0;
    for (var item in _withdrawHistory) {
      final dynamic rawAmount = item['amount'];
      totalWithdrawalAmount += rawAmount is num
          ? rawAmount.toDouble()
          : (double.tryParse(rawAmount.toString()) ?? 0.0);
    }
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
                Row(
                  children: [
                    _buildCircleBackButton(context),
                    const Expanded(
                      child: Center(
                        child: Text('Withdraw',
                            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: primaryColor)),
                      ),
                    ),
                    const SizedBox(width: 40),
                  ],
                ),
                const SizedBox(height: 25),
                _buildBalanceCard(accentColor, currentBalance, totalGrossEarnings),
                const SizedBox(height: 25),

                // Amount input
                const Text('Withdraw Amount',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor)),
                const SizedBox(height: 12),
                _buildAmountInput(),
                const SizedBox(height: 8),
                const Text('Minimum withdraw amount Rp 50.000',
                    style: TextStyle(color: Colors.redAccent, fontSize: 11, fontWeight: FontWeight.w500)),
                const SizedBox(height: 20),

                // Bank selector
                const Text('Bank / E-Wallet',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor)),
                const SizedBox(height: 12),
                _buildBankSelector(),
                const SizedBox(height: 16),

                // Account number input (muncul setelah bank dipilih)
                if (_selectedBank != null) ...[
                  Text(
                    _selectedBank!['type'] == 'ewallet'
                        ? 'Registered Phone Number'
                        : 'Account Number',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: primaryColor),
                  ),
                  const SizedBox(height: 12),
                  _buildAccountNumberInput(),
                  const SizedBox(height: 20),
                ],

                _buildNoticeBox(accentColor),
                const SizedBox(height: 25),

                // Summary card dinamis
                if (_selectedBank != null)
                  _buildSummaryCard(
                    userController.displayName.isEmpty
                        ? userController.username
                        : userController.displayName,
                  ),
                if (_selectedBank != null) const SizedBox(height: 25),

                // Confirm button
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isSubmitting
                        ? null
                        : () {
                            final String cleanText =
                                _amountController.text.replaceAll('.', '');
                            final double? inputAmount =
                                double.tryParse(cleanText);

                            if (cleanText.isEmpty) {
                              NotifHelper.showWarning(
                                  context, 'Please enter the amount first!');
                              return;
                            }
                            if (inputAmount == null) {
                              NotifHelper.showWarning(
                                  context, 'Please enter a valid amount!');
                              return;
                            }
                            if (inputAmount < 50000) {
                              NotifHelper.showWarning(context,
                                  'Minimum withdraw amount is Rp 50.000!');
                              return;
                            }
                            if (inputAmount > currentBalance) {
                              NotifHelper.showError(
                                  context, 'Insufficient balance!');
                              return;
                            }
                            if (_selectedBank == null) {
                              NotifHelper.showWarning(
                                  context, 'Please select a bank or e-wallet!');
                              return;
                            }
                            if (_accountNumberController.text.trim().isEmpty) {
                              NotifHelper.showWarning(context,
                                  'Please enter your account number!');
                              return;
                            }
                            _submitWithdraw(inputAmount,
                                userController.displayName.isEmpty
                                    ? userController.username
                                    : userController.displayName);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: accentColor,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16)),
                      elevation: 0,
                    ),
                    child: _isSubmitting
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2))
                        : const Text('Confirm Withdraw',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                  ),
                ),
                const SizedBox(height: 30),

                const Text('Recent History',
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                        color: primaryColor)),
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

  // ── Widget Helpers ─────────────────────────────────────────────────────────

  Widget _buildCircleBackButton(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
        ],
      ),
      child: IconButton(
        icon: const Icon(Icons.arrow_back, color: Color(0xFF3D4270), size: 20),
        onPressed: widget.onBackPressed ?? () => Navigator.pop(context),
      ),
    );
  }

  Widget _buildBalanceCard(Color color, double balance, double totalGross) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: color.withOpacity(0.85),
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
              color: color.withOpacity(0.2),
              blurRadius: 15,
              offset: const Offset(0, 8))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Available Balance',
              style: TextStyle(color: Colors.white70, fontSize: 13)),
          Text(_formatRupiah(balance),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 26,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 15),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 15),
          const Text('Total Earnings (Gross Revenue)',
              style: TextStyle(color: Colors.white70, fontSize: 12)),
          const SizedBox(height: 2),
          Text(_formatRupiah(totalGross),
              style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildAmountInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: TextField(
        controller: _amountController,
        keyboardType: TextInputType.number,
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF3D4270)),
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly,
          ThousandsSeparatorInputFormatter(),
        ],
        decoration: const InputDecoration(
          prefixIcon: Padding(
            padding: EdgeInsets.all(15),
            child: Text('Rp',
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFB0B8CC))),
          ),
          hintText: '0',
          hintStyle: TextStyle(color: Color(0xFFD0D5E8)),
          border: InputBorder.none,
          contentPadding:
              EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildBankSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<Map<String, dynamic>>(
          value: _selectedBank,
          isExpanded: true,
          hint: const Text('Select bank or e-wallet',
              style: TextStyle(color: Color(0xFFB0B8CC), fontSize: 14)),
          icon: const Icon(Icons.keyboard_arrow_down_rounded,
              color: Color(0xFFB0B8CC)),
          items: kBankList.map((bank) {
            return DropdownMenuItem<Map<String, dynamic>>(
              value: bank,
              child: Row(
                children: [
                  Icon(
                    bank['icon'] as IconData,
                    size: 18,
                    color: bank['type'] == 'ewallet'
                        ? const Color(0xFF6B7FD7)
                        : const Color(0xFF3D4270),
                  ),
                  const SizedBox(width: 10),
                  Text(bank['name'] as String,
                      style: const TextStyle(
                          fontSize: 14, color: Color(0xFF3D4270))),
                ],
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() {
            _selectedBank = val;
            _accountNumberController.clear();
          }),
        ),
      ),
    );
  }

  Widget _buildAccountNumberInput() {
    final bool isEwallet = _selectedBank?['type'] == 'ewallet';
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.02), blurRadius: 10)
        ],
      ),
      child: TextField(
        controller: _accountNumberController,
        keyboardType: isEwallet
            ? TextInputType.phone
            : TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Color(0xFF3D4270)),
        decoration: InputDecoration(
          prefixIcon: Icon(
            isEwallet ? Icons.phone_android : Icons.credit_card,
            color: const Color(0xFFB0B8CC),
            size: 20,
          ),
          hintText:
              isEwallet ? 'e.g. 08123456789' : 'e.g. 1234567890',
          hintStyle: const TextStyle(color: Color(0xFFD0D5E8)),
          border: InputBorder.none,
          contentPadding:
              const EdgeInsets.symmetric(vertical: 18, horizontal: 20),
        ),
      ),
    );
  }

  Widget _buildNoticeBox(Color color) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12)),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: color, size: 20),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Withdrawal will be processed manually by admin within 1–2 business days.',
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
          const Text('Withdrawal Summary',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Color(0xFF3D4270))),
          const Divider(height: 20),
          _detailRow('Bank / E-Wallet', _selectedBank?['name'] ?? '-'),
          const SizedBox(height: 6),
          _detailRow(
            _selectedBank?['type'] == 'ewallet'
                ? 'Phone Number'
                : 'Account Number',
            _accountNumberController.text.isEmpty
                ? '-'
                : _accountNumberController.text,
          ),
          const SizedBox(height: 6),
          _detailRow('Account Name', accountName),
          const Divider(height: 20),
          _detailRow('Processing Time', '1 - 2 Business Days'),
        ],
      ),
    );
  }

  Widget _buildDynamicHistorySection() {
    if (_isLoadingHistory) {
      return const Center(
          child: Padding(
              padding: EdgeInsets.all(20),
              child: CircularProgressIndicator()));
    }

    if (_withdrawHistory.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16)),
        child: const Center(
          child: Text('Belum ada riwayat penarikan',
              style: TextStyle(
                  color: Colors.grey,
                  fontStyle: FontStyle.italic,
                  fontSize: 13)),
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
            : double.tryParse(rawAmount?.toString() ?? '0') ?? 0.0;
        final String status = item['status'] ?? 'pending';
        final String rawDate = item['created_at'] ?? '';
        final String formattedDate =
            rawDate.length >= 10 ? rawDate.substring(0, 10) : 'Recent';

        Color statusColor = Colors.orangeAccent;
        if (status == 'success') statusColor = Colors.green;
        if (status == 'handled') statusColor = const Color(0xFF6B7AFF);
        if (status == 'rejected') statusColor = Colors.redAccent;

        return GestureDetector(
          onTap: () => _showHistoryDetail(item),
          child: Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16)),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: statusColor.withOpacity(0.1),
                child:
                    Icon(Icons.outbound, color: statusColor, size: 20),
              ),
              title: const Text('Withdrawal Request',
                  style: TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 13)),
              subtitle: Text(
                '$formattedDate • ${status.toUpperCase()}',
                style: TextStyle(
                    fontSize: 11,
                    color: statusColor,
                    fontWeight: FontWeight.bold),
              ),
              trailing: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('-${_formatRupiah(amt)}',
                      style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.redAccent)),
                  const SizedBox(width: 4),
                  const Icon(Icons.chevron_right,
                      color: Colors.grey, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class ThousandsSeparatorInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    if (newValue.text.isEmpty) return newValue.copyWith(text: '');
    String cleanString = newValue.text.replaceAll('.', '');
    final buffer = StringBuffer();
    for (int i = 0; i < cleanString.length; i++) {
      if (i > 0 && (cleanString.length - i) % 3 == 0) buffer.write('.');
      buffer.write(cleanString[i]);
    }
    String formattedText = buffer.toString();
    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}