import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/models/batch_details.dart';
import 'package:valgrow_ui/models/item_details.dart';

class InventoryDatabase {
  final _db = FirebaseFirestore.instance;

  Future<void> addItem(ItemDetails item) async {
    try {
      // Reference to Firestore collection
      final itemRef = _db.collection('items').doc();

      // Convert the item to a Map and remove the 'itemId' field
      Map<String, dynamic> itemMap = item.toMap();
      itemMap.remove(
          'itemId'); // Remove the itemId from the map before adding to Firestore

      // Add the remaining fields to Firestore
      await itemRef.set(itemMap);

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

  Future<void> addBatch(ItemBatch batch) async {
    try {
      // Reference to Firestore batch collection
      final batchRef = _db.collection('item_batch').doc();

      // Convert batch to a Map and remove the 'batchId' field before adding
      Map<String, dynamic> batchMap = batch.toMap();
      batchMap.remove('batchId');

      // Add the batch to Firestore
      await batchRef.set(batchMap);

      print("✅ Batch added successfully for item: ${batch.itemId}");

      // ✅ Update total_stock of the item
      await _updateItemStock(batch.itemId, batch.quantity);
    } catch (e) {
      print("❌ Error adding batch: $e");
      throw e;
    }
  }

  Future<void> _updateItemStock(String itemId, int addedQuantity) async {
    try {
      // Reference to the item document
      final itemRef = _db.collection('items').doc(itemId);

      // Fetch the current total_stock
      DocumentSnapshot itemDoc = await itemRef.get();
      if (itemDoc.exists) {
        int currentStock = (itemDoc['total_stock'] ?? 0).toInt();
        int newStock = currentStock + addedQuantity; // Add new batch quantity

        // Update the total_stock in Firestore
        await itemRef.update(
          {'total_stock': newStock, 'last_updated': DateTime.now()},
        );

        print("✅ Updated total_stock for item $itemId: $newStock");
      } else {
        print("⚠️ Item not found: $itemId");
      }
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
}
