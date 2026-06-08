import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:byteme_digital_marketplace/services/api_service.dart';

class SellerOrderPage extends StatefulWidget {
  final VoidCallback? onBackPressed;
  const SellerOrderPage({super.key, this.onBackPressed});

  @override
  State<SellerOrderPage> createState() => _SellerOrderPageState();
}

class _SellerOrderPageState extends State<SellerOrderPage> {
  static const Color primaryColor = Color(0xFF6B7FD7);
  static const Color backgroundColor = Color(0xFFF0F2F8);
  static const int _itemsPerPage = 10;

  List<Map<String, dynamic>> _allOrders = [];
  bool _isLoading = true;
  String? _errorMessage;
  int _currentPage = 1;

  // ── Filter: null = semua, 'paid', 'pending', 'cancelled'
  String? _selectedFilter;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      final response = await ApiService.get('/seller/orders');
      debugPrint(
        'fetchSellerOrders [${response.statusCode}]: ${response.body}',
      );

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        final List raw = decoded is List
            ? decoded
            : (decoded['data'] ?? decoded['orders'] ?? []);
        setState(() {
          _allOrders = raw.map((e) => Map<String, dynamic>.from(e)).toList();
          _currentPage = 1;
        });
      } else {
        setState(
          () => _errorMessage = 'Gagal memuat data (${response.statusCode})',
        );
      }
    } catch (e) {
      setState(() => _errorMessage = 'Tidak dapat terhubung ke server');
      debugPrint('Error fetchSellerOrders: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  // ── Filter berdasarkan status yang dipilih
  List<Map<String, dynamic>> get _filteredOrders {
    if (_selectedFilter == null) return _allOrders;
    return _allOrders.where((order) {
      final statusPembayaran = (order['status_pembayaran'] ?? '')
          .toString()
          .toLowerCase();
      final statusPesanan = (order['status_pesanan'] ?? '')
          .toString()
          .toLowerCase();

      // Tentukan status efektif — prioritaskan status_pembayaran
      String effectiveStatus;
      if (statusPembayaran == 'success') {
        effectiveStatus = 'paid';
      } else if (statusPembayaran == 'pending') {
        effectiveStatus = 'pending';
      } else if (statusPembayaran == 'failed' || statusPesanan == 'cancelled') {
        effectiveStatus = 'cancelled';
      } else {
        effectiveStatus = statusPesanan;
      }

      return effectiveStatus == _selectedFilter;
    }).toList();
  }

  int get _totalPages => (_filteredOrders.length / _itemsPerPage).ceil();

  List<Map<String, dynamic>> get _currentPageItems {
    final start = (_currentPage - 1) * _itemsPerPage;
    final end = (start + _itemsPerPage).clamp(0, _filteredOrders.length);
    return _filteredOrders.sublist(start, end);
  }

  String _formatDate(String? dateStr) {
    if (dateStr == null || dateStr.isEmpty) return '-';
    try {
      final dt = DateTime.parse(dateStr).toLocal();
      return DateFormat('d MMM yyyy', 'id_ID').format(dt);
    } catch (_) {
      return dateStr;
    }
  }

  String _formatRupiah(dynamic amount) {
    if (amount == null) return 'Rp 0';
    final number = amount is num
        ? amount.toDouble()
        : double.tryParse(amount.toString()) ?? 0.0;
    return NumberFormat.currency(
      locale: 'id_ID',
      symbol: 'Rp ',
      decimalDigits: 0,
    ).format(number);
  }

  Color _statusColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'success':
        return Colors.green;
      case 'pending':
        return Colors.orange;
      case 'cancelled':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Color _statusBgColor(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'success':
        return const Color(0xFFE8F5E9);
      case 'pending':
        return const Color(0xFFFFF3E0);
      case 'cancelled':
        return const Color(0xFFFFEBEE);
      default:
        return const Color(0xFFF0F2F8);
    }
  }

  String _statusLabel(String? status) {
    switch (status?.toLowerCase()) {
      case 'paid':
      case 'success':
        return 'Paid';
      case 'pending':
        return 'Pending';
      case 'cancelled':
        return 'Cancelled';
      default:
        return status ?? '-';
    }
  }

  // Hitung jumlah per status untuk badge filter
  int _countByStatus(String? status) {
    if (status == null) return _allOrders.length;
    return _allOrders.where((order) {
      final statusPembayaran = (order['status_pembayaran'] ?? '')
          .toString()
          .toLowerCase();
      final statusPesanan = (order['status_pesanan'] ?? '')
          .toString()
          .toLowerCase();

      String effectiveStatus;
      if (statusPembayaran == 'success') {
        effectiveStatus = 'paid';
      } else if (statusPembayaran == 'pending') {
        effectiveStatus = 'pending';
      } else if (statusPembayaran == 'failed' || statusPesanan == 'cancelled') {
        effectiveStatus = 'cancelled';
      } else {
        effectiveStatus = statusPesanan;
      }

      return effectiveStatus == status;
    }).length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // ── HEADER ──
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GestureDetector(
                    onTap: widget.onBackPressed ?? () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.arrow_back,
                        color: Colors.black,
                        size: 22,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'My Order',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1A1D2E),
                        ),
                      ),
                      if (!_isLoading && _allOrders.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: primaryColor.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            '${_filteredOrders.length} Order',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: primaryColor,
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),

            // ── FILTER TABS ──
            if (!_isLoading && _allOrders.isNotEmpty) _buildFilterTabs(),

            // ── CONTENT ──
            Expanded(
              child: _isLoading
                  ? const Center(
                      child: CircularProgressIndicator(color: primaryColor),
                    )
                  : _errorMessage != null
                  ? _buildErrorState()
                  : _filteredOrders.isEmpty
                  ? _buildEmptyState()
                  : Column(
                      children: [
                        Expanded(
                          child: RefreshIndicator(
                            onRefresh: _fetchOrders,
                            color: primaryColor,
                            child: ListView.builder(
                              padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
                              physics: const AlwaysScrollableScrollPhysics(),
                              itemCount: _currentPageItems.length,
                              itemBuilder: (context, index) =>
                                  _buildOrderCard(_currentPageItems[index]),
                            ),
                          ),
                        ),
                        if (_totalPages > 1) _buildPagination(),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // ----------------------------------------------------------
  // FILTER TABS
  // ----------------------------------------------------------
  Widget _buildFilterTabs() {
    final filters = [
      {'label': 'Semua', 'value': null},
      {'label': 'Paid', 'value': 'paid'},
      {'label': 'Pending', 'value': 'pending'},
      {'label': 'Cancelled', 'value': 'cancelled'},
    ];

    return Container(
      height: 44,
      margin: const EdgeInsets.fromLTRB(20, 0, 20, 12),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: filters.length,
        itemBuilder: (context, index) {
          final filter = filters[index];
          final value = filter['value'] as String?;
          final isSelected = _selectedFilter == value;
          final count = _countByStatus(value);

          return GestureDetector(
            onTap: () {
              setState(() {
                _selectedFilter = value;
                _currentPage = 1;
              });
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.only(right: 10),
              padding: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: isSelected ? primaryColor : Colors.grey.shade300,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    filter['label'] as String,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                  if (count > 0) ...[
                    const SizedBox(width: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 6,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Colors.white.withOpacity(0.3)
                            : primaryColor.withOpacity(0.12),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Text(
                        '$count',
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: isSelected ? Colors.white : primaryColor,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ----------------------------------------------------------
  // ORDER CARD
  // ----------------------------------------------------------
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final statusPembayaran = (order['status_pembayaran'] ?? '')
        .toString()
        .toLowerCase();
    final statusPesanan = (order['status_pesanan'] ?? '')
        .toString()
        .toLowerCase();

    String effectiveStatus;
    if (statusPembayaran == 'success') {
      effectiveStatus = 'paid';
    } else if (statusPembayaran == 'pending') {
      effectiveStatus = 'pending';
    } else if (statusPembayaran == 'failed' || statusPesanan == 'cancelled') {
      effectiveStatus = 'cancelled';
    } else {
      effectiveStatus = statusPesanan;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 70,
              height: 70,
              child:
                  order['file_path'] != null &&
                      (order['file_path'] as String).isNotEmpty
                  ? Image.network(
                      order['file_path'] as String,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: primaryColor.withOpacity(0.1),
                        child: const Icon(
                          Icons.image_outlined,
                          color: primaryColor,
                          size: 30,
                        ),
                      ),
                      loadingBuilder: (context, child, progress) {
                        if (progress == null) return child;
                        return Container(
                          color: primaryColor.withOpacity(0.1),
                          child: const Center(
                            child: CircularProgressIndicator(
                              color: primaryColor,
                              strokeWidth: 2,
                            ),
                          ),
                        );
                      },
                    )
                  : Container(
                      color: primaryColor.withOpacity(0.1),
                      child: const Icon(
                        Icons.image_outlined,
                        color: primaryColor,
                        size: 30,
                      ),
                    ),
            ),
          ),
          const SizedBox(width: 15),

          // Detail
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        order['nama_produk'] ?? '-',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                          color: Color(0xFF1A1D2E),
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: _statusBgColor(effectiveStatus),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        _statusLabel(effectiveStatus),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: _statusColor(effectiveStatus),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoText(
                        'Pembeli',
                        order['username'] ?? '-',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoText(
                        'Tanggal',
                        // ✅ Format tanggal yang rapi
                        _formatDate(order['tgl_pesanan']?.toString()),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),

                Row(
                  children: [
                    Expanded(
                      child: _buildInfoText(
                        'Qty',
                        '${order['qty_terjual'] ?? 1}x',
                      ),
                    ),
                    Expanded(
                      child: _buildInfoText(
                        'Total',
                        _formatRupiah(order['subtotal_terjual']),
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

  Widget _buildInfoText(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 9,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          value,
          style: const TextStyle(
            fontSize: 11,
            color: Color(0xFF1A1D2E),
            fontWeight: FontWeight.w600,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  // ----------------------------------------------------------
  // PAGINATION
  // ----------------------------------------------------------
  Widget _buildPagination() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            onPressed: _currentPage > 1
                ? () => setState(() => _currentPage--)
                : null,
            icon: const Icon(Icons.chevron_left_rounded),
            color: _currentPage > 1 ? primaryColor : Colors.grey.shade300,
          ),
          ...List.generate(_totalPages, (index) {
            final page = index + 1;
            final isSelected = page == _currentPage;
            return GestureDetector(
              onTap: () => setState(() => _currentPage = page),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isSelected ? primaryColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: isSelected ? primaryColor : Colors.grey.shade300,
                  ),
                ),
                child: Center(
                  child: Text(
                    '$page',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: isSelected ? Colors.white : Colors.grey.shade600,
                    ),
                  ),
                ),
              ),
            );
          }),
          IconButton(
            onPressed: _currentPage < _totalPages
                ? () => setState(() => _currentPage++)
                : null,
            icon: const Icon(Icons.chevron_right_rounded),
            color: _currentPage < _totalPages
                ? primaryColor
                : Colors.grey.shade300,
          ),
        ],
      ),
    );
  }

  // ----------------------------------------------------------
  // EMPTY & ERROR STATE
  // ----------------------------------------------------------
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: Colors.grey.shade300,
          ),
          const SizedBox(height: 16),
          Text(
            _selectedFilter == null
                ? 'Belum ada order masuk'
                : 'Tidak ada order ${_statusLabel(_selectedFilter)}',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9098B1),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _selectedFilter == null
                ? 'Produkmu belum terjual, semangat!'
                : 'Coba pilih filter lain',
            style: const TextStyle(fontSize: 13, color: Color(0xFFB0B8CC)),
          ),
          if (_selectedFilter != null) ...[
            const SizedBox(height: 12),
            TextButton(
              onPressed: () => setState(() => _selectedFilter = null),
              child: const Text(
                'Lihat semua order',
                style: TextStyle(color: primaryColor),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.wifi_off_rounded, size: 64, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Terjadi kesalahan',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF9098B1),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          TextButton.icon(
            onPressed: _fetchOrders,
            icon: const Icon(Icons.refresh, color: primaryColor),
            label: const Text(
              'Coba lagi',
              style: TextStyle(color: primaryColor),
            ),
          ),
        ],
      ),
    );
  }
}
