  import 'package:cloud_firestore/cloud_firestore.dart';
  import 'package:valgrow_ui/models/history_model.dart';

  class HistoryDatabase {
    final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Stream transaction history (Sales, Debts, Debt Payments) one by one
  Stream<TransactionHistory> streamTransactionHistory(String storeId, {int? limit}) async* {
    try {
      // Stream Sales & Debt Transactions with optional limit
      Query transactionQuery = _db
          .collection('transactions')
          .where('storeId', isEqualTo: storeId)
          .orderBy('created_at', descending: true);
      
      if (limit != null) {
        transactionQuery = transactionQuery.limit(limit);
      }
      
      QuerySnapshot transactionSnapshot = await transactionQuery.get();

      // Yield transactions one by one as they're processed
      for (var doc in transactionSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

        String transactionType = _determineTransactionType(data);

        List<TransactionItem> items = await _getTransactionItems(doc.id);

        String? customerName;
        if (transactionType == "Debts" && data['customerId'] != null) {
          customerName = await _getCustomerName(data['customerId']);
        }

        yield TransactionHistory(
          transactionId: doc.id,
          storeId: data['storeId'] ?? '',
          totalAmount: (data['total_amount'] ?? 0.0).toDouble(),
          createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          transactionType: transactionType,
          items: items,
          customerName: customerName,
          debtPaymentMethod: null,
        );
      }

      // Stream Debt Payments with optional limit
      Query debtPaymentQuery = _db
          .collection('debt_payments')
          .where('storeId', isEqualTo: storeId)
          .orderBy('payment_date', descending: true);
      
      if (limit != null) {
        debtPaymentQuery = debtPaymentQuery.limit(limit);
      }
      
      QuerySnapshot debtPaymentSnapshot = await debtPaymentQuery.get();

      // Yield debt payments one by one
      for (var doc in debtPaymentSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

        yield TransactionHistory(
          transactionId: doc.id,
          storeId: data['storeId'] ?? '',
          totalAmount: (data['amount_paid'] ?? 0.0).toDouble(),
          createdAt: (data['payment_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          transactionType: "Debt Payment",
          items: [],
          customerName: data['customerId'] ?? "Unknown",
          debtPaymentMethod: data['payment_method'] ?? "Unknown",
        );
      }

    } catch (e) {
      print("❌ Error streaming transaction history: $e");
    }
  }

  /// ✅ Fetch all transaction history (Sales, Debts, Debt Payments) in a SINGLE LIST
  Future<List<TransactionHistory>> getAllTransactionHistory(String storeId, {int? limit}) async {
  try {
    List<TransactionHistory> historyList = [];

    // Fetch Sales & Debt Transactions with optional limit
    Query transactionQuery = _db
        .collection('transactions')
        .where('storeId', isEqualTo: storeId)
        .orderBy('created_at', descending: true);
    
    if (limit != null) {
      transactionQuery = transactionQuery.limit(limit);
    }
    
    QuerySnapshot transactionSnapshot = await transactionQuery.get();      for (var doc in transactionSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

        String transactionType = _determineTransactionType(data);

        List<TransactionItem> items = await _getTransactionItems(doc.id);

        String? customerName;
        if (transactionType == "Debts" && data['customerId'] != null) {
          customerName = await _getCustomerName(data['customerId']);
        }

        historyList.add(TransactionHistory(
          transactionId: doc.id,
          storeId: data['storeId'] ?? '',
          totalAmount: (data['total_amount'] ?? 0.0).toDouble(),
          createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
          transactionType: transactionType,
          items: items,
          customerName: customerName,
          debtPaymentMethod: null,
        ));
      }

    // Fetch Debt Payments with optional limit
    Query debtPaymentQuery = _db
        .collection('debt_payments')
        .where('storeId', isEqualTo: storeId)
        .orderBy('payment_date', descending: true);
    
    if (limit != null) {
      debtPaymentQuery = debtPaymentQuery.limit(limit);
    }
    
    QuerySnapshot debtPaymentSnapshot = await debtPaymentQuery.get();      for (var doc in debtPaymentSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

        historyList.add(TransactionHistory(
          transactionId: doc.id,
          storeId: data['storeId'] ?? '',
          totalAmount: (data['amount_paid'] ?? 0.0).toDouble(),
          createdAt: (data['payment_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          transactionType: "Debt Payment",
          items: [],
          customerName: data['customerId'] ?? "Unknown",
          debtPaymentMethod: data['payment_method'] ?? "Unknown",
        ));
      }

      // Sort by date
      historyList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      // ===== LOG THE RESULT HERE =====
      for (var tx in historyList) {
        print('--- Transaction ID: ${tx.transactionId}');
        print('Type: ${tx.transactionType}');
        print('Total Amount: ₱${tx.totalAmount}');
        print('Date: ${tx.createdAt}');
        if (tx.customerName != null) print('Customer: ${tx.customerName}');
        if (tx.debtPaymentMethod != null) print('Payment Method: ${tx.debtPaymentMethod}');
        if (tx.items.isNotEmpty) {
          print('Items:');
          for (var item in tx.items) {
            print(' - ${item.name} x${item.quantity}') ;
          }
        } else {
          print('No items.');
        }
        print('----------------------');
      }

      print("✅ Fetched ${historyList.length} total transactions (including debts & payments).");

      return historyList;
    } catch (e) {
      print("❌ Error fetching full transaction history: $e");
      return [];
    }
  }


    Future<List<TransactionItem>> _getTransactionItems(
        String transactionId) async {
      try {
        QuerySnapshot itemSnapshot = await _db
            .collection('transaction_items')
            .where('transaction_id', isEqualTo: transactionId)
            .get();

        List<TransactionItem> items = [];

        for (var doc in itemSnapshot.docs) {
          final data = doc.data() as Map<String, dynamic>;

          // Get item_id from transaction_item document
          String itemId = data['item_id'] ?? '';

          // Fetch item details from /items/{itemId} to get the name
          DocumentSnapshot itemDoc =
              await _db.collection('items').doc(itemId).get();

          String itemName = '';
          if (itemDoc.exists) {
            final itemData = itemDoc.data() as Map<String, dynamic>? ?? {};
            itemName = itemData['item_name'] ?? '';
          }

          // Create TransactionItem with name
          items.add(TransactionItem(
            itemId: itemId,
            name: itemName,
            quantity: (data['quantity'] ?? 0).toInt(),
            unitPrice: (data['unit_price'] ?? 0.0).toDouble(),
            totalPrice: (data['total_price'] ?? 0.0).toDouble(),
            discount: data['discount'] != null
                ? (data['discount'] as num).toDouble()
                : null,
          ));
        }

        return items;
      } catch (e) {
        print("❌ Error fetching transaction items for $transactionId: $e");
        return [];
      }
    }

    /// ✅ Determine transaction type (Debts, Debt Payment, Sales)
    String _determineTransactionType(Map<String, dynamic> transaction) {
      if (transaction.containsKey('payment_method')) {
        String paymentMethod =
            transaction['payment_method'].toString().toLowerCase();

        if (paymentMethod == "debt") {
          return "Debts"; // ✅ If payment was "debt", categorize as Debts
        } else if (["cash", "gcash"].contains(paymentMethod)) {
          return "Sales"; // ✅ If cash/gcash, it's a normal sale
        }
      }
      return "Unknown";
    }

    /// ✅ Fetch customer name if transaction is linked to a customer
    Future<String?> _getCustomerName(String customerId) async {
      try {
        DocumentSnapshot customerDoc =
            await _db.collection('customers').doc(customerId).get();
        return customerDoc.exists ? customerDoc['name'] : null;
      } catch (e) {
        print("❌ Error fetching customer name: $e");
        return null;
      }
    }
  }
