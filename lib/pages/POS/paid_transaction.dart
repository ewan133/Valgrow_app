import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:valgrow_ui/pages/POS/receipt.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/components/global_keys.dart';

class PaidTransaction extends StatefulWidget {
  const PaidTransaction({super.key});

  @override
  State<PaidTransaction> createState() => _PaidTransactionState();
}

class _PaidTransactionState extends State<PaidTransaction> {
  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> myTargets = [];

  void initState() {
    super.initState();
    _checkAndStartTutorial();
  }

  nowStart(_) {
    Future.delayed(Duration(seconds: 1));
    tutorialCoachMark = TutorialCoachMark(targets: myTargets)
      ..show(context: context);
  }

  void _checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownTutorial = prefs.getBool('hasShownPaidTutorial') ?? false;

    if (!hasShownTutorial) {
      // Add your targets
      addMyTargets(unpaidTabKey, "myUnpaidTab", ContentAlign.bottom,
          "Go to this tab if you are processing unpaid transactions (utang).");

      addMyTargets(paidTabKey, "myUnpaidTab", ContentAlign.bottom,
          "Go to this tab if you are processing paid transaction.");

      addMyTargets(totalAmountKey, "myTotalAmmount", ContentAlign.bottom,
          "Displays the total amount for the items in the cart.");

      addMyTargets(receivedAmountKey, "myReceivedAmount", ContentAlign.bottom,
          "Enter the amount of money given by the customer here.");

      addMyTargets(changeAmountKey, "myChangeAmount", ContentAlign.top,
          "Automatically calculates and displays the change for the customer.");

      addMyTargets(paymentMethodKey, "myPaymentMethod", ContentAlign.top,
          "Select the payment method, such as Cash or GCash.");

      addMyTargets(confirmButtonKey, "myConfirmButton", ContentAlign.top,
          "Press this button to confirm and process the transaction.");

      // Delay and start the tutorial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () {
          tutorialCoachMark = TutorialCoachMark(targets: myTargets)
            ..show(context: context);

          // Set the flag so it won't show again
          prefs.setBool('hasShownPaidTutorial', true);
        });
      });
    }
  }

  addMyTargets(GlobalKey target, String identifier, ContentAlign alignment,
      String content) {
    myTargets.add(TargetFocus(
      shape: ShapeLightFocus.RRect,
      radius: 10,
      keyTarget: target,
      identify: identifier,
      contents: [
        TargetContent(
          align: alignment,
          padding: EdgeInsets.only(top: 20, bottom: 20, left: 20, right: 20),
          builder: (context, controller) {
            return Center(
              child: Container(
                margin: const EdgeInsets.all(16.0),
                padding: const EdgeInsets.all(20.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 6,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      content,
                      style: const TextStyle(
                        color: Colors.black, // Black text
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.left,
                    ),
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.bottomRight,
                      child: ElevatedButton(
                        onPressed: () {
                          controller.next();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          "Next",
                          style: TextStyle(fontSize: 16),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        )
      ],
    ));
  }

  final TextEditingController _receivingAmountController =
      TextEditingController();

  final TextEditingController _referenceController = TextEditingController();
  double _change = 0.00;
  String _selectedPaymentMethod = "Cash"; // Default selection
  bool _isAmountValid = true; // Track if entered amount is valid

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    // ✅ Calculate total from basket dynamically
    double totalAmount = databaseProvider.basket.fold(0.0, (sum, item) {
      return sum + (item.total_stock * item.regular_price);
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header Section
                Container(
                  margin: const EdgeInsets.only(bottom: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Payment Details",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Enter payment information to complete transaction",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                // Total Amount (Dynamic)
                _buildSummaryCard(
                  key: totalAmountKey,
                  title: "Total Amount",
                  value: "₱${totalAmount.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 16),

                // Receiving Amount (User Input)
                _buildInputField(
                  key: receivedAmountKey,
                  label: "Enter Received Amount",
                  controller: _receivingAmountController,
                  onChanged: (value) => _calculateChange(value, totalAmount),
                ),

                if (!_isAmountValid || _receivingAmountController.text.isEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.warning_amber_rounded,
                            color: Colors.red,
                            size: 16,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            "Please enter a valid amount",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Change (Read-Only)
                _buildSummaryCard(
                  key: changeAmountKey,
                  title: "Change",
                  value: "₱${_change.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 16),

                // Payment Method Dropdown
                _buildDropdownField(
                  key: paymentMethodKey,
                  label: "Select Payment Method",
                  items: ["Cash", "Gcash"],
                ),

                const SizedBox(height: 16),

                if (_selectedPaymentMethod == "Gcash")
                  // Reference Number Input
                  _buildInputField(
                    label: "Enter last 4 digits of Reference No.",
                    hint: "Enter reference number",
                    maxLength: 4,
                    controller: _referenceController,
                  ),

                const SizedBox(height: 24),

                // Confirm Payment Button
                SizedBox(
                  key: confirmButtonKey,
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isAmountValid
                          ? const Color(0xFF14AE5C)
                          : Colors.grey.withOpacity(0.3),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      disabledBackgroundColor: Colors.grey.withOpacity(0.3),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    onPressed: _isAmountValid &&
                            _receivingAmountController.text.isNotEmpty &&
                            ((_selectedPaymentMethod == "Gcash" &&
                                    _referenceController.text.isNotEmpty &&
                                    _referenceController.text.length == 4) ||
                                (_selectedPaymentMethod == "Cash"))
                        ? () {
                            _confirmPayment(totalAmount);
                          }
                        : null,
                    child: Text(
                      "Confirm Payment",
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20), // Extra space for keyboard safety
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to build summary cards for Total Amount & Change
  Widget _buildSummaryCard(
      {required String title, required String value, Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFFF6F6F6),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              color: Colors.black.withOpacity(0.6),
              fontWeight: FontWeight.w500,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // Function to build user input field
  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    String? hint,
    int? maxLength,
    Key? key,
    Function(String)? onChanged,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          maxLength: maxLength ?? 100000,
          decoration: InputDecoration(
            hintText: hint ?? "Enter amount",
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.4),
              fontSize: 14,
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            filled: true,
            fillColor: Colors.white,
            counterText: "",
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFFF6F6F6),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFFF6F6F6),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: const Color(0xFF14AE5C),
                width: 1,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Function to build dropdown field
  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    Key? key,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      key: key,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border.all(
              color: const Color(0xFFF6F6F6),
              width: 1,
            ),
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedPaymentMethod,
              isExpanded: true,
              onChanged: (newValue) {
                setState(() {
                  _selectedPaymentMethod = newValue!;
                });
              },
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              icon: Icon(
                Icons.keyboard_arrow_down,
                color: Colors.black.withOpacity(0.6),
                size: 20,
              ),
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ],
    );
  }

  // Function to auto-calculate change and validate received amount
  void _calculateChange(String value, double totalAmount) {
    double receivedAmount = _parseCurrency(value);

    setState(() {
      if (value.isEmpty) {
        _isAmountValid = false; // Show error only for empty input
      } else {
        _isAmountValid = receivedAmount >= totalAmount; // Validate amount
      }

      _change = receivedAmount - totalAmount;
    });
  }

  // Function to parse currency values safely
  double _parseCurrency(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  // ✅ Function to confirm payment before processing
  void _confirmPayment(double totalAmount) {
    double receivedAmount = _parseCurrency(_receivingAmountController.text);
    bool isDebt = receivedAmount < totalAmount;

    // ✅ Show Confirmation Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          title: Text(
            "Confirm Payment",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
          content: Text(
            "Are you sure you want to proceed with this transaction?\n\n"
            "Total Amount: ₱${totalAmount.toStringAsFixed(2)}\n"
            "Received Amount: ₱${receivedAmount.toStringAsFixed(2)}\n"
            "Change: ₱${(receivedAmount - totalAmount).clamp(0, double.infinity).toStringAsFixed(2)}\n\n"
            "${isDebt ? "This will be recorded as debt." : "Transaction will be marked as paid."}",
            style: TextStyle(
              fontSize: 14,
              color: Colors.black,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
          actions: [
            // Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.black.withOpacity(0.6),
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),

            // Confirm Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _processPayment(totalAmount, receivedAmount, isDebt);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14AE5C),
                foregroundColor: Colors.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                "Confirm",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

// ✅ Function to process the payment after confirmation
  void _processPayment(
      double totalAmount, double receivedAmount, bool isDebt) async {
    try {
      final databaseProvider =
          Provider.of<DatabaseProvider>(context, listen: false);

      print("✅ Processing Payment...");

      // Calculate Due Date for Debt Transactions (Default: 7 Days from Now)
      DateTime? dueDate =
          isDebt ? DateTime.now().add(const Duration(days: 7)) : null;

      // Ensure at least one payment method is selected
      if (_selectedPaymentMethod.isEmpty) {
        Fluttertoast.showToast(
          msg: "Please select a payment method.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      if (_referenceController.text.isEmpty &&
          _selectedPaymentMethod == "Gcash") {
        Fluttertoast.showToast(
          msg: "Please enter the reference number.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.orange,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      // Ensure user is not paying more than they owe
      if (!isDebt && receivedAmount < totalAmount) {
        Fluttertoast.showToast(
          msg: "Insufficient payment amount.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.TOP,
          backgroundColor: Colors.red,
          textColor: Colors.white,
          fontSize: 16.0,
        );
        return;
      }

      String? transactionId = await databaseProvider.processPOS(
        totalAmount: totalAmount,
        amountPaid: receivedAmount,
        paymentMethod: _selectedPaymentMethod.toLowerCase(),
        customerId: null, // If there's a customer, pass their ID here
        isDebt: isDebt,
        due_date: dueDate,
        reference_number: _referenceController.text,
      );

      // ✅ Reset UI after successful transaction
      setState(() {
        _receivingAmountController.clear();
        _change = 0.00;
        _selectedPaymentMethod = "Cash";
      });

      // ✅ Navigate to Success Page
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPage(
            transactionId: transactionId!, // Pass actual transaction ID
          ),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(
        msg: "❌ Something went wrong: $e",
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }
}
