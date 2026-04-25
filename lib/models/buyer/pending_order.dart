class PendingOrder {
  final String id;
  final List<Map<String, dynamic>> items;
  final int totalAmount;
  final DateTime deadline; // Waktu jatuh tempo

  PendingOrder({
    required this.id,
    required this.items,
    required this.totalAmount,
    required this.deadline,
  });
}