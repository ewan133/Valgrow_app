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
        // ✅ Add one day to include entire endDate day
        query = query.where('created_at',
            isLessThan: endDate.add(Duration(days: 1)));
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
        query = query.where('payment_date',
            isLessThan: endDate.add(Duration(days: 1)));
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

  Future<Map<String, dynamic>> getTodaySummary(String storeId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final tomorrow = today.add(Duration(days: 1));

      double totalSales = 0.0;
      double totalDebtAmount = 0.0;
      double totalExpenses = 0.0;
      int paidCount = 0;
      int debtCount = 0;

      // 🔹 Sales (Paid and Debt)
      QuerySnapshot salesSnapshot = await _db
          .collection('transactions')
          .where('storeId', isEqualTo: storeId)
          .where('created_at', isGreaterThanOrEqualTo: today)
          .where('created_at', isLessThan: tomorrow)
          .get();

      for (var doc in salesSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final paymentMethod = data['payment_method'];
        final totalAmount = (data['total_amount'] ?? 0.0) as double;

        if (paymentMethod == 'debt') {
          debtCount++;
          totalDebtAmount += totalAmount;
        } else {
          paidCount++;
          totalSales += totalAmount;
        }
      }

      // 🔹 Add today's debt payments to totalSales
      QuerySnapshot debtPaymentsSnapshot = await _db
          .collection('debt_payments')
          .where('storeId', isEqualTo: storeId)
          .where('payment_date', isGreaterThanOrEqualTo: today)
          .where('payment_date', isLessThan: tomorrow)
          .get();

      for (var doc in debtPaymentsSnapshot.docs) {
        final paymentData = doc.data() as Map<String, dynamic>;
        totalSales += (paymentData['amount_paid'] ?? 0.0) as double;
      }

      // 🔹 Expenses
      QuerySnapshot expenseSnapshot = await _db
          .collection('expenses')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: today)
          .where('date', isLessThan: tomorrow)
          .get();

      for (var doc in expenseSnapshot.docs) {
        totalExpenses += (doc['amount'] ?? 0.0) as double;
      }

      // 🔹 Print summary
      print("📊 Sales Report Summary:");
      print(
          "• Total Sales (with debt payments): ₱${totalSales.toStringAsFixed(2)}");
      print(
          "• Total Debt Amount (new debts): ₱${totalDebtAmount.toStringAsFixed(2)}");
      print("• Total Expenses: ₱${totalExpenses.toStringAsFixed(2)}");
      print("• Profit: ₱${(totalSales - totalExpenses).toStringAsFixed(2)}");
      print("• Paid Transactions: $paidCount");
      print("• Debt Transactions: $debtCount");

      return {
        'totalSales': totalSales,
        'totalDebtAmount': totalDebtAmount,
        'totalExpenses': totalExpenses,
        'profit': totalSales - totalExpenses,
        'paidTransactions': paidCount,
        'debtTransactions': debtCount,
      };
    } catch (e) {
      print('❌ Error in getTodaySummary: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getGeneralOverview(String storeId) async {
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final firstOfMonth = DateTime(now.year, now.month, 1);
      final nextWeek = today.add(const Duration(days: 7));

      // 🟠 Out-of-stock items
      QuerySnapshot itemSnapshot = await _db
          .collection('items')
          .where('storeId', isEqualTo: storeId)
          .where('total_stock', isEqualTo: 0)
          .get();

      List<String> outOfStockItems =
          itemSnapshot.docs.map((doc) => doc['item_name'] as String).toList();

      // 🔴 Customers with debts (overdue or due within a week)
      QuerySnapshot debtSnapshot = await _db
          .collection('debts')
          .where('storeId', isEqualTo: storeId)
          .where('status', whereIn: ['unpaid', 'partial']).get();

      List<Map<String, dynamic>> customersWithDebts = [];
      for (var doc in debtSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final customerId = data['customerId'];
        final balance = (data['balance'] ?? 0.0) as double;
        final dueDate = (data['due_date'] as Timestamp).toDate();

        if (dueDate.isBefore(today) || dueDate.isBefore(nextWeek)) {
          final name = await _getCustomerName(customerId);
          final daysDiff = dueDate.difference(today).inDays;

          String status;
          if (dueDate.isBefore(today)) {
            status = 'Overdue by ${today.difference(dueDate).inDays} day(s)';
          } else {
            status = 'Due in $daysDiff day(s)';
          }

          customersWithDebts.add({
            'name': name,
            'balance': balance,
            'dueDate': dueDate,
            'status': status,
          });
        }
      }

      // 🔥 Top 5 Most Sold Items (based on transactions this month)
      QuerySnapshot transactions = await _db
          .collection('transactions')
          .where('storeId', isEqualTo: storeId)
          .where('created_at', isGreaterThanOrEqualTo: firstOfMonth)
          .where('created_at', isLessThanOrEqualTo: now)
          .get();

      Map<String, int> itemSales = {};

      for (var tx in transactions.docs) {
        final txId = tx.id;

        QuerySnapshot txItems = await _db
            .collection('transaction_items')
            .where('transaction_id', isEqualTo: txId)
            .get();

        for (var itemDoc in txItems.docs) {
          final itemData = itemDoc.data() as Map<String, dynamic>;
          final itemId = itemData['item_id'];
          final quantity = (itemData['quantity'] ?? 0) as int;

          itemSales[itemId] = (itemSales[itemId] ?? 0) + quantity;
        }
      }

      final top5ItemIds = itemSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topItems = <String>[];
      for (final entry in top5ItemIds.take(5)) {
        final itemDoc = await _db.collection('items').doc(entry.key).get();
        final itemName = itemDoc['item_name'] ?? "Unknown Item";
        topItems.add("$itemName - ${entry.value} sold");
      }

      // Debug prints
      print("📦 Out of Stock Items:");
      outOfStockItems.forEach((item) => print("• $item"));

      print("\n⚠️ Customers with Outstanding Debts:");
      for (var entry in customersWithDebts) {
        print("• ${entry['name']} – ₱${entry['balance']} (${entry['status']})");
      }

      print("\n🔥 Top 5 Most Sold Items:");
      topItems.forEach((item) => print("• $item"));

      return {
        'outOfStockItems': outOfStockItems,
        'customersWithOutstandingDebts': customersWithDebts,
        'mostSoldItems': topItems,
      };
    } catch (e) {
      print('❌ Error in getGeneralOverview: $e');
      return {};
    }
  }

  Future<Map<String, dynamic>> getDateRangeFinancialReport({
    required String storeId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      double totalSales = 0.0;
      double totalUnpaidDebt = 0.0;

      // 🔹 Default to TODAY only if no dates are provided
      final now = DateTime.now();
      final todayStart = DateTime(now.year, now.month, now.day);
      final todayEnd = todayStart.add(const Duration(days: 1));
      startDate ??= todayStart;
      endDate ??= todayEnd;

      // ✅ Transactions (excluding debt-based)
      Query transactionQuery = _db
          .collection('transactions')
          .where('storeId', isEqualTo: storeId)
          .where('payment_method', isNotEqualTo: 'debt')
          .where('created_at', isGreaterThanOrEqualTo: startDate)
          .where('created_at', isLessThan: endDate);

      QuerySnapshot transactionSnapshot = await transactionQuery.get();
      for (var doc in transactionSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalSales += (data['total_amount'] ?? 0.0) as double;
      }

      // ✅ Debt Payments made today
      Query debtPaymentQuery = _db
          .collection('debt_payments')
          .where('storeId', isEqualTo: storeId)
          .where('payment_date', isGreaterThanOrEqualTo: startDate)
          .where('payment_date', isLessThan: endDate);

      QuerySnapshot debtPaymentSnapshot = await debtPaymentQuery.get();
      for (var doc in debtPaymentSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalSales += (data['amount_paid'] ?? 0.0) as double;
      }

      // 🔴 Total unpaid debts (all-time)
      QuerySnapshot debtSnapshot = await _db
          .collection('debts')
          .where('storeId', isEqualTo: storeId)
          .where('status', whereIn: ['unpaid', 'partial']).get();

      for (var doc in debtSnapshot.docs) {
        totalUnpaidDebt += (doc['balance'] ?? 0.0) as double;
      }

      return {
        'totalSalesExcludingDebt': totalSales,
        'totalUnpaidDebts': totalUnpaidDebt,
      };
    } catch (e) {
      print('❌ Error in getDateRangeFinancialReport: $e');
      return {};
    }
  }

  /// ✅ Fetch data for Quick Summary Cards
  Future<Map<String, dynamic>> getQuickSummary(String storeId) async {
    try {
      int totalInStockItems = 0;
      int totalOutOfStockItems = 0;
      int customersWithBalance = 0;

      // 🔹 Fetch all items for the store
      QuerySnapshot itemSnapshot = await _db
          .collection('items')
          .where('storeId', isEqualTo: storeId)
          .get();

      for (var doc in itemSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final stock = (data['total_stock'] ?? 0) as int;
        if (stock > 0) {
          totalInStockItems++;
        } else {
          totalOutOfStockItems++;
        }
      }

      // 🔸 Count customers with unpaid or partial debts
      QuerySnapshot debtSnapshot = await _db
          .collection('debts')
          .where('storeId', isEqualTo: storeId)
          .where('status', whereIn: ['unpaid', 'partial']).get();

      // Group by customerId using a Set to avoid duplicates
      Set<String> customerIdsWithBalance = {};

      for (var doc in debtSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final customerId = data['customerId'];
        if (customerId != null && customerId != "guest") {
          customerIdsWithBalance.add(customerId);
        }
      }

      customersWithBalance = customerIdsWithBalance.length;

      return {
        'totalInStockItems': totalInStockItems,
        'totalOutOfStockItems': totalOutOfStockItems,
        'customersWithBalance': customersWithBalance,
      };
    } catch (e) {
      print("❌ Error in getQuickSummary: $e");
      return {
        'totalInStockItems': 0,
        'totalOutOfStockItems': 0,
        'customersWithBalance': 0,
      };
    }
  }

  Future<Map<String, dynamic>> getPerformanceChartData(String storeId) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 56)); // Last 8 weeks

      List<double> weeklySales = List.filled(8, 0.0);
      List<double> weeklyExpenses = List.filled(8, 0.0);

      // Transactions
      QuerySnapshot txSnapshot = await _db
          .collection('transactions')
          .where('storeId', isEqualTo: storeId)
          .where('created_at', isGreaterThanOrEqualTo: startDate)
          .get();

      for (var doc in txSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = (data['created_at'] as Timestamp).toDate();
        final index = now.difference(createdAt).inDays ~/ 7;
        if (index < 8) {
          weeklySales[7 - index] += (data['total_amount'] ?? 0.0) as double;
        }
      }

      // Expenses
      QuerySnapshot expSnapshot = await _db
          .collection('expenses')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .get();

      for (var doc in expSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        final index = now.difference(date).inDays ~/ 7;
        if (index < 8) {
          weeklyExpenses[7 - index] += (data['amount'] ?? 0.0) as double;
        }
      }

      // POS Breakdown
      int paidCount = 0;
      int unpaidCount = 0;

      for (var doc in txSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final method = data['payment_method'];
        if (method == "cash" || method == "gcash") {
          paidCount++;
        } else if (method == "debt") {
          unpaidCount++;
        }
      }

      // Debt Payments
      QuerySnapshot debtPaymentSnapshot = await _db
          .collection('debt_payments')
          .where('storeId', isEqualTo: storeId)
          .where('payment_date', isGreaterThanOrEqualTo: startDate)
          .get();

      int debtPaymentCount = debtPaymentSnapshot.docs.length;

      // Most Sold Items
      Map<String, int> itemSales = {};

      for (var tx in txSnapshot.docs) {
        final txId = tx.id;
        QuerySnapshot txItems = await _db
            .collection('transaction_items')
            .where('transaction_id', isEqualTo: txId)
            .get();

        for (var item in txItems.docs) {
          final itemData = item.data() as Map<String, dynamic>;
          final itemId = itemData['item_id'];
          final qty = (itemData['quantity'] ?? 0) as int;
          itemSales[itemId] = (itemSales[itemId] ?? 0) + qty;
        }
      }

      final sortedItems = itemSales.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      final topSoldItems = <double>[];
      final topSoldLabels = <String>[];

      for (var entry in sortedItems.take(5)) {
        final itemDoc = await _db.collection('items').doc(entry.key).get();
        final itemName = itemDoc['item_name'] ?? 'Unknown Item';
        topSoldLabels.add('$itemName');
        topSoldItems.add(entry.value.toDouble());
      }

      // Fill missing slots with placeholders
      while (topSoldItems.length < 5) {
        topSoldItems.add(0.0);
        topSoldLabels.add('');
      }

      print("📊 Weekly Sales: $weeklySales");
      print("📉 Weekly Expenses: $weeklyExpenses");
      print(
          "💳 POS Breakdown → Paid: $paidCount | Unpaid: $unpaidCount | Debt Payments: $debtPaymentCount");
      print("🔥 Top 5 Most Sold Items:");
      for (int i = 0; i < topSoldLabels.length; i++) {
        print("• ${topSoldLabels[i]}: ${topSoldItems[i].toInt()} sold");
      }

      return {
        'weeklySales': weeklySales,
        'weeklyExpenses': weeklyExpenses,
        'posBreakdown': [
          paidCount.toDouble(),
          unpaidCount.toDouble(),
          debtPaymentCount.toDouble(),
        ],
        'topSoldItems': topSoldItems,
        'topSoldLabels': topSoldLabels,
      };
    } catch (e) {
      print("❌ Error in getPerformanceChartData: $e");
      return {
        'weeklySales': List.filled(8, 0.0),
        'weeklyExpenses': List.filled(8, 0.0),
        'posBreakdown': [0.0, 0.0, 0.0],
        'topSoldItems': List.filled(5, 0.0),
        'topSoldLabels': List.filled(5, ''),
      };
    }
  }

  /// ✅ Fetch financial insights data for last 8 weeks
  Future<Map<String, List<double>>> getFinancialInsights(String storeId) async {
    try {
      final now = DateTime.now();
      final startDate = now.subtract(const Duration(days: 56)); // Last 8 weeks

      List<double> weeklySales = List.filled(8, 0.0);
      List<double> weeklyAvailableItems = List.filled(8, 0.0);
      List<double> weeklyExpenses = List.filled(8, 0.0);
      List<double> weeklyNetProfit = List.filled(8, 0.0);

      // 🔹 Fetch Transactions
      QuerySnapshot txSnapshot = await _db
          .collection('transactions')
          .where('storeId', isEqualTo: storeId)
          .where('created_at', isGreaterThanOrEqualTo: startDate)
          .get();

      for (var doc in txSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final createdAt = (data['created_at'] as Timestamp).toDate();
        final index = now.difference(createdAt).inDays ~/ 7;
        if (index < 8) {
          weeklySales[7 - index] += (data['total_amount'] ?? 0.0) as double;
        }
      }

      // 🔹 Fetch Expenses
      QuerySnapshot expSnapshot = await _db
          .collection('expenses')
          .where('storeId', isEqualTo: storeId)
          .where('date', isGreaterThanOrEqualTo: startDate)
          .get();

      for (var doc in expSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final date = (data['date'] as Timestamp).toDate();
        final index = now.difference(date).inDays ~/ 7;
        if (index < 8) {
          weeklyExpenses[7 - index] += (data['amount'] ?? 0.0) as double;
        }
      }

      // 🔹 Fetch Available Items
      QuerySnapshot itemSnapshot = await _db
          .collection('items')
          .where('storeId', isEqualTo: storeId)
          .get();

      int availableItemCount = 0;
      for (var doc in itemSnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final stock = (data['total_stock'] ?? 0) as int;
        if (stock > 0) {
          availableItemCount++;
        }
      }

      // Fill Available Items for each week
      for (int i = 0; i < 8; i++) {
        weeklyAvailableItems[i] = availableItemCount.toDouble();
      }

      // 🔹 Calculate Net Profit
      for (int i = 0; i < 8; i++) {
        weeklyNetProfit[i] = weeklySales[i] - weeklyExpenses[i];
      }

      // ✅ Final Debug Print
      print("✅ Financial Insights Computed:");
      print("─────────────────────────────────");
      print("📈 Weekly Sales        : $weeklySales");
      print("📦 Weekly Available Items: $weeklyAvailableItems");
      print("💸 Weekly Expenses      : $weeklyExpenses");
      print("📊 Weekly Net Profit    : $weeklyNetProfit");
      print("─────────────────────────────────");

      return {
        'weeklySales': weeklySales,
        'weeklyAvailableItems': weeklyAvailableItems,
        'weeklyExpenses': weeklyExpenses,
        'weeklyNetProfit': weeklyNetProfit,
      };
    } catch (e) {
      print('❌ Error fetching financial insights: $e');
      return {
        'weeklySales': List.filled(8, 0.0),
        'weeklyAvailableItems': List.filled(8, 0.0),
        'weeklyExpenses': List.filled(8, 0.0),
        'weeklyNetProfit': List.filled(8, 0.0),
      };
    }
  }
}
