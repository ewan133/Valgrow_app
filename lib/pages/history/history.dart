import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/history_components.dart/date_container.dart';
import 'package:valgrow_ui/components/history_components.dart/history_tile.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  late String formattedDate;

  @override
  void initState() {
    super.initState();
    DateTime now = DateTime.now();
    formattedDate = DateFormat('MMMM d, yyyy').format(now);

    // ✅ Fetch transaction history on page load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final databaseProvider =
          Provider.of<DatabaseProvider>(context, listen: false);
      if (databaseProvider.store != null) {
        databaseProvider.fetchTransactionHistory(databaseProvider.store!.storeId);
      }
    });
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

                if (databaseProvider.isLoadingTransactions)
                  _buildLoadingIndicator() // ✅ Show loading indicator
                else if (databaseProvider.transactionHistory.isEmpty)
                  _buildNoTransactionsMessage() // ✅ Show no data message
                else
                  _buildTransactionList(databaseProvider), // ✅ Show transactions
              ],
            ),
          );
        },
      ),
    );
  }

  // ✅ Builds the fixed date header
  Widget _buildDateHeader() {
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
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: MyText(
          text: "As of $formattedDate",
          fontSize: 14,
          color: Colors.black,
          fontWeight: FontWeight.w500,
        ),
      ),
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
    // ✅ Group transactions by date (as `DateTime`)
    Map<DateTime, List> groupedTransactions = {};

    for (var transaction in databaseProvider.transactionHistory) {
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
      child: ListView.builder(
        padding: const EdgeInsets.only(top: 10),
        itemCount: groupedTransactions.length,
        itemBuilder: (context, index) {
          DateTime date = groupedTransactions.keys.elementAt(index);
          List transactions = groupedTransactions[date]!;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              MyDateContainer(date: date), // ✅ Uses MyDateContainer with real date
              ...transactions.map((transaction) => GestureDetector(
                    onTap: () => _showTransactionSummary(context, transaction), // ✅ Show alert on tap
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: MyHistoryTile(
                        transactionType: transaction.transactionType, // Sales / Expense
                        amount: transaction.totalAmount,
                        timestamp: transaction.createdAt,
                      ),
                    ),
                  )),
            ],
          );
        },
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
            borderRadius: BorderRadius.circular(12), // ✅ Rounded corners
          ),
          title: MyText(
            text: "Transaction Summary",
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min, // ✅ Prevents oversized modal
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildSummaryRow("Type:", transaction.transactionType),
              _buildSummaryRow("Amount:", "₱${transaction.totalAmount.toStringAsFixed(2)}"),
              _buildSummaryRow("Date:", DateFormat('MMMM d, yyyy').format(transaction.createdAt)),
              _buildSummaryRow("Time:", DateFormat.jm().format(transaction.createdAt)), // 5:27 PM
              
              if (transaction.transactionType == "Debts" && transaction.customerName != null)
                _buildSummaryRow("Customer:", transaction.customerName ?? "N/A"),

              if (transaction.transactionType == "Debts Payment" && transaction.debtPaymentMethod != null)
                _buildSummaryRow("Payment Method:", transaction.debtPaymentMethod ?? "Unknown"),
            ],
          ),
          actions: [
            Center(
              child: IconButton(
                icon: const Icon(Icons.close, size: 24, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context); // ✅ Close dialog
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
