import 'package:cloud_firestore/cloud_firestore.dart';

class DebtDetails {
  final String debtId;
  final String storeId;
  final String customerId;
  final String transactionId;
  final double totalAmount;
  final double amountPaid;
  final double balance;
  final String status;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime dueDate;
  final DateTime? lastPaymentDate;

  DebtDetails({
    required this.debtId,
    required this.storeId,
    required this.customerId,
    required this.transactionId,
    required this.totalAmount,
    required this.amountPaid,
    required this.balance,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
    required this.dueDate,
    this.lastPaymentDate,
  });

  /// ✅ Convert Firestore `DocumentSnapshot` → `DebtDetails`
  factory DebtDetails.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DebtDetails(
      debtId: doc.id,
      storeId: data['storeId'] ?? '',
      customerId: data['customerId'] ?? '',
      transactionId: data['transactionId'] ?? '',
      totalAmount: (data['total_amount'] ?? 0.0).toDouble(),
      amountPaid: (data['amount_paid'] ?? 0.0).toDouble(),
      balance: (data['balance'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'unpaid',
      createdAt: (data['created_at'] as Timestamp).toDate(),
      updatedAt: (data['updated_at'] as Timestamp).toDate(),
      dueDate: (data['due_date'] as Timestamp).toDate(),
      lastPaymentDate: (data['last_payment_date'] as Timestamp?)?.toDate(),
    );
  }

  /// ✅ Convert `DebtDetails` → `Map` (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'customerId': customerId,
      'transactionId': transactionId,
      'total_amount': totalAmount,
      'amount_paid': amountPaid,
      'balance': balance,
      'status': status,
      'created_at': Timestamp.fromDate(createdAt),
      'updated_at': Timestamp.fromDate(updatedAt),
      'due_date': Timestamp.fromDate(dueDate),
      'last_payment_date': lastPaymentDate != null
          ? Timestamp.fromDate(lastPaymentDate!)
          : null,
    };
  }

  /// ✅ Create `DebtDetails` from `Map`
  factory DebtDetails.fromMap(String docId, Map<String, dynamic> map) {
    return DebtDetails(
      debtId: docId,
      storeId: map['storeId'] ?? '',
      customerId: map['customerId'] ?? '',
      transactionId: map['transactionId'] ?? '',
      totalAmount: (map['total_amount'] ?? 0.0).toDouble(),
      amountPaid: (map['amount_paid'] ?? 0.0).toDouble(),
      balance: (map['balance'] ?? 0.0).toDouble(),
      status: map['status'] ?? 'unpaid',
      createdAt: (map['created_at'] as Timestamp).toDate(),
      updatedAt: (map['updated_at'] as Timestamp).toDate(),
      dueDate: (map['due_date'] as Timestamp).toDate(),
      lastPaymentDate: (map['last_payment_date'] as Timestamp?)?.toDate(),
    );
  }
}
