import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class POSDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<String?> processTransaction({
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
    String? reference_number,
  }) async {
    try {
      // 🔍 Validate required fields before proceeding
      if (storeId.isEmpty || userId.isEmpty || paymentMethod.isEmpty) {
        throw Exception("❌ ERROR: Required fields are missing!");
      }

      final transactionRef = _db.collection('transactions').doc();
      final String transactionId = transactionRef.id;
      double change =
          (amountPaid >= totalAmount) ? (amountPaid - totalAmount) : 0.0;

      // Determine transaction status
      String status = (amountPaid >= totalAmount)
          ? "paid"
          : (amountPaid > 0.0 ? "partial" : "unpaid");

      print("🔹 Processing Transaction...");
      print("Transaction ID: $transactionId");
      print("Store ID: $storeId");
      print("User ID: $userId");
      print("Total Amount: $totalAmount");
      print("Amount Paid: $amountPaid");
      print("Change: $change");
      print("Payment Method: $paymentMethod");
      print("Transaction Status: $status");
      print("Customer ID: ${customerId ?? '⚠️ No Customer (Guest)'}");
      print("Customer Name: $customerName");

      if (items.isEmpty) {
        throw Exception("❌ ERROR: No items found in the transaction!");
      }

      // 🔹 Create Transaction in Firestore
      await transactionRef.set({
        "storeId": storeId,
        "userId": userId,
        "customerId": customerId ?? "guest",
        "total_amount": totalAmount,
        "amount_paid": amountPaid,
        "change": change,
        "payment_method": paymentMethod,
        "status": status,
        "created_at": FieldValue.serverTimestamp(),
        "updated_at": FieldValue.serverTimestamp(),
        "reference_number": reference_number ?? "",
      });

      // 🔹 Add transaction items & update stock
      for (var item in items) {
        if (item['item_id'] == null || item['quantity'] == null) {
          print("⚠️ Skipping invalid item: $item");
          continue;
        }
        print(
            "📦 Processing Item: ${item['item_id']} - Quantity: ${item['quantity']}");
        await _addTransactionItem(transactionId, item);
        await _updateItemStock(item['item_id'], item['quantity']);
      }

      // 🔹 Handle Debt Entry if the transaction is not fully paid
      if (status != "paid" && customerId != null) {
        print("📝 Creating Debt Entry for Customer: $customerId");
        await _createDebtEntry(transactionId, customerId, storeId, totalAmount,
            amountPaid, due_date, reference_number);
        await addDebtNotification(
          storeOwnerId: storeOwnerId,
          storeId: storeId,
          customerId: customerId,
          customerName: customerName,
          balance: totalAmount - amountPaid,
          dueDate: due_date,
        );
        print("✅ New Debt Notification Added!");
      }

      print("✅ Transaction Processed Successfully: $transactionId");

      // ✅ Return the Transaction ID
      return transactionId;
    } catch (e) {
      print("❌ ERROR processing transaction: $e");
      return null; // Return null in case of an error
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

        // 🔥 Insert a notification if stock goes to 0
        if (newStock == 0) {
          await _insertLowStockNotification(
              itemId, itemDoc['item_name'], itemDoc['storeId']);
        }
      } else {
        print("⚠️ Item not found: $itemId");
      }
    } catch (e) {
      print("❌ Error updating stock: $e");
      throw e;
    }
  }

  /// 🔥 **Insert Notification for Out of Stock Item**
  Future<void> _insertLowStockNotification(
      String itemId, String itemName, String storeId) async {
    try {
      final notificationRef = _db.collection('notifications').doc();

      await notificationRef.set({
        "title": "Stock Alert",
        "message": "The item '$itemName' is out of stock!",
        "icon": "warning", // Icon name (use mapping in UI)
        "isUnread": true,
        "storeId": storeId,
        "userId": storeId, // Notify store owner
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("🚨 Low stock notification sent for: $itemName ($itemId)");
    } catch (e) {
      print("❌ Error inserting low stock notification: $e");
      throw e;
    }
  }

 Future<void> _createDebtEntry(
  String transactionId,
  String customerId,
  String storeId,
  double totalAmount,
  double amountPaid,
  DateTime? due_date,
  String? reference_number
) async {
  try {
    final debtRef = _db.collection('debts').doc();
    final String debtId = debtRef.id;
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
          Timestamp.fromDate(DateTime.now().add(Duration(days: 14))),
    });

    print("✅ Debt recorded for customer: $customerId | Balance: $balance");

    // ✅ Update the customer's total_debt field
    await _updateCustomerTotalDebt(customerId, balance);

    // ✅ If some amount was paid at the time of debt creation, log it as a payment
    if (amountPaid > 0) {
      await _insertInitialDebtPayment(
        debtId: debtId,
        transactionId: transactionId,
        storeId: storeId,
        amountPaid: amountPaid,
        reference_number: reference_number ?? ""
      );
    }
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

  Future<Map<String, dynamic>?> getTransactionDetails(
      String transactionId) async {
    try {
      print("🔍 Fetching details for Transaction ID: $transactionId");

      // 🔹 Fetch the transaction details
      DocumentSnapshot transactionDoc =
          await _db.collection('transactions').doc(transactionId).get();

      if (!transactionDoc.exists) {
        print("❌ Transaction not found: $transactionId");
        return null;
      }

      Map<String, dynamic> transactionData =
          transactionDoc.data() as Map<String, dynamic>;

      // 🔹 Fetch all items in the transaction
      List<Map<String, dynamic>> items = [];

      QuerySnapshot itemsQuery = await _db
          .collection('transaction_items')
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      for (var itemDoc in itemsQuery.docs) {
        Map<String, dynamic> itemData = itemDoc.data() as Map<String, dynamic>;

        // ✅ Fetch item details from the "items" collection
        DocumentSnapshot itemDetailsDoc =
            await _db.collection('items').doc(itemData['item_id']).get();

        if (itemDetailsDoc.exists) {
          Map<String, dynamic> itemDetails =
              itemDetailsDoc.data() as Map<String, dynamic>;
          itemData['item_name'] = itemDetails['item_name']; // ✅ Add item name
        } else {
          itemData['item_name'] = "Unknown Item"; // ✅ Default if not found
        }

        items.add(itemData);
      }

      // 🔹 Fetch customer details if customerId exists and is not a guest
      Map<String, dynamic>? customerData;
      if (transactionData['customerId'] != null &&
          transactionData['customerId'] != "guest") {
        DocumentSnapshot customerDoc = await _db
            .collection('customers')
            .doc(transactionData['customerId'])
            .get();

        if (customerDoc.exists) {
          customerData = customerDoc.data() as Map<String, dynamic>;
        }
      }

      // 🔹 Fetch debt details if the transaction is unpaid or partial
      Map<String, dynamic>? debtData;
      if (transactionData['status'] == "unpaid" ||
          transactionData['status'] == "partial") {
        QuerySnapshot debtQuery = await _db
            .collection('debts')
            .where('transactionId', isEqualTo: transactionId)
            .get();

        if (debtQuery.docs.isNotEmpty) {
          debtData = debtQuery.docs.first.data() as Map<String, dynamic>;
        }
      }

      // 🔹 Fetch debt payments associated with this transaction
      List<Map<String, dynamic>> debtPayments = [];
      QuerySnapshot debtPaymentQuery = await _db
          .collection('debt_payments')
          .where('transactionId', isEqualTo: transactionId)
          .get();

      if (debtPaymentQuery.docs.isNotEmpty) {
        for (var paymentDoc in debtPaymentQuery.docs) {
          Map<String, dynamic> paymentData =
              paymentDoc.data() as Map<String, dynamic>;

          // ✅ Fetch corresponding original transaction if available
          if (paymentData['transactionId'] != null) {
            DocumentSnapshot originalTransactionDoc = await _db
                .collection('transactions')
                .doc(paymentData['transactionId'])
                .get();

            if (originalTransactionDoc.exists) {
              paymentData['original_transaction'] =
                  originalTransactionDoc.data() as Map<String, dynamic>;
            }
          }

          debtPayments.add(paymentData);
        }
      }

      // 🔹 If this is a debt payment, fetch original transaction details
      if (transactionData['status'] == 'paid' && debtPayments.isNotEmpty) {
        QuerySnapshot linkedDebtQuery = await _db
            .collection('debts')
            .where('transactionId', isEqualTo: transactionId)
            .get();

        if (linkedDebtQuery.docs.isNotEmpty) {
          Map<String, dynamic> linkedDebt =
              linkedDebtQuery.docs.first.data() as Map<String, dynamic>;

          DocumentSnapshot originalTransactionDoc = await _db
              .collection('transactions')
              .doc(linkedDebt['transactionId'])
              .get();

          if (originalTransactionDoc.exists) {
            Map<String, dynamic> originalTransactionData =
                originalTransactionDoc.data() as Map<String, dynamic>;

            // ✅ Fetch original transaction items
            QuerySnapshot originalItemsQuery = await _db
                .collection('transaction_items')
                .where('transaction_id', isEqualTo: linkedDebt['transactionId'])
                .get();

            List<Map<String, dynamic>> originalItems = [];

            for (var originalItemDoc in originalItemsQuery.docs) {
              Map<String, dynamic> originalItemData =
                  originalItemDoc.data() as Map<String, dynamic>;

              // ✅ Fetch item names for original transaction
              DocumentSnapshot itemDetailsDoc = await _db
                  .collection('items')
                  .doc(originalItemData['item_id'])
                  .get();

              if (itemDetailsDoc.exists) {
                Map<String, dynamic> itemDetails =
                    itemDetailsDoc.data() as Map<String, dynamic>;
                originalItemData['item_name'] = itemDetails['item_name'];
              } else {
                originalItemData['item_name'] = "Unknown Item";
              }

              originalItems.add(originalItemData);
            }

            // ✅ Merge original transaction details
            transactionData['original_transaction'] = originalTransactionData;
            transactionData['original_items'] = originalItems;
          }
        }
      }

      // 🔹 Combine all the fetched data into a single map
      Map<String, dynamic> transactionDetails = {
        "transaction": transactionData,
        "items": items, // ✅ Includes item names
        "customer": customerData,
        "debt": debtData,
        "debt_payments": debtPayments.isNotEmpty ? debtPayments : null,
      };

      print("✅ Transaction details retrieved successfully!");
      return transactionDetails;
    } catch (e) {
      print("❌ Error fetching transaction details: $e");
      return null;
    }
  }

  Future<void> _insertInitialDebtPayment({
  required String debtId,
  required String transactionId,
  required String storeId,
  required double amountPaid,
   String? reference_number,
}) async {
  try {
    final paymentRef = _db.collection('debt_payments').doc();

    await paymentRef.set({
      'debt_id': debtId,
      'transactionId': transactionId,
      'storeId': storeId,
      'amount_paid': amountPaid,
      'payment_method': 'initial', // Tag as initial payment
      'payment_date': FieldValue.serverTimestamp(),
      'reference_number': reference_number ?? "", // Optional: leave blank or set default
    });

    print("💰 Initial debt payment recorded for debt: $debtId");
  } catch (e) {
    print("❌ Error inserting initial debt payment: $e");
    throw e;
  }
}

}
