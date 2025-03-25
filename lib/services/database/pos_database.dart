import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class POSDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> processTransaction({
    required String storeId,
    required String userId,
    required List<Map<String, dynamic>> items,
    required double totalAmount,
    required double amountPaid,
    required String paymentMethod,
    String? customerId,
    required String customerName,
    required String storeOwnerId,
    DateTime? due_date,
  }) async {
    try {
      final transactionRef = _db.collection('transactions').doc();
      final String transactionId = transactionRef.id;
      double change =
          (amountPaid > totalAmount) ? (amountPaid - totalAmount) : 0.0;
      String status = (amountPaid >= totalAmount)
          ? "paid"
          : (amountPaid > 0.0 ? "partial" : "unpaid");

      // Create transaction
      await transactionRef.set({
        "storeId": storeId,
        "userId": userId,
        "customerId": customerId,
        "total_amount": totalAmount,
        "amount_paid": amountPaid,
        "change": change,
        "payment_method": paymentMethod,
        "status": status,
        "created_at": FieldValue.serverTimestamp(),
        "updated_at": FieldValue.serverTimestamp(),
      });

      // Add transaction items & update stock
      for (var item in items) {
        await _addTransactionItem(transactionId, item);
        await _updateItemStock(item['item_id'], item['quantity']);
      }

      // If payment is not complete, create a debt entry
      if (status != "paid" && customerId != null) {
        await _createDebtEntry(transactionId, customerId, storeId, totalAmount,
            amountPaid, due_date);
        await addDebtNotification(
            storeOwnerId: storeOwnerId,
            storeId: storeId,
            customerId: customerId,
            customerName: customerName,
            balance: totalAmount - amountPaid,
            dueDate: due_date);
        print("✅ New debt notification are added!");
      }
      print("cusotmer Id : $customerId");
      print("total amount : $totalAmount");
      print("recieved amount : $amountPaid");
      print("change : $due_date");
      print("✅ Transaction processed successfully: $transactionId");
    } catch (e) {
      print("❌ Error processing transaction: $e");
      throw e;
    }
  }

  Future<void> _addTransactionItem(
      String transactionId, Map<String, dynamic> item) async {
    try {
      final transactionItemRef = _db.collection('transaction_items').doc();

      await transactionItemRef.set({
        "transaction_id": transactionId,
        "item_id": item['item_id'],
        "quantity": item['quantity'],
        "unit_price": item['unit_price'],
        "total_price": item['quantity'] * item['unit_price'],
        "storeId": item['storeId'],
        "discount": item['discount'] ?? 0.0,
        "subtotal":
            (item['quantity'] * item['unit_price']) - (item['discount'] ?? 0.0),
      });

      print("✅ Transaction item added: ${item['item_id']}");
    } catch (e) {
      print("❌ Error adding transaction item: $e");
      throw e;
    }
  }

  Future<void> _updateItemStock(String itemId, int quantitySold) async {
    try {
      final itemRef = _db.collection('items').doc(itemId);
      DocumentSnapshot itemDoc = await itemRef.get();

      if (itemDoc.exists) {
        int currentStock = (itemDoc['total_stock'] ?? 0).toInt();
        int newStock = currentStock - quantitySold;

        await itemRef.update({
          "total_stock": newStock >= 0 ? newStock : 0,
          "last_updated": FieldValue.serverTimestamp(),
        });

        print("✅ Stock updated for item: $itemId | New stock: $newStock");
      } else {
        print("⚠️ Item not found: $itemId");
      }
    } catch (e) {
      print("❌ Error updating stock: $e");
      throw e;
    }
  }

  Future<void> _createDebtEntry(
      String transactionId,
      String customerId,
      String storeId,
      double totalAmount,
      double amountPaid,
      DateTime? due_date) async {
    try {
      final debtRef = _db.collection('debts').doc();
      double balance = totalAmount - amountPaid;
      String status = (amountPaid >= totalAmount)
          ? "paid"
          : (amountPaid > 0.0 ? "partial" : "unpaid");

      // ✅ Create the debt entry
      await debtRef.set({
        "storeId": storeId,
        "customerId": customerId,
        "transactionId": transactionId,
        "total_amount": totalAmount,
        "amount_paid": amountPaid,
        "balance": balance,
        "status": status,
        "created_at": FieldValue.serverTimestamp(),
        "updated_at": FieldValue.serverTimestamp(),
        "due_date": due_date ??
            Timestamp.fromDate(DateTime.now().add(Duration(days: 7))),
      });

      print("✅ Debt recorded for customer: $customerId | Balance: $balance");

      // ✅ Update the customer's total_debt field
      await _updateCustomerTotalDebt(customerId, balance);
    } catch (e) {
      print("❌ Error creating debt entry: $e");
      throw e;
    }
  }

  Future<void> _updateCustomerTotalDebt(
      String customerId, double newDebt) async {
    try {
      final customerRef = _db.collection('customers').doc(customerId);
      DocumentSnapshot customerDoc = await customerRef.get();

      if (customerDoc.exists) {
        double currentDebt = (customerDoc['total_debt'] ?? 0.0).toDouble();
        double updatedDebt = currentDebt + newDebt;

        await customerRef.update({
          "total_debt": updatedDebt,
        });

        print(
            "✅ Customer's total debt updated: $customerId | New Total Debt: $updatedDebt");
      } else {
        print("⚠️ Customer not found: $customerId");
      }
    } catch (e) {
      print("❌ Error updating customer's total debt: $e");
      throw e;
    }
  }

  Future<void> addDebtNotification({
    required String storeOwnerId,
    required String storeId,
    required String customerId,
    required String customerName,
    required double balance,
    DateTime? dueDate,
  }) async {
    try {
      // ✅ Check for missing fields
      if (storeOwnerId.isEmpty) {
        print("❌ Error: storeOwnerId is empty.");
        return;
      }
      if (storeId.isEmpty) {
        print("❌ Error: storeId is empty.");
        return;
      }
      if (customerId.isEmpty) {
        print("❌ Error: customerId is empty.");
        return;
      }
      if (customerName.isEmpty) {
        print("❌ Error: customerName is empty.");
        return;
      }
      if (balance.isNaN || balance < 0) {
        print("❌ Error: balance is invalid ($balance).");
        return;
      }
      if (dueDate == null) {
        print("❌ Error: dueDate is null. Using default value.");
        dueDate =
            DateTime.now().add(Duration(days: 7)); // Default 7-day due date
      }

      // ✅ Format date as "January 10, 2025"
      String formattedDueDate = DateFormat("MMMM d, y").format(dueDate);

      // ✅ Add notification to Firestore
      await _db.collection('notifications').add({
        "storeId": storeId,
        "userId": storeOwnerId, // ✅ Notify the store owner
        "title": "New Debt Added",
        "message":
            "$customerName has a new debt of ₱$balance. Due on: $formattedDueDate",
        "icon": "warning",
        "isUnread": true,
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Debt notification added for store owner: $storeOwnerId");
    } catch (e) {
      print("❌ Error adding debt notification: $e");
    }
  }

  
}
