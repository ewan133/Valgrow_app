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

        if (!customerDebtsMap.containsKey(debt.customerId)) {
          customerDebtsMap[debt.customerId] = {
            "totalBalance": 0.0,
            "nearestDueDate": debt.dueDate,
            "debts": [],
          };
        }

        // ✅ Correctly sum the total balance per customer
        customerDebtsMap[debt.customerId]["totalBalance"] += debt.balance;

        if (debt.dueDate
            .isBefore(customerDebtsMap[debt.customerId]["nearestDueDate"])) {
          customerDebtsMap[debt.customerId]["nearestDueDate"] = debt.dueDate;
        }

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

  Future<bool> processDebtPayment({
    required String debtId,
    required double amountPaid,
    required String paymentMethod,
    required String storeId,
    required String customerId,
  }) async {
    final FirebaseFirestore _db = FirebaseFirestore.instance;
    final WriteBatch batch = _db.batch();

    try {
      // ✅ Fetch the debt document
      DocumentReference debtRef = _db.collection('debts').doc(debtId);
      DocumentSnapshot debtSnapshot = await debtRef.get();

      if (!debtSnapshot.exists) {
        print("❌ Error: Debt record not found.");
        return false;
      }

      Map<String, dynamic> debtData =
          debtSnapshot.data() as Map<String, dynamic>;

      double currentBalance = (debtData['balance'] ?? 0).toDouble();
      double totalAmount = (debtData['total_amount'] ?? 0).toDouble();
      double alreadyPaid = (debtData['amount_paid'] ?? 0).toDouble();
      String transactionId = debtData['transactionId'] ?? "";

      // ✅ Ensure the amountPaid is not greater than the balance
      if (amountPaid > currentBalance) {
        print("⚠️ Payment amount cannot exceed the remaining balance.");
        return false;
      }

      // ✅ Calculate new values
      double newBalance = currentBalance - amountPaid;
      double newTotalPaid = alreadyPaid + amountPaid;
      String newStatus = newBalance == 0 ? "paid" : "partial";

      // ✅ Create a new debt payment entry
      DocumentReference paymentRef = _db.collection('debt_payments').doc();
      batch.set(paymentRef, {
        'debt_id': debtId,
        'amount_paid': amountPaid,
        'payment_date': FieldValue.serverTimestamp(),
        'payment_method': paymentMethod,
        'storeId': storeId,
        'transactionId': transactionId.isNotEmpty ? transactionId : null,
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

      // ✅ (Optional) Update transaction status if needed
      if (newBalance == 0 && transactionId.isNotEmpty) {
        DocumentReference transactionRef =
            _db.collection('transactions').doc(transactionId);
        batch.update(transactionRef, {
          'status': 'paid',
          'updated_at': FieldValue.serverTimestamp(),
        });
      }

      // ✅ Commit all updates
      await batch.commit();
      print("✅ Debt payment processed successfully.");
      return true;
    } catch (e) {
      print("❌ Error processing debt payment: $e");
      return false;
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

  
}
