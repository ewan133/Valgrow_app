  import 'package:cloud_firestore/cloud_firestore.dart';

  class ItemDetails {
    final String itemId;
    final String item_name;
    final double regular_price;
    final double unpaid_price;
    final String category;
    final String unit;
    final String barcode;
    final String item_image;
    final int total_stock;
    final String storeId;
    final DateTime last_updated; // ✅ Ensure DateTime type

    ItemDetails({
      required this.itemId,
      required this.item_name,
      required this.regular_price,
      required this.unpaid_price,
      required this.category,
      required this.unit,
      required this.barcode,
      required this.item_image,
      required this.storeId,
      required this.total_stock,
      required this.last_updated,
    });

    /// ✅ Convert Firestore `DocumentSnapshot` → `ItemDetails`
    factory ItemDetails.fromDocument(DocumentSnapshot doc) {
      final data = doc.data() as Map<String, dynamic>;
      return ItemDetails(
        itemId: doc.id, // ✅ Firestore document ID
        item_name: data['item_name'] ?? 'Unknown',
        regular_price: (data['regular_price'] ?? 0).toDouble(),
        unpaid_price: (data['unpaid_price'] ?? 0).toDouble(),
        category: data['category'] ?? '',
        unit: data['unit'] ?? '',
        barcode: data['barcode'] ?? '',
        item_image: data['item_image'] ?? '',
        storeId: data['storeId'] ?? '',
        total_stock: (data['total_stock'] ?? 0).toInt(),
        last_updated: (data['last_updated'] as Timestamp?)?.toDate() ?? DateTime.now(), // ✅ Convert Firestore Timestamp
      );
    }

    /// ✅ Convert `ItemDetails` → `Map` (for Firestore storage)
    Map<String, dynamic> toMap() {
      return {
        'item_name': item_name,
        'regular_price': regular_price,
        'unpaid_price': unpaid_price,
        'category': category,
        'unit': unit,
        'barcode': barcode,
        'item_image': item_image,
        'storeId': storeId,
        'total_stock': total_stock,
        'last_updated': FieldValue.serverTimestamp(), // ✅ Use Firestore timestamp
      };
    }

    /// ✅ Create `ItemDetails` from `Map`
    factory ItemDetails.fromMap(String docId, Map<String, dynamic> map) {
      return ItemDetails(
        itemId: docId,
        item_name: map['item_name'] ?? 'Unknown',
        regular_price: (map['regular_price'] ?? 0).toDouble(),
        unpaid_price: (map['unpaid_price'] ?? 0).toDouble(),
        category: map['category'] ?? '',
        unit: map['unit'] ?? '',
        barcode: map['barcode'] ?? '',
        item_image: map['item_image'] ?? '',
        storeId: map['storeId'] ?? '',
        total_stock: (map['total_stock'] ?? 0).toInt(),
        last_updated: (map['last_updated'] as Timestamp?)?.toDate() ?? DateTime.now(), // ✅ Fix conversion
      );
    }
  }
