import 'package:cloud_firestore/cloud_firestore.dart';

class ReportsDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Fetch sales report data for a given date range
  Future<List<Map<String, dynamic>>> getSalesReport(
      {required String storeId, DateTime? startDate, DateTime? endDate}) async {
    try {
      print("🔍 Fetching sales report for Store: $storeId...");

      Query query = _db
          .collection('transactions')
          .where('storeId', isEqualTo: storeId)
          .orderBy('created_at', descending: true); // Sort latest first

      // ✅ Apply date filters if provided
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

        // ✅ Fetch employee name
        String employeeName = await _getEmployeeName(data['userId']);

        // ✅ Fetch customer name (or set to "Guest" if null)
        String customerName = "Guest";
        if (data['customerId'] != null && data['customerId'] != "guest") {
          customerName = await _getCustomerName(data['customerId']);
        }

        // ✅ Fetch total items sold
        int totalItemsSold = await _getTotalItemsSold(doc.id);

        // ✅ Convert Firestore timestamp to readable date
        DateTime createdAt = (data['created_at'] as Timestamp).toDate();
        String formattedDate =
            "${_monthName(createdAt.month)} ${createdAt.day}, ${createdAt.year}";

        // ✅ Add formatted data to list
        salesReport.add({
          "Transaction ID": doc.id,
          "Date": formattedDate,
          "Employee": employeeName,
          "Items Sold": totalItemsSold,
          "Total Sales": "₱${data['total_amount'].toStringAsFixed(2)}",
          "Payment Method": _capitalize(data['payment_method']),
          "Customer": customerName,
        });
      }

      print(
          "✅ Sales report fetched successfully: ${salesReport.length} records");
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
}
