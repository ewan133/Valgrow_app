import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionHistory {
  final String transactionId;
  final String storeId;
  final double totalAmount;
  final DateTime createdAt;
  final String transactionType; // 🔹 Sales, Debts, Debt Payment
  final List<TransactionItem> items;
  final String? customerName; // 🔹 Added: Customer name for debts
  final String? debtPaymentMethod; // 🔹 Added: Payment method for debt payments

  TransactionHistory({
    required this.transactionId,
    required this.storeId,
    required this.totalAmount,
    required this.createdAt,
    required this.transactionType,
    required this.items,
    this.customerName, // ✅ Optional
    this.debtPaymentMethod, // ✅ Optional
  });

  /// ✅ Convert Firestore `DocumentSnapshot` → `TransactionHistory`
  factory TransactionHistory.fromDocument(
    DocumentSnapshot doc,
    List<TransactionItem> items,
    String transactionType, {
    String? customerName, // ✅ Now accepts optional customerName
    String? debtPaymentMethod, // ✅ Now accepts optional debtPaymentMethod
  }) {
    final data = doc.data() as Map<String, dynamic>;

    return TransactionHistory(
      transactionId: doc.id,
      storeId: data['storeId'] ?? '',
      totalAmount: (data['total_amount'] ?? 0.0).toDouble(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      transactionType: transactionType,
      items: items,
      customerName: customerName, // ✅ Assign customer name if applicable
      debtPaymentMethod: debtPaymentMethod, // ✅ Assign payment method if applicable
    );
  }
}




/// ✅ Model for Transaction Items
class TransactionItem {
  final String itemId;
  final int quantity;
  final double unitPrice;
  final double totalPrice;
  final double? discount; // Optional

  TransactionItem({
    required this.itemId,
    required this.quantity,
    required this.unitPrice,
    required this.totalPrice,
    this.discount,
  });

  /// ✅ Convert Firestore Document → `TransactionItem`
  factory TransactionItem.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return TransactionItem(
      itemId: data['item_id'] ?? '',
      quantity: (data['quantity'] ?? 0).toInt(),
      unitPrice: (data['unit_price'] ?? 0.0).toDouble(),
      totalPrice: (data['total_price'] ?? 0.0).toDouble(),
      discount: (data['discount'] ?? 0.0).toDouble(),
    );
  }

  /// ✅ Convert `TransactionItem` → `Map`
  Map<String, dynamic> toMap() {
    return {
      'item_id': itemId,
      'quantity': quantity,
      'unit_price': unitPrice,
      'total_price': totalPrice,
      'discount': discount,
    };
  }
}
