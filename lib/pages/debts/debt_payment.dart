import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:valgrow_ui/components/debts_components/item_debt_list.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/models/debts_model.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class DebtPaymentPage extends StatefulWidget {
  final DebtDetails debtDetails;
  final CustomerDetails customerDetails;

  const DebtPaymentPage({super.key, required this.debtDetails, required this.customerDetails});

  @override
  State<DebtPaymentPage> createState() => _DebtPaymentPageState();
}

class _DebtPaymentPageState extends State<DebtPaymentPage> {
  final TextEditingController _payingAmountController = TextEditingController();
  final TextEditingController _customerMoneyController = TextEditingController();
  double _change = 0.0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .fetchTransactionItems(widget.debtDetails.transactionId);
    });

    _payingAmountController.text = widget.debtDetails.balance.toString();
    _payingAmountController.addListener(_validatePayingAmount);
    _customerMoneyController.addListener(_calculateChange);
  }

  @override
  void dispose() {
    _payingAmountController.dispose();
    _customerMoneyController.dispose();
    super.dispose();
  }

  // ✅ Prevents the user from entering more than the balance
  void _validatePayingAmount() {
    double payingAmount = double.tryParse(_payingAmountController.text) ?? 0.0;
    double maxBalance = widget.debtDetails.balance;

    if (payingAmount > maxBalance) {
      _payingAmountController.text = maxBalance.toStringAsFixed(2);
      _payingAmountController.selection = TextSelection.fromPosition(
        TextPosition(offset: _payingAmountController.text.length),
      );
    }
    _calculateChange();
  }

  // ✅ Calculates change dynamically
  void _calculateChange() {
    double payingAmount = double.tryParse(_payingAmountController.text) ?? 0.0;
    double customerMoney = double.tryParse(_customerMoneyController.text) ?? 0.0;

    setState(() {
      _change = (customerMoney - payingAmount).clamp(0.0, double.infinity);
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    final transactionItems = provider.transactionItems;
    final isLoading = provider.isLoadingTransactionItems;

    return Scaffold(
      appBar: MyAppbar(title: "Debt Details"),
      body: Padding(
        padding: const EdgeInsets.only(left: 20, right: 20, top: 16),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ✅ Financial Summary
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.black.withOpacity(0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSummaryRow("Customer:", widget.customerDetails.name),
                    _buildSummaryRow("Date Created:", _formatDate(widget.debtDetails.createdAt)),
                    _buildSummaryRow("Due Date:", _formatDate(widget.debtDetails.dueDate)),
                    _buildSummaryRow("Total Amount:", "₱${widget.debtDetails.totalAmount.toStringAsFixed(2)}"),
                    _buildSummaryRow("Amount Paid:", "₱${widget.debtDetails.amountPaid.toStringAsFixed(2)}"),
                    const Divider(color: Colors.black45),
                    _buildSummaryRow("Remaining Balance:", "₱${widget.debtDetails.balance.toStringAsFixed(2)}"),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ✅ Items List
              const Text("Items Purchased:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              SizedBox(
                height: 150,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : transactionItems.isEmpty
                        ? const Center(child: Text("No items found for this transaction."))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: transactionItems.length,
                            itemBuilder: (context, index) {
                              final item = transactionItems[index];
                              final itemDetails = item["itemDetails"];

                              return MyItemDebtList(
                                itemName: itemDetails?["item_name"] ?? "Unknown Item",
                                quantity: item["transactionItem"]["quantity"],
                                price: item["transactionItem"]["total_price"],
                              );
                            },
                          ),
              ),

              const SizedBox(height: 15),

              // ✅ Payment Section
              _buildPaymentField("Paying Amount:", _payingAmountController),
              const SizedBox(height: 10),
              _buildPaymentField("Received Amount:", _customerMoneyController),

              const SizedBox(height: 15),

              // ✅ Change Display
              Center(
                child: Text(
                  "Change: ₱${_change.toStringAsFixed(2)}",
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
              ),

              const SizedBox(height: 15),

              // ✅ Pay Debt Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF14AE5C),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                  ),
                  onPressed: () {
                    // TODO: Implement debt payment logic
                  },
                  child: const Text(
                    "Pay Debt",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ✅ Row for Summary (Customer, Date Created, Due Date, etc.)
  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 3),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ✅ Payment Input Fields with Validation
  Widget _buildPaymentField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            border: Border.all(color: Colors.black),
            borderRadius: BorderRadius.circular(8),
          ),
          child: TextField(
            controller: controller,
            decoration: const InputDecoration(
              border: InputBorder.none,
              prefixIcon: Text("₱ ", style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
              prefixIconConstraints: BoxConstraints(minWidth: 40),
              hintText: "00.00",
              hintStyle: TextStyle(fontSize: 14, color: Color(0xFFBDBDBD)),
            ),
            keyboardType: TextInputType.number,
          ),
        ),
      ],
    );
  }

  // ✅ Format Date
  String _formatDate(DateTime? date) {
    if (date == null) return "N/A";
    return DateFormat.yMMMd().format(date);
  }
}


