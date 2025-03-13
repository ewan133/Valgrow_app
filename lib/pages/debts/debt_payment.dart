import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:valgrow_ui/components/debts_components/item_debt_list.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/models/debts_model.dart';
import 'package:valgrow_ui/pages/debts/debts_sucess.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class DebtPaymentPage extends StatefulWidget {
  final DebtDetails debtDetails;
  final CustomerDetails customerDetails;

  const DebtPaymentPage(
      {super.key, required this.debtDetails, required this.customerDetails});

  @override
  State<DebtPaymentPage> createState() => _DebtPaymentPageState();
}

class _DebtPaymentPageState extends State<DebtPaymentPage> {
  final TextEditingController _payingAmountController = TextEditingController();
  final TextEditingController _customerMoneyController =
      TextEditingController();
  double _change = 0.0;
  String _selectedPaymentMethod = "Cash"; // Default payment method
  bool _isProcessing = false; // ✅ To disable the pay button during processing

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
    double customerMoney =
        double.tryParse(_customerMoneyController.text) ?? 0.0;

    setState(() {
      _change = (customerMoney - payingAmount) < 0
          ? 0.0
          : (customerMoney - payingAmount);
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
                    _buildSummaryRow("Date Created:",
                        _formatDate(widget.debtDetails.createdAt)),
                    _buildSummaryRow(
                        "Due Date:", _formatDate(widget.debtDetails.dueDate)),
                    _buildSummaryRow("Total Amount:",
                        "₱${widget.debtDetails.totalAmount.toStringAsFixed(2)}"),
                    _buildSummaryRow("Amount Paid:",
                        "₱${widget.debtDetails.amountPaid.toStringAsFixed(2)}"),
                    const Divider(color: Colors.black45),
                    _buildSummaryRow("Remaining Balance:",
                        "₱${widget.debtDetails.balance.toStringAsFixed(2)}"),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              // ✅ Items List
              const Text("Items Purchased:",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
              const SizedBox(height: 5),
              SizedBox(
                height: 150,
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : transactionItems.isEmpty
                        ? const Center(
                            child: Text("No items found for this transaction."))
                        : ListView.builder(
                            shrinkWrap: true,
                            physics: const BouncingScrollPhysics(),
                            itemCount: transactionItems.length,
                            itemBuilder: (context, index) {
                              final item = transactionItems[index];
                              final itemDetails = item["itemDetails"];

                              return MyItemDebtList(
                                itemName:
                                    itemDetails?["item_name"] ?? "Unknown Item",
                                quantity: item["transactionItem"]["quantity"],
                                price: item["transactionItem"]["total_price"],
                              );
                            },
                          ),
              ),

              const SizedBox(height: 15),

              if (widget.debtDetails.balance > 0) ...[
                // ✅ Payment Section
                _buildPaymentField("Paying Amount:", _payingAmountController),
                const SizedBox(height: 10),
                Row(
                  children: [
                    // Received Amount Field (Takes 70% of the Row)
                    Expanded(
                      flex: 7, // ✅ 70% width
                      child: _buildPaymentField(
                          "Received Amount:", _customerMoneyController),
                    ),
                    const SizedBox(width: 10), // Space between inputs

                    // Payment Method Dropdown (Takes 30% of the Row)
                    Expanded(
                      flex: 3, // ✅ 30% width
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text("Method:",
                              style: TextStyle(
                                  fontSize: 14, fontWeight: FontWeight.w700)),
                          const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF6F6F6),
                              border: Border.all(color: Colors.black),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _selectedPaymentMethod,
                                items: const [
                                  DropdownMenuItem(
                                      value: "Cash", child: Text("Cash")),
                                  DropdownMenuItem(
                                      value: "Gcash", child: Text("GCash")),
                                ],
                                onChanged: (value) {
                                  setState(() {
                                    _selectedPaymentMethod = value!;
                                  });
                                },
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                // ✅ Change Display
                Center(
                  child: Text(
                    "Change: ₱${_change.toStringAsFixed(2)}",
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.w700),
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
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25)),
                    ),
                    onPressed: _isProcessing
                        ? null // ✅ Disable button while processing
                        : () async {
                            setState(() =>
                                _isProcessing = true); // ✅ Start processing

                            double payingAmount =
                                double.tryParse(_payingAmountController.text) ??
                                    0.0;
                            double receivedAmount = double.tryParse(
                                    _customerMoneyController.text) ??
                                0.0;

                            if (payingAmount <= 0 ||
                                payingAmount > widget.debtDetails.balance) {
                              Fluttertoast.showToast(
                                msg: "Invalid payment amount!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity
                                    .BOTTOM, // You can change this to CENTER or TOP
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              setState(() =>
                                  _isProcessing = false); // ✅ Stop processing
                              return;
                            }

                            if (receivedAmount < payingAmount) {
                              Fluttertoast.showToast(
                                msg:
                                    "Received amount cannot be less than paying amount!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity
                                    .BOTTOM, // You can change this to CENTER or TOP
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              setState(() =>
                                  _isProcessing = false); // ✅ Stop processing
                              return;
                            }

                            if (_selectedPaymentMethod.isEmpty) {
                              Fluttertoast.showToast(
                                msg: "Please select a payment method!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity
                                    .BOTTOM, // You can change this to CENTER or TOP
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                              setState(() =>
                                  _isProcessing = false); // ✅ Stop processing
                              return;
                            }

                            bool success = await Provider.of<DatabaseProvider>(
                                    context,
                                    listen: false)
                                .processDebtPayment(
                              debtId: widget.debtDetails.debtId,
                              amountPaid: payingAmount,
                              paymentMethod: _selectedPaymentMethod,
                              storeId: widget.debtDetails.storeId,
                              customerId: widget.customerDetails.customerId,
                            );

                            if (success) {
                              final provider = Provider.of<DatabaseProvider>(
                                  context,
                                  listen: false);

                              // ✅ Update the selected customer with refreshed data
                              await provider.updateSelectedCustomerAfterPayment(
                                  widget.customerDetails.customerId);
                              await provider.fetchDebtsWithCustomerInfo();

                              // ✅ Navigate to success page
                              Navigator.pop(context, provider.selectedCustomer);
                              Navigator.pushReplacement(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const DebtSuccessPage()),
                              );
                            } else {
                              Fluttertoast.showToast(
                                msg: "Payment Failed!",
                                toastLength: Toast.LENGTH_SHORT,
                                gravity: ToastGravity
                                    .BOTTOM, // You can change this to CENTER or TOP
                                backgroundColor: Colors.red,
                                textColor: Colors.white,
                                fontSize: 16.0,
                              );
                            }

                            setState(() =>
                                _isProcessing = false); // ✅ Stop processing
                          },
                    child: _isProcessing
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            "Pay Debt",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white),
                          ),
                  ),
                ),
              ],
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
          Text(label,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          Text(value,
              style:
                  const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  // ✅ Payment Input Fields with Validation
  Widget _buildPaymentField(String label, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700)),
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
              prefixIcon: Text("₱ ",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
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
