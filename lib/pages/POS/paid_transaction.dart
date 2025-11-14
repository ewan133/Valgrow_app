import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:valgrow_ui/pages/POS/receipt.dart';
import 'package:valgrow_ui/pages/POS/sucess_page.dart';
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
  bool _isProcessing = false;

  void initState() {
    super.initState();
    //_checkAndStartTutorial();
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
  double _receivedAmount = 0.00;
  String _selectedPaymentMethod = "Cash"; // Default selection
  bool _isAmountValid = true; // Track if entered amount is valid

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    // ✅ Calculate total from basket dynamically
    double totalAmount = databaseProvider.basket.fold(0.0, (sum, item) {
      return sum + (item.total_stock * (item.regular_price ?? 0.0));
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  const Text(
                    "Payment Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Total Amount (Dynamic)
                  _buildSummaryCard(
                    key: totalAmountKey,
                    title: "Total Amount",
                    value: "₱${totalAmount.toStringAsFixed(2)}",
                  ),

                  const SizedBox(height: 15),

                  // Receiving Amount (User Input)
                  _buildInputField(
                    key: receivedAmountKey,
                    label: "Enter Received Amount",
                    controller: _receivingAmountController,
                    onChanged: (value) => _calculateChange(value, totalAmount),
                  ),

                  if (!_isAmountValid ||
                      _receivingAmountController.text.isEmpty)
                    const Padding(
                      padding: EdgeInsets.only(top: 5),
                      child: Text(
                        "⚠ Please enter a valid amount",
                        style: TextStyle(color: Colors.red, fontSize: 14),
                      ),
                    ),

                  const SizedBox(height: 15),

                  // Change (Read-Only)
                  _buildSummaryCard(
                    key: changeAmountKey,
                    title: "Change",
                    value: "₱${_change.toStringAsFixed(2)}",
                  ),

                  const SizedBox(height: 15),

                  // Payment Method Dropdown
                  _buildDropdownField(
                    key: paymentMethodKey,
                    label: "Select Payment Method",
                    items: ["Cash", "Gcash"],
                  ),

                  const SizedBox(height: 15),

                  if (_selectedPaymentMethod == "Gcash")
                    // Receiving Amount (User Input)
                    _buildInputField(
                      label: "Enter last 4 digit of Reference No.",
                      hint: "Enter reference number",
                      maxLength: 4,
                      controller: _referenceController,
                    ),

                  const SizedBox(height: 25),

                  // Confirm Payment Button (Disabled if amount is insufficient)
                  SizedBox(
                    key: confirmButtonKey,
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _isAmountValid && !_isProcessing
                            ? const Color(0xFF14AE5C)
                            : Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: _isAmountValid &&
                              !_isProcessing &&
                              _receivingAmountController.text.isNotEmpty &&
                              ((_selectedPaymentMethod == "Gcash" &&
                                      _referenceController.text.isNotEmpty &&
                                      _referenceController.text.length == 4) ||
                                  (_selectedPaymentMethod == "Cash"))
                          ? () {
                              _confirmPayment(totalAmount);
                            }
                          : null, // Disable button if amount is empty or invalid
                      child: _isProcessing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text(
                                  "Processing...",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              "Confirm Payment",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                      height: 60), // Extra space to avoid navigation bar
                ],
              ),
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 5),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          keyboardType: const TextInputType.numberWithOptions(
              decimal: true, signed: false),
          onChanged: (value) {
            // ✅ Remove any negative signs and non-numeric characters except decimal point
            String filtered = value.replaceAll(RegExp(r'[^0-9.]'), '');

            // ✅ Ensure only one decimal point
            int decimalCount = '.'.allMatches(filtered).length;
            if (decimalCount > 1) {
              int firstDecimalIndex = filtered.indexOf('.');
              filtered = filtered.substring(0, firstDecimalIndex + 1) +
                  filtered.substring(firstDecimalIndex + 1).replaceAll('.', '');
            }

            // ✅ Update controller if value changed
            if (filtered != value) {
              controller.value = TextEditingValue(
                text: filtered,
                selection: TextSelection.collapsed(offset: filtered.length),
              );
            }

            // ✅ Call the onChanged callback if provided
            if (onChanged != null) {
              onChanged(filtered);
            }
          },
          maxLength: maxLength ?? 100000,
          decoration: InputDecoration(
            hintText: hint ?? "Enter amount",
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            filled: true,
            fillColor: Colors.white,
            counterText: "", // This hides the character counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade400),
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
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            border: Border.all(color: Colors.grey.shade400),
            borderRadius: BorderRadius.circular(8),
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
              items: items.map((String item) {
                return DropdownMenuItem<String>(
                  value: item,
                  child: Text(
                    item,
                    style: const TextStyle(fontSize: 16),
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

      _receivedAmount = receivedAmount;
      // ✅ Change should never be negative - if payment is less than total, change is 0
      _change = (receivedAmount - totalAmount).clamp(0, double.infinity);
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15), // ✅ Rounded corners
          ),
          title: const Text(
            "Confirm Payment",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to proceed with this transaction?\n\n"
            "Total Amount: ₱${totalAmount.toStringAsFixed(2)}\n"
            "Received Amount: ₱${receivedAmount.toStringAsFixed(2)}\n"
            "Change: ₱${(receivedAmount - totalAmount).clamp(0, double.infinity).toStringAsFixed(2)}\n"
            "${isDebt ? "This will be recorded as debt." : "Transaction will be marked as paid."}",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            // ❌ Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog without saving
              },
              child: const Text(
                "Cancel",
                style: TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),

            // ✅ Confirm Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ✅ Close modal
                _processPayment(
                    totalAmount, receivedAmount, isDebt); // ✅ Process payment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
              child: const Text(
                "Confirm",
                style: TextStyle(fontSize: 16, color: Colors.white),
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
    setState(() {
      _isProcessing = true;
    });

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
        _isProcessing = false;
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
      setState(() {
        _isProcessing = false;
      });

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
