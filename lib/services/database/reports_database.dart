import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Fetch sales report data for a given date range
  Future<List<Map<String, dynamic>>> getSalesReport({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print("🔍 Fetching sales report for Store: $storeId...");

      Query query = _db
          .collection('transactions')
          .where('storeId', isEqualTo: storeId)
          .orderBy('created_at', descending: true);

      if (startDate != null) {
        query = query.where('created_at', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('created_at', isLessThanOrEqualTo: endDate);
      }

      QuerySnapshot querySnapshot = await query.get();

      List<Map<String, dynamic>> salesReport = [];

      for (var doc in querySnapshot.docs) {
        var data = doc.data() as Map<String, dynamic>;

        String employeeName = await _getEmployeeName(data['userId']);

        String customerName = "Guest";
        if (data['customerId'] != null && data['customerId'] != "guest") {
          customerName = await _getCustomerName(data['customerId']);
        }

        int totalItemsSold = await _getTotalItemsSold(doc.id);

        DateTime createdAt = (data['created_at'] as Timestamp).toDate();
        String formattedDate =
            "${_monthName(createdAt.month)} ${createdAt.day}, ${createdAt.year}";

        final reportEntry = {
          "Transaction ID": doc.id,
          "Date": formattedDate,
          "Employee": employeeName,
          "Items Sold": totalItemsSold,
          "Total Sales": "₱${data['total_amount'].toStringAsFixed(2)}",
          "Payment Method": _capitalize(data['payment_method']),
          "Customer": customerName,
        };

        salesReport.add(reportEntry);
      }

      print(
          "✅ Sales report fetched successfully: ${salesReport.length} records");

      for (var entry in salesReport) {
        print("📦 Transaction Record:");
        entry.forEach((key, value) {
          print("• $key: $value");
        });
        print("-----------------------------");
      }

      return salesReport;
    } catch (e) {
      print("❌ Error fetching sales report: $e");
      return [];
    }
  }

  /// 🔍 Fetch Employee Name from Firestore
  Future<String> _getEmployeeName(String userId) async {
    try {
      DocumentSnapshot userDoc =
          await _db.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return userDoc['name'] ?? "Unknown";
      }
    } catch (e) {
      print("⚠️ Error fetching employee name: $e");
    }
    return "Unknown";
  }

  /// 🔍 Fetch Customer Name from Firestore
  Future<String> _getCustomerName(String customerId) async {
    try {
      DocumentSnapshot customerDoc =
          await _db.collection('customers').doc(customerId).get();
      if (customerDoc.exists) {
        return customerDoc['name'] ?? "Unknown";
      }
    } catch (e) {
      print("⚠️ Error fetching customer name: $e");
    }
    return "Unknown";
  }

  /// 🔢 Get Total Items Sold in a Transaction
  Future<int> _getTotalItemsSold(String transactionId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('transaction_items')
          .where('transaction_id', isEqualTo: transactionId)
          .get();

      int totalItems = querySnapshot.docs
          .fold(0, (sum, doc) => sum + (doc['quantity'] as int? ?? 0));

      return totalItems;
    } catch (e) {
      print("⚠️ Error fetching total items sold: $e");
      return 0;
    }
  }

  /// 🗓 Convert month number to month name (e.g., 1 → January)
  String _monthName(int month) {
    List<String> months = [
      "January",
      "February",
      "March",
      "April",
      "May",
      "June",
      "July",
      "August",
      "September",
      "October",
      "November",
      "December"
    ];
    return months[month - 1];
  }

  /// 🔠 Capitalize first letter of a word
  String _capitalize(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1).toLowerCase();
  }

  /// ✅ Fetch debt payment report for a given date range and store
  /// ✅ Fetch debt payment report for a given date range and store
  Future<List<Map<String, dynamic>>> getDebtPaymentReport({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      print("🔍 Fetching debt payment report for Store: $storeId...");

      Query query = _db
          .collection('debt_payments')
          .where('storeId', isEqualTo: storeId)
          .orderBy('payment_date', descending: true);

      if (startDate != null) {
        query = query.where('payment_date', isGreaterThanOrEqualTo: startDate);
      }
      if (endDate != null) {
        query = query.where('payment_date', isLessThanOrEqualTo: endDate);
      }

      QuerySnapshot snapshot = await query.get();
      List<Map<String, dynamic>> report = [];

      for (var doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;

        final paymentDate = (data['payment_date'] as Timestamp).toDate();
        final debtId = data['debt_id'];
        final customerInfo = await _getCustomerInfoFromDebtId(debtId);

        report.add({
          "Payment ID": doc.id,
          "Date":
              "${_monthName(paymentDate.month)} ${paymentDate.day}, ${paymentDate.year}",
          "Amount Paid": data['amount_paid'] ?? 0.0,
          "Payment Method": _capitalize(data['payment_method'] ?? "Unknown"),
          "Customer": customerInfo['name'],
          "Remaining Balance": customerInfo['remainingBalance'], // ✅ NEW FIELD
        });
      }

      print("✅ Debt payment report fetched: ${report.length} records");
      return report;
    } catch (e) {
      print("❌ Error fetching debt payment report: $e");
      return [];
    }
  }

  Future<Map<String, dynamic>> _getCustomerInfoFromDebtId(String debtId) async {
    try {
      final debtDoc = await _db.collection('debts').doc(debtId).get();
      if (debtDoc.exists) {
        final customerId = debtDoc['customerId'];

        // Fetch customer name
        final customerName = await _getCustomerName(customerId);

        // Fetch all unpaid/partial debts for this customer
        final debtSnapshot = await _db
            .collection('debts')
            .where('customerId', isEqualTo: customerId)
            .where('status', whereIn: ['unpaid', 'partial']).get();

        double totalBalance = 0.0;
        for (var debt in debtSnapshot.docs) {
          totalBalance += (debt['balance'] ?? 0.0) as double;
        }

        return {
          'name': customerName,
          'remainingBalance': totalBalance,
        };
      }
    } catch (e) {
      print("⚠️ Error resolving customer info from debt ID: $e");
    }

    return {
      'name': "Unknown",
      'remainingBalance': 0.0,
    };
  }
}
