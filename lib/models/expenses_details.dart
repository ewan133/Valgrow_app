import 'package:cloud_firestore/cloud_firestore.dart';

class ExpenseModel {
  final String expenseId;
  final double amount;
  final String category;
  final String? note;
  final String storeId;
  final DateTime date;
  final DateTime createdAt;

  ExpenseModel({
    required this.expenseId,
    required this.amount,
    required this.category,
    this.note,
    required this.storeId,
    required this.date,
    required this.createdAt,
  });

  /// 🔄 Convert Firestore Document → ExpenseModel
  factory ExpenseModel.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return ExpenseModel(
      expenseId: doc.id,
      amount: (data['amount'] as num?)?.toDouble() ?? 0.0,
      category: data['category'] as String? ?? '',
      note: data['note'] as String?,
      storeId: data['storeId'] as String? ?? '',
      date: (data['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// 🔄 Convert ExpenseModel → Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'amount': amount,
      'category': category,
      'note': note,
      'storeId': storeId,
      'date': Timestamp.fromDate(date),
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  /// 🛠️ Optional: Create from plain Map + ID
  factory ExpenseModel.fromMap(String docId, Map<String, dynamic> map) {
    return ExpenseModel(
      expenseId: docId,
      amount: (map['amount'] as num?)?.toDouble() ?? 0.0,
      category: map['category'] as String? ?? '',
      note: map['note'] as String?,
      storeId: map['storeId'] as String? ?? '',
      date: (map['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
