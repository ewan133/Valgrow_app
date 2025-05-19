import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/models/debts_model.dart';

class DebtsDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Fetch all customers by storeId (not just debt-related)
  Future<List<CustomerDetails>> fetchAllCustomersByStoreId(
      String storeId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('customers')
          .where('storeId',
              isEqualTo: storeId) // ✅ Get all customers for this store
          .get();

      List<CustomerDetails> customers = querySnapshot.docs.map((doc) {
        return CustomerDetails.fromDocument(doc);
      }).toList();

      for (var customer in customers) {
        print("✅ Customer ID: ${customer.customerId}");
        print("Name: ${customer.name}");
        print("Phone: ${customer.phone}");
        print("Total Debt: ₱${customer.totalDebt}");
        print("Store ID: ${customer.storeId}");
        print("------");
      }

      return customers; // ✅ Return the list of customers
    } catch (e) {
      print("❌ Error retrieving customers for storeId $storeId: $e");
      return []; // ✅ Always return an empty list on error instead of null
    }
  }

  /// ✅ Add a new customer to Firestore
  Future<CustomerDetails?> addNewCustomer({
    required String storeId,
    required String name,
    required String phone,
    required String imageUrl,
  }) async {
    try {
      // ✅ Check if a customer with the same phone number already exists
      QuerySnapshot existingCustomerSnapshot = await _db
          .collection('customers')
          .where('storeId', isEqualTo: storeId)
          .where('phone', isEqualTo: phone)
          .get();

      if (existingCustomerSnapshot.docs.isNotEmpty) {
        print("⚠️ Customer with phone $phone already exists.");
        return null; // Return null if customer already exists
      }

      // ✅ Create a new customer document
      DocumentReference newCustomerRef = _db.collection('customers').doc();

      CustomerDetails newCustomer = CustomerDetails(
        customerId: newCustomerRef.id,
        storeId: storeId,
        name: name,
        phone: phone,
        totalDebt: 0.0, // New customers start with zero debt
        imageUrl: imageUrl,
        lastTransactionDate: null, // No transaction yet
      );

      // ✅ Save the new customer to Firestore
      await newCustomerRef.set(newCustomer.toMap());

      print(
          "✅ New customer added: ${newCustomer.name} (ID: ${newCustomer.customerId})");
      return newCustomer;
    } catch (e) {
      print("❌ Error adding new customer: $e");
      throw e;
    }
  }

  /// ✅ Fetch all customers and their nearest debt due date
  Future<List<Map<String, dynamic>>> fetchDebtsGroupedByCustomer(
      String storeId) async {
    try {
      // ✅ Fetch all debts for the store
      QuerySnapshot debtSnapshot = await _db
          .collection('debts')
          .where('storeId', isEqualTo: storeId)
          .get();

      if (debtSnapshot.docs.isEmpty) {
        print("⚠️ No debts found for storeId: $storeId");
        return [];
      }

      // ✅ Group debts by customerId
      Map<String, dynamic> customerDebtsMap = {};

      for (var doc in debtSnapshot.docs) {
        DebtDetails debt = DebtDetails.fromDocument(doc);

        // ✅ Initialize the customer entry if it does not exist
        customerDebtsMap.putIfAbsent(
            debt.customerId,
            () => {
                  "totalBalance": 0.0,
                  "nearestDueDate": null, // ✅ Ensure this is always present
                  "debts": [],
                });

        // ✅ Accumulate total balance
        customerDebtsMap[debt.customerId]["totalBalance"] += debt.balance;

        // ✅ Ensure only unpaid/partial debts are considered for nearest due date
        if (debt.status != "paid") {
          if (customerDebtsMap[debt.customerId]["nearestDueDate"] == null ||
              debt.dueDate.isBefore(
                  customerDebtsMap[debt.customerId]["nearestDueDate"])) {
            customerDebtsMap[debt.customerId]["nearestDueDate"] = debt.dueDate;
          }
        }

        // ✅ Add debt to the list
        customerDebtsMap[debt.customerId]["debts"].add(debt);
      }

      // ✅ Fetch customer details for each grouped entry
      List<Map<String, dynamic>> groupedDebts = [];

      for (String customerId in customerDebtsMap.keys) {
        DocumentSnapshot customerDoc =
            await _db.collection('customers').doc(customerId).get();

        CustomerDetails? customer;
        if (customerDoc.exists) {
          customer = CustomerDetails.fromDocument(customerDoc);
        }

        groupedDebts.add({
          "customer": customer,
          "totalBalance": customerDebtsMap[customerId]["totalBalance"],
          "nearestDueDate": customerDebtsMap[customerId]["nearestDueDate"],
          "debts": customerDebtsMap[customerId]["debts"],
        });
      }

      print("✅ Total grouped debts fetched: ${groupedDebts.length}");
      return groupedDebts;
    } catch (e) {
      print(
          "❌ Error retrieving debts grouped by customer for storeId $storeId: $e");
      return [];
    }
  }

  Future<List<DebtDetails>> fetchDebtsByCustomerId(String customerId) async {
    try {
      // ✅ Fetch all debts for the given customer
      QuerySnapshot debtSnapshot = await _db
          .collection('debts')
          .where('customerId', isEqualTo: customerId)
          .orderBy('due_date',
              descending: false) // ✅ Sort by nearest due date first
          .get();

      if (debtSnapshot.docs.isEmpty) {
        print("⚠️ No debts found for customerId: $customerId");
        return [];
      }

      // ✅ Convert Firestore documents to a list of DebtDetails objects
      List<DebtDetails> debts = debtSnapshot.docs.map((doc) {
        return DebtDetails.fromDocument(doc);
      }).toList();

      print("✅ Fetched ${debts.length} debts for customerId: $customerId");

      return debts;
    } catch (e) {
      print("❌ Error retrieving debts for customerId $customerId: $e");
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchTransactionItems(
      String transactionId) async {
    try {
      // ✅ Fetch all items for the given transaction
      QuerySnapshot transactionItemsSnapshot = await _db
          .collection('transaction_items')
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      if (transactionItemsSnapshot.docs.isEmpty) {
        print("⚠️ No items found for transaction ID: $transactionId");
        return [];
      }

      List<Map<String, dynamic>> transactionItems = [];

      for (var doc in transactionItemsSnapshot.docs) {
        Map<String, dynamic> transactionItemData =
            doc.data() as Map<String, dynamic>;

        // ✅ Fetch item details from the "items" collection
        DocumentSnapshot itemDoc = await _db
            .collection('items')
            .doc(transactionItemData['item_id'])
            .get();
        Map<String, dynamic>? itemDetails =
            itemDoc.exists ? itemDoc.data() as Map<String, dynamic> : null;

        transactionItems.add({
          "transactionItem": transactionItemData,
          "itemDetails": itemDetails,
        });
      }

      print(
          "✅ Fetched ${transactionItems.length} items for transaction ID: $transactionId");

      return transactionItems;
    } catch (e) {
      print("❌ Error retrieving items for transaction ID $transactionId: $e");
      return [];
    }
  }

  Future<String?> processDebtPayment({
    required String debtId,
    required double amountPaid,
    required String paymentMethod,
    required String storeId,
    required String customerId,
     String? reference_number
  }) async {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    final WriteBatch batch = _db.batch();

    try {
      // ✅ Fetch the debt document
      DocumentReference debtRef = _db.collection('debts').doc(debtId);
      DocumentSnapshot debtSnapshot = await debtRef.get();

      if (!debtSnapshot.exists) {
        print("❌ Error: Debt record not found.");
        return null;
      }

      Map<String, dynamic> debtData =
          debtSnapshot.data() as Map<String, dynamic>;

      double currentBalance = (debtData['balance'] ?? 0).toDouble();
      double totalAmount = (debtData['total_amount'] ?? 0).toDouble();
      double alreadyPaid = (debtData['amount_paid'] ?? 0).toDouble();
      String transactionId =
          debtData['transactionId'] ?? ""; // ✅ Original Transaction ID

      // ✅ Ensure the amountPaid is not greater than the balance
      if (amountPaid > currentBalance) {
        print("⚠️ Payment amount cannot exceed the remaining balance.");
        return null;
      }

      // ✅ Calculate new values
      double newBalance = currentBalance - amountPaid;
      double newTotalPaid = alreadyPaid + amountPaid;
      String newStatus = newBalance == 0 ? "paid" : "partial";

      // ✅ Create a **debt payment entry** linked to the original transaction
      DocumentReference paymentRef = _db.collection('debt_payments').doc();
      batch.set(paymentRef, {
        'debt_id': debtId,
        'amount_paid': amountPaid,
        'payment_date': FieldValue.serverTimestamp(),
        'payment_method': paymentMethod,
        'storeId': storeId,
        'transactionId':
            transactionId,
        'reference_number':
            reference_number ?? "",
             // ✅ Link to the **original** transaction
      });

      // ✅ Update the debt document
      batch.update(debtRef, {
        'amount_paid': newTotalPaid,
        'balance': newBalance,
        'status': newStatus,
        'updated_at': FieldValue.serverTimestamp(),
        'last_payment_date': FieldValue.serverTimestamp(),
      });

      // ✅ Update customer's total debt
      DocumentReference customerRef =
          _db.collection('customers').doc(customerId);
      batch.update(customerRef, {
        'total_debt': FieldValue.increment(-amountPaid), // Reduce total debt
      });

      // ✅ (Optional) Update original transaction status if debt is fully paid
      if (newBalance == 0 && transactionId.isNotEmpty) {
        DocumentReference originalTransactionRef =
            _db.collection('transactions').doc(transactionId);
        batch.update(originalTransactionRef, {
          'status': 'paid',
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      // ✅ Commit all updates
      await batch.commit();

      print(
          "✅ Debt payment processed successfully. Transaction ID: $transactionId");
      return transactionId; // ✅ Return the **original** debt transaction ID
    } catch (e) {
      print("❌ Error processing debt payment: $e");
      return null;
    }
  }

  // ✅ Fetch a single customer by ID (for updating after payment)
  Future<CustomerDetails?> fetchCustomerById(String customerId) async {
    try {
      DocumentSnapshot doc =
          await _db.collection('customers').doc(customerId).get();

      if (!doc.exists) {
        print("⚠️ Customer not found (ID: $customerId)");
        return null;
      }

      return CustomerDetails.fromDocument(doc);
    } catch (e) {
      print("❌ Error fetching customer details: $e");
      return null;
    }
  }

  Future<void> addDebtPaymentNotification({
    required String storeOwnerId,
    required String storeId,
    required String customerId,
    required String customerName,
    required double amountPaid,
    required double remainingBalance,
  }) async {
    try {
      // ✅ Ensure required data is available
      if (storeOwnerId.isEmpty || storeId.isEmpty || customerId.isEmpty) {
        print(
            "❌ Error: Missing required fields for debt payment notification.");
        return;
      }

      // ✅ Add notification to Firestore
      await _db.collection('notifications').add({
        "storeId": storeId,
        "userId": storeOwnerId, // ✅ Notify the store owner
        "title": "Debt Payment Received",
        "message":
            "$customerName made a payment of ₱$amountPaid. Remaining Balance: ₱$remainingBalance.",
        "icon": "payments",
        "isUnread": true,
        "timestamp": FieldValue.serverTimestamp(),
      });

      print("✅ Debt payment notification added for owner: $storeOwnerId");
    } catch (e) {
      print("❌ Error adding debt payment notification: $e");
    }
  }

  Future<void> fileCustomerReport({
    required String storeId,
    required String reportedId,
    required String customerName,
    required String reportReason,
    required String reportedByUserId,
  }) async {
    try {
      final now = DateTime.now();
      final yesterday = now.subtract(const Duration(hours: 24));

      // 🔍 Check for duplicate reports within 24 hours
      final existingQuery = await _db
          .collection('admin_reports')
          .where('storeId', isEqualTo: storeId)
          .where('respondent', isEqualTo: reportedId) // ✅ Fixed field
          .where('complainant', isEqualTo: reportedByUserId) // ✅ Fixed field
          .where('status', isEqualTo: 'pending')
          .get();

      final recentDuplicate = existingQuery.docs.any((doc) {
        final data = doc.data();
        final timestamp = (data['timestamp'] as Timestamp?)?.toDate();
        final reason = data['reason'] as String? ?? '';

        return timestamp != null &&
            timestamp.isAfter(yesterday) &&
            reason.trim() == reportReason.trim();
      });

      if (recentDuplicate) {
        print("⚠️ Duplicate report detected. Skipping report submission.");
        return;
      }

      // 📝 Proceed with filing the report
      final reportRef = _db.collection('admin_reports').doc();

      await reportRef.set({
        'reportId': reportRef.id,
        'storeId': storeId,
        'complainant': reportedByUserId,
        'respondent': reportedId,
        'respondentName': customerName,
        'reason': reportReason,
        'timestamp': Timestamp.now(),
        'status': 'pending',
        'reportCategory': 'Debt Dispute',
        'type': 'Business to Customer',
      });

      print("✅ Customer report filed successfully for $customerName");
    } catch (e) {
      print("❌ Error filing customer report: $e");
    }
  }

  /// ✅ Update customer details (name, phone, image)
  Future<CustomerDetails?> updateCustomerDetails({
    required String customerId,
    String? name,
    String? phone,
    String? imageUrl,
  }) async {
    try {
      final customerRef = _db.collection('customers').doc(customerId);
      final Map<String, dynamic> updates = {};

      if (name != null) updates['name'] = name;
      if (phone != null) updates['phone'] = phone;
      if (imageUrl != null) updates['imageUrl'] = imageUrl;

      if (updates.isEmpty) {
        print("⚠️ No changes provided for update.");
        return null;
      }

      await customerRef.update(updates);
      print("✅ Customer $customerId updated successfully.");

      // 🔁 Fetch and return the updated customer document using fromDocument
      final updatedDoc = await customerRef.get();
      if (updatedDoc.exists) {
        return CustomerDetails.fromDocument(updatedDoc);
      } else {
        print("⚠️ Updated document not found.");
        return null;
      }
    } catch (e) {
      print("❌ Error updating customer details: $e");
      rethrow;
    }
  }
}
