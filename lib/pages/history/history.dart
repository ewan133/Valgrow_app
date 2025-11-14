import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/history_components.dart/date_container.dart';
import 'package:valgrow_ui/components/history_components.dart/history_tile.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/pages/audit/audit_trail_page.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late String formattedDate;
  final int _initialLimit = 30; // Initial limit for transactions
  bool _showAllTransactions = false;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    formattedDate = DateFormat('MMMM d, yyyy').format(now);

    // ✅ Fetch transaction history on page load with initial limit
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final databaseProvider =
          Provider.of<DatabaseProvider>(context, listen: false);
      if (databaseProvider.store != null) {
        databaseProvider.fetchTransactionHistory(
          databaseProvider.store!.storeId,
          limit: _initialLimit,
        );
      }
    });
  }

  // ✅ Load all transactions
  void _loadAllTransactions() async {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);
    if (databaseProvider.store != null) {
      await databaseProvider.fetchTransactionHistory(
        databaseProvider.store!.storeId,
      );
      if (mounted) {
        setState(() {
          _showAllTransactions = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "History"),
      body: Consumer<DatabaseProvider>(
        builder: (context, databaseProvider, child) {
          return Container(
            color: const Color.fromRGBO(20, 174, 92, 0.3),
            child: Column(
              children: [
                _buildDateHeader(), // ✅ Header with current date

                if (databaseProvider.isLoadingTransactions &&
                    databaseProvider.transactionHistory.isEmpty)
                  _buildLoadingIndicator() // ✅ Show loading indicator only if no data yet
                else if (!databaseProvider.isLoadingTransactions &&
                    databaseProvider.transactionHistory.isEmpty)
                  _buildNoTransactionsMessage() // ✅ Show no data message
                else
                  _buildTransactionList(
                      databaseProvider), // ✅ Show transactions (even while loading more)
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ Builds the fixed date header
  Widget _buildDateHeader() {
    return Builder(
      builder: (context) {
        // Use Provider.of with listen: false to avoid triggering rebuilds
        final databaseProvider =
            Provider.of<DatabaseProvider>(context, listen: false);

        // Check if user is store owner
        final isOwner = databaseProvider.user != null &&
            databaseProvider.store != null &&
            databaseProvider.user!.uid == databaseProvider.store!.ownerId;

        return Container(
          height: 57,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            boxShadow: [
              BoxShadow(
                color: Colors.grey,
                blurRadius: 10,
                spreadRadius: 1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: MyText(
                    text: "As of $formattedDate",
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                // Show Audit Trail button only for store owners
                if (isOwner)
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AuditTrailPage(),
                        ),
                      );
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding:
                          EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: Color(0xFF14AE5C).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.analytics_outlined,
                            color: Color(0xFF14AE5C),
                            size: 18,
                          ),
                          SizedBox(width: 6),
                          Text(
                            'Audit Trail',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF14AE5C),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Builds the loading indicator
  Widget _buildLoadingIndicator() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: CircularProgressIndicator(color: Color(0xFF14AE5C)),
      ),
    );
  }

  // ✅ Builds the "No Transactions" message
  Widget _buildNoTransactionsMessage() {
    return const Padding(
      padding: EdgeInsets.all(20),
      child: Center(
        child: MyText(
          text: "No transaction history found.",
          fontSize: 16,
          color: Colors.black54,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  // ✅ Builds the transaction list grouped by date
  Widget _buildTransactionList(DatabaseProvider databaseProvider) {
    final allTransactions = databaseProvider.transactionHistory;

    // Check if there might be more transactions (if we got exactly the limit)
    final hasMoreTransactions = !_showAllTransactions &&
        allTransactions.length >= _initialLimit &&
        !databaseProvider.isLoadingTransactions;

    // ✅ Group transactions by date (as `DateTime`)
    Map<DateTime, List> groupedTransactions = {};

    for (var transaction in allTransactions) {
      DateTime dateKey = DateTime(
        transaction.createdAt.year,
        transaction.createdAt.month,
        transaction.createdAt.day,
      );

      if (!groupedTransactions.containsKey(dateKey)) {
        groupedTransactions[dateKey] = [];
      }
      groupedTransactions[dateKey]!.add(transaction);
    }

    return Expanded(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.only(top: 10, bottom: 10),
              itemCount: groupedTransactions.length,
              itemBuilder: (context, index) {
                DateTime date = groupedTransactions.keys.elementAt(index);
                List transactions = groupedTransactions[date]!;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    MyDateContainer(
                        date: date), // ✅ Uses MyDateContainer with real date
                    ...transactions.map((transaction) => GestureDetector(
                          onTap: () => _showTransactionSummary(
                              context, transaction), // ✅ Show alert on tap
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 2),
                            child: MyHistoryTile(
                              transactionType: transaction
                                  .transactionType, // Sales / Expense
                              amount: transaction.totalAmount,
                              timestamp: transaction.createdAt,
                            ),
                          ),
                        )),
                  ],
                );
              },
            ),
          ),

          // ✅ Show loading indicator at bottom while streaming
          if (databaseProvider.isLoadingTransactions)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: CircularProgressIndicator(
                  color: Color(0xFF14AE5C),
                  strokeWidth: 2,
                ),
              ),
            ),

          // ✅ "See More" button at the end
          if (hasMoreTransactions)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _loadAllTransactions,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14AE5C),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.expand_more, color: Colors.white),
                      SizedBox(width: 8),
                      MyText(
                        text: "See More Transactions",
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ✅ Function to show transaction summary in an alert
  void _showTransactionSummary(BuildContext context, transaction) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: MyText(
            text: "Transaction Summary",
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildSummaryRow("Type:", transaction.transactionType),
                _buildSummaryRow("Amount:",
                    "₱${transaction.totalAmount.toStringAsFixed(2)}"),
                _buildSummaryRow("Date:",
                    DateFormat('MMMM d, yyyy').format(transaction.createdAt)),
                _buildSummaryRow(
                    "Time:", DateFormat.jm().format(transaction.createdAt)),
                if (transaction.transactionType == "Debts" &&
                    transaction.customerName != null)
                  _buildSummaryRow(
                      "Customer:", transaction.customerName ?? "N/A"),
                if (transaction.transactionType == "Debts Payment" &&
                    transaction.debtPaymentMethod != null)
                  _buildSummaryRow("Payment Method:",
                      transaction.debtPaymentMethod ?? "Unknown"),
                const SizedBox(height: 16),
                if (transaction.transactionType != "Debt Payment") ...[
                  MyText(
                    text: "Items:",
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 8),
                  ...List.generate(
                    transaction.items.length,
                    (index) {
                      var item = transaction.items[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: MyText(
                                text: "${item.name} x${item.quantity}",
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black87,
                              ),
                            ),
                            MyText(
                              text:
                                  "₱${(item.unitPrice * item.quantity).toStringAsFixed(2)}",
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black87,
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ],
            ),
          ),
          actions: [
            Center(
              child: IconButton(
                icon: const Icon(Icons.close, size: 24, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
          ],
        );
      },
    );
  }

  // ✅ Helper to create summary rows in the alert
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          MyText(
            text: label,
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black54,
          ),
          MyText(
            text: value,
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ],
      ),
    );
  }
}
