import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:valgrow_ui/models/batch_details.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/models/debts_model.dart';
import 'package:valgrow_ui/models/history_model.dart';
import 'package:valgrow_ui/models/item_details.dart';
import 'package:valgrow_ui/models/store_profile.dart';
import 'package:valgrow_ui/models/user_profile.dart';
import 'package:valgrow_ui/services/database/database_service.dart';
import 'package:valgrow_ui/services/database/debts_database.dart';
import 'package:valgrow_ui/services/database/history_database.dart';
import 'package:valgrow_ui/services/database/inventory_database.dart';
import 'package:valgrow_ui/services/database/pos_database.dart';

class DatabaseProvider extends ChangeNotifier {
  final DatabaseService _db = DatabaseService();
  final InventoryDatabase _inventoryDatabase = InventoryDatabase();
  final POSDatabase _posDatabase = POSDatabase();
  final DebtsDatabase _debtsDatabase = DebtsDatabase();
  final HistoryDatabase _historyDatabase = HistoryDatabase();

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

  // list of store customers
  List<CustomerDetails> _customers = [];
  List<CustomerDetails> get customers => _customers;

  // List of debts with customer details
  List<Map<String, dynamic>> _debtsWithCustomers = [];
  List<Map<String, dynamic>> get debtsWithCustomers => _debtsWithCustomers;

  // Nearest due date
  DateTime? _nearestDueDate;
  DateTime? get nearestDueDate => _nearestDueDate;

  // List of debts for a specific customer
  List<DebtDetails> _customerDebts = [];
  List<DebtDetails> get customerDebts => _customerDebts;

  CustomerDetails? _selectedCustomer;
  List<DebtDetails> _selectedCustomerDebts = [];

  CustomerDetails? get selectedCustomer => _selectedCustomer;
  List<DebtDetails> get selectedCustomerDebts => _selectedCustomerDebts;
  bool _isLoadingDebts = false;
  bool get isLoadingDebts => _isLoadingDebts;

  // history list
  List<TransactionHistory> _transactionHistory = [];
  List<TransactionHistory> get transactionHistory => _transactionHistory;
  bool _isLoadingTransactions = false;
  bool get isLoadingTransactions => _isLoadingTransactions;

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

  // Regenerate a new store code and update it
  Future<void> updateStoreCode() async {
    try {
      if (_store == null) return;
      await _db.generateAndUpdateStoreCode(_store!.storeId);
      await fetchUserProfile(_user!.uid);
      await fetchStoreProfile(_user!.storeId);
      notifyListeners();
    } catch (e) {
      print("Error updating store name: $e");
    }
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

  // Clears the basket when POSPage is closed
  void clearBasket() {
    _basket.clear();
    notifyListeners();
  }

  // Add item to basket (track quantity separately)
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

  // Remove item or decrease quantity
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

  // Completely remove an item from the basket
  void complteRemoveFromBasket(String barcode) {
    _basket.removeWhere((item) => item.barcode == barcode);
    notifyListeners();
  }

  // Process a transaction (Paid or Unpaid)
  Future<void> processPOS({
    required double totalAmount,
    required double amountPaid,
    required String paymentMethod,
    String? customerId,
    required bool isDebt,
    DateTime? due_date,
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
        due_date: due_date ?? null,
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

  /*
    Debts Tracking System
  */

  Future<void> fetchCustomersByStoreId() async {
    _isLoading = true;
    notifyListeners();
    try {
      _customers =
          await _debtsDatabase.fetchAllCustomersByStoreId(_store!.storeId);
    } catch (e) {
      print("❌ Error fetching customers: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Add new customer
  Future<bool> addNewCustomer({
    required String name,
    required String phone,
    required String imageUrl,
  }) async {
    _isLoading = true;
    notifyListeners();
    try {
      if (_store == null) {
        print("❌ Error: Store is null, cannot add customer.");
        return false;
      }

      CustomerDetails? newCustomer = await _debtsDatabase.addNewCustomer(
        storeId: _store!.storeId,
        name: name,
        phone: phone,
        imageUrl: imageUrl,
      );

      if (newCustomer != null) {
        fetchCustomersByStoreId();
        notifyListeners();
        print("✅ New customer added: ${newCustomer.name}");
        return true;
      } else {
        print("⚠️ Customer already exists!");
        return false;
      }
    } catch (e) {
      print("❌ Error adding new customer: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Fetch customers and group their debts, finding the nearest due date
  Future<void> fetchDebtsWithCustomerInfo() async {
    _isLoading = true;
    notifyListeners();

    try {
      if (_store == null) {
        print("❌ Error: Store is null, cannot fetch debts.");
        return;
      }

      // ✅ Call method from DebtsDatabase to fetch customers with nearest due dates
      List<Map<String, dynamic>> customersWithDueDates =
          await _debtsDatabase.fetchDebtsGroupedByCustomer(_store!.storeId);

      _debtsWithCustomers =
          customersWithDueDates; // ✅ Store grouped customer debts
      _nearestDueDate = _calculateNearestDueDate(
          customersWithDueDates); // ✅ Calculate the overall nearest due date

      print(
          "✅ Fetched ${_debtsWithCustomers.length} customers with due dates.");
      print("✅ Overall Nearest Due Date: $_nearestDueDate");
    } catch (e) {
      print("❌ Error fetching customers with debt details: $e");
      _debtsWithCustomers = []; // ✅ Reset debts on error
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Helper method to find the overall nearest due date across all customers' debts
  DateTime? _calculateNearestDueDate(
      List<Map<String, dynamic>> customersWithDueDates) {
    DateTime? nearestDate;
    for (var entry in customersWithDueDates) {
      DateTime? customerDueDate = entry["nearestDueDate"];
      if (customerDueDate != null &&
          (nearestDate == null || customerDueDate.isBefore(nearestDate))) {
        nearestDate = customerDueDate;
      }
    }
    return nearestDate;
  }

  // ✅ Fetch debts for a specific customer by ID
  Future<void> fetchDebtsForCustomer(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ✅ Call the method from DebtsDatabase
      List<DebtDetails> debts =
          await _debtsDatabase.fetchDebtsByCustomerId(customerId);

      _customerDebts = debts; // ✅ Store fetched debts
      print("✅ Fetched ${debts.length} debts for customer ID: $customerId");
    } catch (e) {
      print("❌ Error fetching debts for customer ID $customerId: $e");
      _customerDebts = []; // Reset list if error occurs
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

// ✅ Store transaction items
  List<Map<String, dynamic>> _transactionItems = [];
  List<Map<String, dynamic>> get transactionItems => _transactionItems;

  // ✅ Loading status for transactions
  bool _isLoadingTransactionItems = false;
  bool get isLoadingTransactionItems => _isLoadingTransactionItems;

  /// ✅ Fetch and store items in a specific transaction
  Future<void> fetchTransactionItems(String transactionId) async {
    _isLoadingTransactionItems = true;
    notifyListeners();

    try {
      _transactionItems =
          await _debtsDatabase.fetchTransactionItems(transactionId);
      print(
          "✅ Stored ${_transactionItems.length} transaction items in provider.");
    } catch (e) {
      print("❌ Error fetching transaction items: $e");
      _transactionItems = []; // Reset on failure
    } finally {
      _isLoadingTransactionItems = false;
      notifyListeners();
    }
  }

  Future<bool> processDebtPayment({
    required String debtId,
    required double amountPaid,
    required String paymentMethod,
    required String storeId,
    required String customerId,
  }) async {
    _isLoading = true;
    notifyListeners();

    try {
      bool success = await _debtsDatabase.processDebtPayment(
        debtId: debtId,
        amountPaid: amountPaid,
        paymentMethod: paymentMethod,
        storeId: storeId,
        customerId: customerId,
      );

      if (success) {
        // ✅ Refresh customer's debts & store details
        await fetchDebtsForCustomer(customerId);
        await fetchStoreProfile(storeId);
      }

      return success;
    } catch (e) {
      print("❌ Error processing debt payment: $e");
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ✅ Public Method to Manually Set Customer
  void updateSelectedCustomer(CustomerDetails customer) {
    _selectedCustomer = customer;
    notifyListeners();
  }

  /// ✅ Update Selected Customer After Payment
  Future<void> updateSelectedCustomerAfterPayment(String customerId) async {
    _isLoading = true;
    notifyListeners();

    try {
      // ✅ Fetch updated customer details
      CustomerDetails? updatedCustomer =
          await _debtsDatabase.fetchCustomerById(customerId);

      if (updatedCustomer != null) {
        _selectedCustomer = updatedCustomer;
        notifyListeners();
      }
    } catch (e) {
      print("❌ Error updating selected customer: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearSelectedCustomer() {
    _selectedCustomer = null;
    _selectedCustomerDebts = [];
  }

  /*
  
   History System
  
   */

  Future<void> fetchTransactionHistory(String storeId) async {
    _isLoadingTransactions = true;
    notifyListeners();
    try {
      _transactionHistory =
          await _historyDatabase.getAllTransactionHistory(storeId);
      print("✅ Fetched ${_transactionHistory.length} transactions.");
    } catch (e) {
      print("❌ Error fetching transactions: $e");
      _transactionHistory = [];
    } finally {
      _isLoadingTransactions = false;
      notifyListeners();
    }
  }
  
}
