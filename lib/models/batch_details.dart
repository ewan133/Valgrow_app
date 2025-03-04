import 'package:cloud_firestore/cloud_firestore.dart';

class ItemBatch {
  final String batchId;
  final String batchName;
  final String itemId; // Reference to /items/{item_id}
  final int quantity;
  final DateTime expirationDate;
  final String storeId;
  final DateTime createdAt;

  ItemBatch({
    required this.batchId,
    required this.batchName,
    required this.itemId,
    required this.quantity,
    required this.expirationDate,
    required this.storeId,
    required this.createdAt,
  });

  /// ✅ Convert Firestore `DocumentSnapshot` → `ItemBatch`
  factory ItemBatch.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ItemBatch(
      batchId: doc.id, // Firestore document ID
      batchName: data['batchName'] ?? '',
      itemId: data['item_id'] ?? '',
      quantity: (data['quantity'] ?? 0).toInt(),
      expirationDate: (data['expiration_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      storeId: data['storeId'] ?? '',
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// ✅ Convert `ItemBatch` → `Map` (for Firestore storage)
  Map<String, dynamic> toMap() {
    return {
      
      'batchName': batchName,
      'item_id': itemId,
      'quantity': quantity,
      'expiration_date': Timestamp.fromDate(expirationDate), // Store as Firestore timestamp
      'storeId': storeId,
      'created_at': FieldValue.serverTimestamp(), // Firestore server timestamp
    };
  }

  /// ✅ Create `ItemBatch` from `Map`
  factory ItemBatch.fromMap(String docId, Map<String, dynamic> map) {
    return ItemBatch(
      batchId: docId,
      batchName: map['batchName'] ?? '',
      itemId: map['item_id'] ?? '',
      quantity: (map['quantity'] ?? 0).toInt(),
      expirationDate: (map['expiration_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
      storeId: map['storeId'] ?? '',
      createdAt: (map['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
