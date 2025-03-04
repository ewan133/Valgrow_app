import 'package:cloud_firestore/cloud_firestore.dart';

class ItemBatch {
  final String batchId;
  final String batchName;
  final String itemId; // Reference to /items/{item_id}
  final int quantity;
  final double purchasePrice;
  final DateTime expirationDate;
  final String storeId;
  final DateTime createdAt;

  ItemBatch({
    required this.batchId,
    required this.batchName,
    required this.itemId,
    required this.quantity,
    required this.purchasePrice,
    required this.expirationDate,
    required this.storeId,
    required this.createdAt,
  });

  /// ✅ Convert Firestore `DocumentSnapshot` → `ItemBatch`
  factory ItemBatch.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>?;
    if (data == null) {
      throw Exception("Document data is null");
    }
    return ItemBatch(
      batchId: doc.id, // Firestore document ID
      batchName: data['batchName'] as String? ?? '',
      itemId: data['item_id'] as String? ?? '',
      quantity: (data['quantity'] as num?)?.toInt() ?? 0,
      purchasePrice: (data['purchase_price'] as num?)?.toDouble() ?? 0.0,
      expirationDate: (data['expiration_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      storeId: data['storeId'] as String? ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// ✅ Convert `ItemBatch` → `Map` (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      'batchName': batchName,
      'item_id': itemId,
      'quantity': quantity,
      'purchase_price': purchasePrice,
      'expiration_date': Timestamp.fromDate(expirationDate),
      'storeId': storeId,
      'created_at': FieldValue.serverTimestamp(),
    };
  }

  /// ✅ Create `ItemBatch` from `Map`
  factory ItemBatch.fromMap(String docId, Map<String, dynamic> map) {
    return ItemBatch(
      batchId: docId,
      batchName: map['batchName'] as String? ?? '',
      itemId: map['item_id'] as String? ?? '',
      quantity: (map['quantity'] as num?)?.toInt() ?? 0,
      purchasePrice: (map['purchase_price'] as num?)?.toDouble() ?? 0.0,
      expirationDate: (map['expiration_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      storeId: map['storeId'] as String? ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}