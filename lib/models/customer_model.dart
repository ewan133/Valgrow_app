import 'package:cloud_firestore/cloud_firestore.dart';

class CustomerDetails {
  final String customerId;
  final String storeId;
  final String name;
  final String phone;
  final double totalDebt;
  final String imageUrl; // ✅ Added image field
  final DateTime? lastTransactionDate;

  CustomerDetails({
    required this.customerId,
    required this.storeId,
    required this.name,
    required this.phone,
    required this.totalDebt,
    required this.imageUrl, // ✅ Default is null if no image
    this.lastTransactionDate,
  });

  /// ✅ Convert Firestore `DocumentSnapshot` → `CustomerDetails`
  factory CustomerDetails.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CustomerDetails(
      customerId: doc.id,
      storeId: data['storeId'] ?? '',
      name: data['name'] ?? 'Unknown',
      phone: data['phone'] ?? '',
      totalDebt: (data['total_debt'] ?? 0.0).toDouble(),
      imageUrl: data['imageUrl'], // ✅ Retrieve image from Firestore
      lastTransactionDate: (data['last_transaction_date'] as Timestamp?)?.toDate(),
    );
  }

  /// ✅ Convert `CustomerDetails` → `Map` (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'storeId': storeId,
      'name': name,
      'phone': phone,
      'total_debt': totalDebt,
      'imageUrl': imageUrl, // ✅ Store image URL
      'last_transaction_date': lastTransactionDate != null
          ? Timestamp.fromDate(lastTransactionDate!)
          : null,
    };
  }

  /// ✅ Create `CustomerDetails` from `Map`
  factory CustomerDetails.fromMap(String docId, Map<String, dynamic> map) {
    return CustomerDetails(
      customerId: docId,
      storeId: map['storeId'] ?? '',
      name: map['name'] ?? 'Unknown',
      phone: map['phone'] ?? '',
      totalDebt: (map['total_debt'] ?? 0.0).toDouble(),
      imageUrl: map['imageUrl'], // ✅ Get image from map
      lastTransactionDate: (map['last_transaction_date'] as Timestamp?)?.toDate(),
    );
  }
}
