import 'package:cloud_firestore/cloud_firestore.dart';

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
    } catch (e) {
      print("❌ Error creating debt entry: $e");
      throw e;
    }
  }
}
