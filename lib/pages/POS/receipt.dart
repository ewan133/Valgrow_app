import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class ReceiptPage extends StatefulWidget {
  final String transactionId;

  const ReceiptPage({super.key, required this.transactionId});

  @override
  State<ReceiptPage> createState() => _ReceiptPageState();
}

class _ReceiptPageState extends State<ReceiptPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .fetchTransactionDetails(widget.transactionId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    final transactionDetails = provider.transactionDetails;
    final isLoading = provider.isLoadingTransaction;
    final store = provider.store;
    final user = provider.user;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        title: const Text(
          "Receipt",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 🔄 Loading
          : transactionDetails == null
              ? const Center(child: Text("❌ Transaction not found"))
              : _buildReceipt(transactionDetails, store, user),
    );
  }

  /// ✅ **Build Receipt**
  Widget _buildReceipt(
      Map<String, dynamic> transactionDetails, dynamic store, dynamic user) {
    final transaction = transactionDetails["transaction"];
    final items = transactionDetails["items"];
    final customer = transactionDetails["customer"];
    final debt = transactionDetails["debt"];
    final debtPayments = transactionDetails["debt_payments"];

    final storeName = store?.name ?? "Unknown Store";
    final cashierName = user?.name ?? "Unknown Cashier";
    final isDebtPayment = debtPayments != null; // ✅ Detect if it is a debt payment

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // 🏪 Store Details
          Text(
            storeName,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            "Date: ${DateFormat.yMMMd().format(transaction["created_at"].toDate())} ${DateFormat.jm().format(transaction["created_at"].toDate())}",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          Text(
            "Cashier: $cashierName",
            style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
          ),
          if (customer != null)
            Text(
              "Customer: ${customer["name"]}",
              style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
            ),
          const SizedBox(height: 10),

          // 📜 Transaction Items
          Expanded(
            child: ListView(
              children: [
                const Divider(thickness: 1),
                for (var item in items)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            "${item['item_name']} x${item['quantity']}",
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                        Text(
                          "₱${(item['quantity'] * item['unit_price']).toStringAsFixed(2)}",
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                const Divider(thickness: 1),
              ],
            ),
          ),

          // 💰 Payment Summary
          Column(
            children: [
              _paymentRow(
                  "Subtotal:", "₱${transaction["total_amount"].toStringAsFixed(2)}"),
              
              // ✅ Hide Payment Method, Amount Paid, and Change for Debt Payments
              if (!isDebtPayment) ...[
                _paymentRow(
                    "Payment Method:", transaction["payment_method"].toUpperCase()),
                _paymentRow(
                    "Amount Paid:", "₱${transaction["amount_paid"].toStringAsFixed(2)}"),
                _paymentRow("Change:", "₱${transaction["change"].toStringAsFixed(2)}"),
              ],

              // 🔥 Display Remaining Balance if it is a **Debt Transaction**
              if (debt != null)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),
                    const Text(
                      "DEBT TRANSACTION",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                    _paymentRow(
                      "Remaining Balance:",
                      "₱${debt["balance"].toStringAsFixed(2)}",
                    ),
                    _paymentRow(
                      "Due Date:",
                      DateFormat.yMMMd().format(debt["due_date"].toDate()),
                    ),
                  ],
                ),

              // 🔥 Display Debt Payments if applicable
              if (debtPayments != null)
                Column(
                  children: [
                    const SizedBox(height: 10),
                    const Divider(thickness: 1),
                    const Text(
                      "DEBT PAYMENTS",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    for (var payment in debtPayments)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat.yMMMd()
                                  .format(payment["payment_date"].toDate()),
                              style: const TextStyle(fontSize: 14),
                            ),
                            Text(
                              "₱${payment["amount_paid"].toStringAsFixed(2)}",
                              style: const TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.bold),
                            ),
                            Text(
                              payment["payment_method"].toUpperCase(),
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade700),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),

              const SizedBox(height: 10),
              const Divider(thickness: 1),

              // ✅ Thank You Message
              const Text(
                "Thank you for shopping with us!",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Text(
                "Have a great day!",
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✅ **Helper: Payment Row**
  Widget _paymentRow(String title, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(fontSize: 16)),
          Text(value,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
