import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/models/history_model.dart';

class HistoryDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Fetch all transaction history (Sales, Debts, Debt Payments) in a SINGLE LIST
  Future<List<TransactionHistory>> getAllTransactionHistory(String storeId) async {
    try {
      List<TransactionHistory> historyList = [];

      // ✅ Fetch Sales & Debt Transactions
      QuerySnapshot transactionSnapshot = await _db
          .collection('transactions')
          .where('storeId', isEqualTo: storeId)
          .orderBy('created_at', descending: true)
          .get();

      for (var doc in transactionSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

        // ✅ Determine transaction type (Sales or Debts)
        String transactionType = _determineTransactionType(data);

        // ✅ Fetch transaction items
        List<TransactionItem> items = await _getTransactionItems(doc.id);

        // ✅ Fetch customer name if it's a debt transaction
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
          customerName: customerName, // ✅ Include customer name for debts
          debtPaymentMethod: null, // ✅ Only relevant for Debt Payments
        ));
      }

      // ✅ Fetch Debt Payments
      QuerySnapshot debtPaymentSnapshot = await _db
          .collection('debt_payments')
          .where('storeId', isEqualTo: storeId)
          .orderBy('payment_date', descending: true)
          .get();

      for (var doc in debtPaymentSnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>? ?? {};

        historyList.add(TransactionHistory(
          transactionId: doc.id,
          storeId: data['storeId'] ?? '',
          totalAmount: (data['amount_paid'] ?? 0.0).toDouble(),
          createdAt: (data['payment_date'] as Timestamp?)?.toDate() ?? DateTime.now(),
          transactionType: "Debt Payment", // ✅ Categorize as Debt Payment
          items: [], // ✅ No items associated with debt payments
          customerName: data['customerId'] ?? "Unknown", // ✅ Include customer name
          debtPaymentMethod: data['payment_method'] ?? "Unknown", // ✅ Include payment method
        ));
      }

      // ✅ Sort by `createdAt` (newest first)
      historyList.sort((a, b) => b.createdAt.compareTo(a.createdAt));

      print("✅ Fetched ${historyList.length} total transactions (including debts & payments).");

      return historyList;
    } catch (e) {
      print("❌ Error fetching full transaction history: $e");
      return [];
    }
  }

  /// ✅ Fetch all items related to a specific transaction
  Future<List<TransactionItem>> _getTransactionItems(String transactionId) async {
    try {
      QuerySnapshot itemSnapshot = await _db
          .collection('transaction_items')
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      return itemSnapshot.docs.map((doc) => TransactionItem.fromDocument(doc)).toList();
    } catch (e) {
      print("❌ Error fetching transaction items for $transactionId: $e");
      return [];
    }
  }

  /// ✅ Determine transaction type (Debts, Debt Payment, Sales)
  String _determineTransactionType(Map<String, dynamic> transaction) {
    if (transaction.containsKey('payment_method')) {
      String paymentMethod = transaction['payment_method'].toString().toLowerCase();

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
      DocumentSnapshot customerDoc = await _db.collection('customers').doc(customerId).get();
      return customerDoc.exists ? customerDoc['name'] : null;
    } catch (e) {
      print("❌ Error fetching customer name: $e");
      return null;
    }
  }
}
