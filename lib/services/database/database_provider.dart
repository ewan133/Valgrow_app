import 'package:flutter/material.dart';
import 'package:valgrow_ui/models/batch_details.dart';
import 'package:valgrow_ui/models/item_details.dart';
import 'package:valgrow_ui/models/store_profile.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/services/database/database_service.dart';
import 'package:valgrow_ui/services/database/inventory_database.dart';
import 'package:valgrow_ui/services/database/pos_database.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final InventoryDatabase _inventoryDatabase = InventoryDatabase();
  final POSDatabase _posDatabase = POSDatabase();

  // loading status
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // store and use user details
  UserProfile? _user;
  StoreProfile? _store;
  UserProfile? get user => _user;
  StoreProfile? get store => _store;

  // list of store items
  List<ItemDetails> _items = [];
  List<ItemDetails> get items => _items;

  // list of store items
  List<ItemBatch> _batch = [];
  List<ItemBatch> get batch => _batch;

  // list of POS items
  List<ItemDetails> _basket = [];
  List<ItemDetails> get basket => _basket;

  Future<void> fetchUserProfile(String uid) async {
    try {
      final userData = await _db.getCurrentUserInfo(uid);

      if (userData != null) {
        print(
            "Fetched User Data: ${userData.toMap()}"); // ✅ Prints readable JSON
        _user = userData;
        notifyListeners();
      } else {
        print("User data is null");
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
  }

  /// Fetch & Set Store Profile
  Future<void> fetchStoreProfile(String storeId) async {
    try {
      final storeData = await _db.getStoreInfo(storeId);
      if (storeData != null) {
        _store = storeData;
        notifyListeners();
      }
    } catch (e) {
      print("Error fetching store profile: $e");
    }
  }

  /// Update User Information & Notify
  Future<void> updateUser({
    String? phone,
    String? document,
  }) async {
    try {
      if (_user == null) return;

      //Update in Database
      if (phone != null) await _db.updatePhoneNumber(_user!.uid, phone);
      if (document != null) await _db.updateUserDocument(_user!.uid, document);

      //Update in Provider
      _user = _user!.copyWith(
        phone: phone ?? _user!.phone,
        document: document ?? _user!.document,
      );
      notifyListeners();
    } catch (e) {
      print("Error updating user: $e");
    }
  }

  /// Update Store Name & Notify
  Future<void> updateStoreName(String storeName) async {
    try {
      if (_store == null) return;

      await _db.updateStoreName(_store!.storeId, storeName);

      _store = _store!.copyWith(name: storeName);
      notifyListeners();
    } catch (e) {
      print("Error updating store name: $e");
    }
  }

  /// Clear data (useful for logout)
  void clearData() {
    _user = null;
    _store = null;
    _items = [];
    notifyListeners();
  }

  /*
    Inventory Management 
  */

  // Fetch items for a specific storeId
  Future<void> fetchItemsByStoreId() async {
    _isLoading = true;
    notifyListeners();
    try {
      _items = await _inventoryDatabase.getItemsByStoreId(_store!.storeId);
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // add new id
  Future<void> addNewItem(ItemDetails item) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _inventoryDatabase.addItem(item);
    } catch (e) {
      print("Error fetching items: $e");
    } finally {
      await fetchItemsByStoreId();
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Fetch batches for a specific item
  Future<void> fetchBatchByItemId(String itemId) async {
    _isLoading = true;
    notifyListeners();
    try {
      _batch = await _inventoryDatabase.getBatchesForItem(itemId);
    } catch (e) {
      print("❌ Error fetching batches: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Add a new batch and update item stock
  Future<void> addNewBatch(ItemBatch batch) async {
    _isLoading = true;
    notifyListeners();
    try {
      await _inventoryDatabase.addBatch(batch);
      await fetchItemsByStoreId(); // Refresh items to reflect updated stock
    } catch (e) {
      print("❌ Error adding batch: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Edit an existing item
  Future<void> editItem(ItemDetails updatedItem) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _inventoryDatabase.editItem(updatedItem);
      await fetchItemsByStoreId(); // Refresh items after update
      print("✅ Item updated successfully: ${updatedItem.itemId}");
    } catch (e) {
      print("❌ Error updating item: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }


  /*
    Point of Sale System
  */

  /// ✅ Clears the basket when POSPage is closed
  void clearBasket() {
    _basket.clear();
    notifyListeners();
  }

  /// ✅ Add item to basket (track quantity separately)
  void addToBasket(ItemDetails newItem) {
    int index = _basket.indexWhere((i) => i.barcode == newItem.barcode);

    if (index != -1) {
      // ✅ If item already exists, increase "total_stock" (as quantity in POS)
      _basket[index] = ItemDetails(
        itemId: _basket[index].itemId,
        item_name: _basket[index].item_name,
        regular_price: _basket[index].regular_price,
        unpaid_price: _basket[index].unpaid_price,
        category: _basket[index].category,
        unit: _basket[index].unit,
        barcode: _basket[index].barcode,
        item_image: _basket[index].item_image,
        storeId: _basket[index].storeId,
        total_stock: _basket[index].total_stock + 1, // ✅ Increase quantity
        last_updated: _basket[index].last_updated,
      );
    } else {
      // ✅ Add new item with total_stock as POS quantity (1)
      _basket.add(newItem);
    }

    notifyListeners(); // ✅ Update UI
  }

  /// ✅ Remove item or decrease quantity
  void removeFromBasket(String barcode) {
    int index = _basket.indexWhere((i) => i.barcode == barcode);

    if (index != -1) {
      if (_basket[index].total_stock > 1) {
        _basket[index] = ItemDetails(
          itemId: _basket[index].itemId,
          item_name: _basket[index].item_name,
          regular_price: _basket[index].regular_price,
          unpaid_price: _basket[index].unpaid_price,
          category: _basket[index].category,
          unit: _basket[index].unit,
          barcode: _basket[index].barcode,
          item_image: _basket[index].item_image,
          storeId: _basket[index].storeId,
          total_stock: _basket[index].total_stock - 1, // ✅ Decrease quantity
          last_updated: _basket[index].last_updated,
        );
      } else {
        _basket.removeAt(index); // ✅ Remove if quantity = 1
      }
    }

    notifyListeners();
  }

  /// ✅ Completely remove an item from the basket
  void complteRemoveFromBasket(String barcode) {
    _basket.removeWhere((item) => item.barcode == barcode);
    notifyListeners();
  }

  /// ✅ Process a transaction (Paid or Unpaid)
  Future<void> processPOS({
    required double totalAmount,
    required double amountPaid,
    required String paymentMethod,
    String? customerId,
    required bool isDebt,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _posDatabase.processTransaction(
        storeId: _store!.storeId,
        userId: _user!.uid,
        customerId: customerId,
        totalAmount: totalAmount,
        amountPaid: amountPaid,
        paymentMethod: paymentMethod,
        items: _basket
            .map((item) => {
                  "item_id": item.itemId,
                  "quantity": item.total_stock, // ✅ Using stock as POS quantity
                  "unit_price": isDebt
                      ? item.unpaid_price ?? 0.0 // ✅ Use unpaid price for debts
                      : item.regular_price ??
                          0.0, // ✅ Use regular price for paid transactions
                  "storeId": item.storeId,
                  "discount": 0.0, // Modify this if needed
                })
            .toList(),
      );

      // ✅ Clear basket after transaction
      fetchItemsByStoreId();
      clearBasket();
    } catch (e) {
      print("❌ Error processing POS transaction: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
}
