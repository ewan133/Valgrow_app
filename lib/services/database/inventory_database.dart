import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/models/batch_details.dart';
import 'package:valgrow_ui/models/item_details.dart';
import 'package:valgrow_ui/services/database/audit_database.dart';

class InventoryDatabase {
  final _db = FirebaseFirestore.instance;
  final AuditDatabase _auditDb = AuditDatabase();

  Future<void> addItem(ItemDetails item, {String? userId}) async {
    try {
      // Reference to Firestore collection
      final itemRef = _db.collection('items').doc();

      // Convert the item to a Map and remove the 'itemId' field
      Map<String, dynamic> itemMap = item.toMap();
      itemMap.remove(
          'itemId'); // Remove the itemId from the map before adding to Firestore

      // Add the remaining fields to Firestore
      await itemRef.set(itemMap);

      // ✅ Log audit trail
      await _auditDb.logAudit(
        storeId: item.storeId,
        userId: userId ?? item.storeId, // ✅ Use actual userId if provided
        action: 'CREATE_ITEM',
        entityType: 'inventory',
        entityId: itemRef.id,
        description: 'New item added: ${item.item_name}',
        metadata: {
          'itemName': item.item_name,
          'category': item.category,
        },
      );

      print("✅ Item added successfully: ${item.item_name}");
    } catch (e) {
      print("❌ Error adding item: $e");
      throw e;
    }
  }

  Future<List<String>> getUniqueCategories(String storeId) async {
    try {
      // Fetch all items that belong to the given storeId
      QuerySnapshot querySnapshot = await _db
          .collection('items')
          .where('storeId', isEqualTo: storeId) // Filter by storeId
          .get();

      // Extract unique categories from the filtered documents
      Set<String> uniqueCategories = {};

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;
        if (data.containsKey('category') && data['category'] is String) {
          uniqueCategories.add(data['category']);
        }
      }

      return uniqueCategories.toList(); // Convert Set to List and return
    } catch (e) {
      print("❌ Error retrieving categories for storeId ($storeId): $e");
      return []; // Return an empty list if an error occurs
    }
  }

  // get all items from the database
  Future<List<ItemDetails>> getItemsByStoreId(String storeId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('items')
          .where('storeId', isEqualTo: storeId) // Filter items by storeId
          .get();

      List<ItemDetails> items = querySnapshot.docs.map((doc) {
        return ItemDetails.fromDocument(doc);
      }).toList();

      for (var item in items) {
        print("✅ Item ID (Doc ID): ${item.itemId}");
        print("Item Name: ${item.item_name}");
        print("Category: ${item.category}");
        print("Price: \$${item.regular_price}");
        print("Stock: ${item.total_stock}");
        print("Store ID: ${item.storeId}");
        print("------");
      }

      return items; // Return the list of items
    } catch (e) {
      print("❌ Error retrieving items for storeId $storeId: $e");
      return []; // Return an empty list if an error occurs
    }
  }

  /*
    METHODS FOR BATCH COLLECTIONS
    - fetch all batches
    - add batch 
    - update item stocks after batch insert
   */

  Future<List<ItemBatch>> getBatchesForItem(String itemId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('item_batch')
          .where('item_id', isEqualTo: itemId) // Filter by item_id
          .orderBy('created_at', descending: true) // Sort by newest first
          .get();

      List<ItemBatch> batches = querySnapshot.docs.map((doc) {
        return ItemBatch.fromDocument(doc);
      }).toList();

      for (var batch in batches) {
        print("✅ Batch ID: ${batch.batchId}");
        print("Quantity: ${batch.quantity}");
        print("Expiration Date: ${batch.expirationDate}");
        print("Created At: ${batch.createdAt}");
        print("Store ID: ${batch.storeId}");
        print("------");
      }
      return batches; // Return the list of batches
    } catch (e) {
      print("❌ Error retrieving batches for itemId $itemId: $e");
      return []; // Return an empty list if an error occurs
    }
  }

  Future<void> addBatch(ItemBatch batch, {String? userId}) async {
    try {
      // 🔹 Reference Firestore batch collection
      final batchRef = _db.collection('item_batch').doc();

      // 🔹 Convert batch to a Map and remove the 'batchId' field before adding
      Map<String, dynamic> batchMap = batch.toMap();
      batchMap.remove('batchId');

      // 🔹 Add batch to Firestore
      await batchRef.set(batchMap);

      print("✅ Batch added successfully for item: ${batch.itemId}");

      // ✅ Insert into inventory_log
      await _insertInventoryLog(
        itemId: batch.itemId,
        quantity: batch.quantity,
        reason: "New Stock Added",
        storeId: batch.storeId,
        type: "Addition",
      );

      // ✅ Update item stock
      await _updateItemStock(batch.itemId);

      // 🔍 Fetch item name from Firestore
      final itemSnapshot =
          await _db.collection('items').doc(batch.itemId).get();
      final itemData = itemSnapshot.data();
      final itemName = itemData?['item_name'] ?? 'Unknown Item';

      // ✅ Insert capital expense with detailed note and userId
      await _db.collection('expenses').add({
        'amount': batch.purchasePrice,
        'category': 'Capital',
        'note':
            'Purchased ${batch.quantity}x $itemName for ₱${batch.purchasePrice.toStringAsFixed(2)} in total',
        'date': DateTime.now(),
        'storeId': batch.storeId,
        'userId': userId ?? batch.storeId, // ✅ Use userId if provided
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("✅ Capital expense logged.");

      // ✅ Log audit trail for batch addition
      await _auditDb.logAudit(
        storeId: batch.storeId,
        userId: userId ?? batch.storeId, // ✅ Use actual userId if provided
        action: 'ADD_STOCK_BATCH',
        entityType: 'inventory',
        entityId: batch.itemId,
        description: 'Added ${batch.quantity} units of $itemName (Batch)',
        metadata: {
          'quantity': batch.quantity,
          'purchasePrice': batch.purchasePrice,
          'itemName': itemName,
          'expirationDate': batch.expirationDate?.toIso8601String(),
        },
      );
    } catch (e) {
      print("❌ Error adding batch: $e");
      throw e;
    }
  }

  /// 🔹 **Insert a record into inventory_log**
  Future<void> _insertInventoryLog({
    required String itemId,
    required int quantity,
    required String reason,
    required String storeId,
    required String type, // ✅ Either "Addition" or "Reduction"
  }) async {
    try {
      final logRef = _db.collection('inventory_log').doc(); // New log entry

      await logRef.set({
        "item_id": itemId,
        "quantity": quantity,
        "reason": reason,
        "storeId": storeId,
        "type": type,
        "created_at": FieldValue.serverTimestamp(),
      });

      print(
          "✅ Inventory log added: Item ID - $itemId | Type - $type | Qty - $quantity");
    } catch (e) {
      print("❌ Error inserting into inventory_log: $e");
    }
  }

  Future<void> _updateItemStock(String itemId) async {
    try {
      final itemRef = _db.collection('items').doc(itemId);

      // 🔹 Fetch total quantity added from inventory_log
      QuerySnapshot additionLogs = await _db
          .collection('inventory_log')
          .where('item_id', isEqualTo: itemId)
          .where('type', isEqualTo: "Addition")
          .get();

      int totalAddedStock = additionLogs.docs.fold(0, (sum, doc) {
        return sum + (doc['quantity'] as num? ?? 0).toInt();
      });

      // 🔹 Fetch total quantity reduced from inventory_log
      QuerySnapshot reductionLogs = await _db
          .collection('inventory_log')
          .where('item_id', isEqualTo: itemId)
          .where('type', isEqualTo: "Reduction")
          .get();

      int totalReducedStock = reductionLogs.docs.fold(0, (sum, doc) {
        return sum + (doc['quantity'] as num? ?? 0).toInt();
      });

      // 🔹 Fetch total quantity sold from transaction_items
      QuerySnapshot salesLogs = await _db
          .collection('transaction_items')
          .where('item_id', isEqualTo: itemId)
          .get();

      int totalSoldStock = salesLogs.docs.fold(0, (sum, doc) {
        return sum + (doc['quantity'] as num? ?? 0).toInt();
      });

      // 🔹 Calculate new stock correctly
      int newStock = totalAddedStock - (totalReducedStock + totalSoldStock);
      if (newStock < 0) newStock = 0; // Ensure stock never goes negative

      // 🔹 Update Firestore
      await itemRef.update({
        'total_stock': newStock,
        'last_updated': FieldValue.serverTimestamp(),
      });

      print("✅ Updated total_stock for item $itemId: $newStock");
    } catch (e) {
      print("❌ Error updating total_stock: $e");
      throw e;
    }
  }

  Future<void> editItem(ItemDetails item) async {
    try {
      // Reference to the item document in Firestore
      final itemRef = _db.collection('items').doc(item.itemId);

      // Check if the item exists before updating
      DocumentSnapshot itemDoc = await itemRef.get();
      if (!itemDoc.exists) {
        print("⚠️ Item not found: ${item.itemId}");
        return;
      }

      // Convert the item to a Map
      Map<String, dynamic> updatedData = item.toMap();

      // Remove null values to avoid overwriting with null
      updatedData.removeWhere((key, value) => value == null);

      // Update the item in Firestore
      await itemRef.update(updatedData);

      print("✅ Item updated successfully: ${item.itemId}");
    } catch (e) {
      print("❌ Error updating item: $e");
      throw e;
    }
  }

  /// ✅ Reduce stock & log it in inventory logs
  Future<void> reduceStock({
    required String itemId,
    required int quantity,
    required String reason,
    required String storeId,
    String? userId, // ✅ Added userId parameter
  }) async {
    final DocumentReference itemRef = _db.collection('items').doc(itemId);
    final DocumentReference logRef = _db.collection('inventory_log').doc();
    final WriteBatch batch = _db.batch();

    try {
      // 🔹 Fetch current stock
      DocumentSnapshot itemSnapshot = await itemRef.get();
      if (!itemSnapshot.exists) {
        print("❌ Error: Item not found");
        return;
      }

      Map<String, dynamic> itemData =
          itemSnapshot.data() as Map<String, dynamic>;
      int currentStock = (itemData['total_stock'] ?? 0).toInt();

      if (quantity > currentStock) {
        print("⚠️ Cannot reduce more than available stock!");
        return;
      }

      // 🔹 Calculate new stock level
      int newStock = currentStock - quantity;
      if (newStock < 0) newStock = 0; // Prevent negative stock

      // 🔹 Log stock reduction
      batch.set(logRef, {
        "item_id": itemId,
        "quantity": quantity,
        "reason": reason,
        "storeId": storeId,
        "type": "Reduction",
        "created_at": FieldValue.serverTimestamp(),
      });

      // 🔹 Update stock in Firestore
      batch.update(itemRef, {
        "total_stock": newStock,
        "last_updated": FieldValue.serverTimestamp(),
      });

      await batch
          .commit(); // ✅ **Fix: Batch commit ensures both updates happen together**

      print(
          "✅ Stock reduced & log created: $quantity units removed from Item $itemId.");

      // ✅ **Fix: Recalculate stock after reducing to ensure accuracy**
      await _updateItemStock(itemId);

      // ✅ Log audit trail for stock reduction
      await _auditDb.logAudit(
        storeId: storeId,
        userId: userId ?? storeId, // ✅ Use actual userId if provided
        action: 'REDUCE_STOCK',
        entityType: 'inventory',
        entityId: itemId,
        description: 'Reduced stock by $quantity units. Reason: $reason',
        metadata: {
          'quantity': quantity,
          'reason': reason,
        },
      );
    } catch (e) {
      print("❌ Error reducing stock for item $itemId: $e");
      throw e;
    }
  }
}
