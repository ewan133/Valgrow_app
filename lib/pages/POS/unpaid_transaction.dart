import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/pages/POS/customer_selection.dart';
import 'package:valgrow_ui/pages/POS/receipt.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';
import 'package:valgrow_ui/components/global_keys.dart';

class UnpaidTransaction extends StatefulWidget {
  const UnpaidTransaction({super.key});

  @override
  State<UnpaidTransaction> createState() => _UnpaidTransactionState();
}

class _UnpaidTransactionState extends State<UnpaidTransaction> {
  final TextEditingController _receivingAmountController =
      TextEditingController();
  final TextEditingController _referenceController = TextEditingController();

  double _receivedAmount = 0.00;
  double _balance = 00.0;
  CustomerDetails? _selectedCustomer; // Default customer
  double totalAmount = 0.00;
  DateTime? _selectedDueDate; // Default Due Date
  String _selectedPaymentMethod = "Cash"; // Default selection

  TutorialCoachMark? tutorialCoachMark;
  List<TargetFocus> myTargets = [];

  nowStart(_) {
    Future.delayed(Duration(seconds: 1));
    tutorialCoachMark = TutorialCoachMark(targets: myTargets)
      ..show(context: context);
  }

  void _checkAndStartTutorial() async {
    final prefs = await SharedPreferences.getInstance();
    final hasShownTutorial = prefs.getBool('hasShownUnpaidTutorial') ?? false;

    if (!hasShownTutorial) {
      // Add your target
      addMyTargets(
          totalUnpaidAmountKey,
          "totalUnpaidAmountKey",
          ContentAlign.bottom,
          "Shows the total cost of all items in the cart.");

      addMyTargets(
          unpaidReceivedAmountKey,
          "unpaidReceivedAmountKey",
          ContentAlign.bottom,
          "Enter the amount of money provided by the customer if they will pay partially.");

      addMyTargets(
          unpaidPaymentMethodKey,
          "unpaidPaymentMethodKey",
          ContentAlign.top,
          "Choose the payment method, such as Cash or GCash.");

      addMyTargets(unpaidBalanceKey, "unpaidBalanceKey", ContentAlign.top,
          "Automatically calculates and displays the customer's remaining balance.");

      addMyTargets(selectCustomerKey, "selectCustomerKey", ContentAlign.top,
          "Select an existing customer or add a new one.");

      addMyTargets(setUnpaidDuedateKey, "setUnpaidDuedateKey", ContentAlign.top,
          "Set the due date for the unpaid amount.");

      addMyTargets(unpaidSaveButtonKey, "unpaidSaveButtonKey", ContentAlign.top,
          "Click to save and finalize the unpaid transaction.");

      // Delay and start the tutorial
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Future.delayed(const Duration(seconds: 1), () {
          tutorialCoachMark = TutorialCoachMark(targets: myTargets)
            ..show(context: context);

          // Set the flag so it won't show again
          prefs.setBool('hasShownUnpaidTutorial', false);
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

  @override
  void initState() {
    super.initState();
    // ✅ Fetch totalAmount dynamically
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final databaseProvider =
          Provider.of<DatabaseProvider>(context, listen: false);
      setState(() {
        totalAmount = databaseProvider.basket.fold(0.0, (sum, item) {
          return sum + (item.total_stock * item.unpaid_price);
        });
        _balance = totalAmount; // ✅ Set _balance to totalAmount
      });
    });

    _checkAndStartTutorial();
  }

  void _confirmPayment() {
    if (_balance < 100) {
      Fluttertoast.showToast(
        msg: "Unpaid transactions must have a minimum balance of ₱100.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // Position: BOTTOM, CENTER, or TOP
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return; // ❌ Stop function execution if no customer is selected
    }

    // ✅ Ensure a customer is selected before proceeding
    if (_selectedCustomer == null) {
      Fluttertoast.showToast(
        msg: "Please select a customer before saving the transaction.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP, // Position: BOTTOM, CENTER, or TOP
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return; // ❌ Stop function execution if no customer is selected
    }
    double? receivingAmount = double.tryParse(_receivingAmountController.text);
    if (receivingAmount != null &&
        _receivingAmountController.text.isNotEmpty &&
        receivingAmount >= totalAmount) {
      Fluttertoast.showToast(
        msg: "Please use the 'Paid' tab for full payments.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // Position: BOTTOM, CENTER, or TOP
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return; // ❌ Stop function execution if no customer is selected
    }

    if (_selectedPaymentMethod == "Gcash" &&
        _referenceController.text.isEmpty) {
      Fluttertoast.showToast(
        msg: "Please enter the reference number.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // Position: BOTTOM, CENTER, or TOP
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return; // ❌ Stop function execution if no customer is selected
    }

    if (_selectedPaymentMethod == "Gcash" &&
        _referenceController.text.isNotEmpty &&
        _referenceController.text.length != 4) {
      Fluttertoast.showToast(
        msg: "Please enter a valid reference number.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM, // Position: BOTTOM, CENTER, or TOP
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return; // ❌ Stop function execution if no customer is selected
    }

    if (_selectedDueDate != null &&
        _selectedDueDate!.isBefore(DateTime.now())) {
      Fluttertoast.showToast(
        msg: "Please select a valid due date.",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
      return;
    }

    // ✅ Show Confirmation Dialog
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12), // ✅ Rounded corners
          ),
          title: Text(
            "Confirm Transaction",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
          content: Text(
            "Are you sure you want to save this transaction?\n\n"
            "Customer: ${_selectedCustomer!.name}\n"
            "Total Amount: ₱${totalAmount.toStringAsFixed(2)}\n"
            "Received Amount: ₱${_receivedAmount.toStringAsFixed(2)}\n"
            "Balance: ₱${_balance.toStringAsFixed(2)}",
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.black.withOpacity(0.8),
            ),
          ),
          actions: [
            // ❌ Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ✅ Close modal without saving
              },
              child: Text(
                "Cancel",
                style: TextStyle(
                  color: Colors.red,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // ✅ Confirm Button
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // ✅ Close modal
                _processPayment(); // ✅ Call function to process payment
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14AE5C),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
              child: Text(
                "Confirm",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  /// ✅ Function to Process Payment (Moved from `_confirmPayment()`)
  void _processPayment() async {
    try {
      final databaseProvider =
          Provider.of<DatabaseProvider>(context, listen: false);

      print("✅ Processing Payment...");
      String? transactionId = await databaseProvider.processPOS(
          totalAmount: totalAmount,
          amountPaid: _receivedAmount,
          paymentMethod: "debt",
          customerId: _selectedCustomer!.customerId,
          isDebt: true,
          due_date: _selectedDueDate,
          customerName: _selectedCustomer!.name,
          reference_number: _referenceController.text);

      // ✅ Reset UI
      setState(() {
        _receivingAmountController.clear();
        _balance = 0.00;
        _selectedCustomer = null;
        _selectedDueDate = null;
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
        msg: "Something Went Wrong!",
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.TOP,
        backgroundColor: Colors.red,
        textColor: Colors.white,
        fontSize: 16.0,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    // ✅ Calculate total from basket dynamically
    totalAmount = databaseProvider.basket.fold(0.0, (sum, item) {
      return sum + (item.total_stock * item.unpaid_price);
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
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.06),
                        blurRadius: 16,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Unpaid Transaction",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: Colors.black,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "Configure partial payment details",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black.withOpacity(0.6),
                          fontWeight: FontWeight.w500,
                          letterSpacing: 0.3,
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                // Total Amount (Read-Only)
                _buildSummaryCard(
                  key: totalUnpaidAmountKey,
                  title: "Total Amount",
                  value: "₱${totalAmount.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 15),

                // Receiving Amount (User Input)
                _buildInputField(
                  key: unpaidReceivedAmountKey,
                  label: "Customer Money (for partial payments)",
                  controller: _receivingAmountController,
                  maxLength: 6,
                  onChanged: (value) => _calculateBalance(value, totalAmount),
                ),

                const SizedBox(height: 15),

                // Payment Method Dropdown
                _buildDropdownField(
                  key: unpaidPaymentMethodKey,
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
                const SizedBox(height: 15),
                // Balance (Auto Calculated)
                _buildSummaryCard(
                  key: unpaidBalanceKey,
                  title: "Balance",
                  value: "₱${_balance.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 15),

                // Customer Name Selection Field
                _buildSelectionField(
                  key: selectCustomerKey,
                  label: "Select Customer",
                  selectedValue: _selectedCustomer?.name ??
                      "Select or Add", // ✅ Fix: Avoid force unwrapping null
                  onItemSelected: (newValue) {
                    setState(() {
                      if (newValue == "+ New Customer") {
                        //_showNewCustomerDialog();
                      } else {
                        _selectedCustomer = newValue;
                      }
                    });
                  },
                  context: context,
                ),

                const SizedBox(height: 15),

                // Due Date Picker
                _buildDatePickerField(
                  key: setUnpaidDuedateKey,
                  label: "Due Date (default 2 weeks from now)",
                  value: _selectedDueDate,
                  onDatePicked: (newDate) {
                    setState(() {
                      _selectedDueDate = newDate;
                    });
                  },
                  context: context,
                ),

                const SizedBox(height: 25),

                // Save Transaction Button
                SizedBox(
                  key: unpaidSaveButtonKey,
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14AE5C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    onPressed: () {
                      _confirmPayment();
                    },
                    child: Text(
                      "Save Transaction",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                        letterSpacing: -0.2,
                      ),
                    ),
                  ),
                ),
                const SizedBox(
                    height: 20), // Extra space to avoid keyboard overflow
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to build summary cards for Total Amount & Balance
  Widget _buildSummaryCard(
      {required String title, required String value, Key? key}) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Colors.black.withOpacity(0.7),
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: Colors.black,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ),
    );
  }

  // Function to auto-calculate balance and prevent negative values
  void _calculateBalance(String value, double totalAmount) {
    double receivedAmount = double.tryParse(value) ?? 0.0;

    // Ensure received amount does not exceed totalAmount
    if (receivedAmount > totalAmount) {
      receivedAmount = totalAmount;
      _receivingAmountController.text =
          totalAmount.toStringAsFixed(2); // Update input field
    }

    setState(() {
      _receivedAmount = receivedAmount;
      _balance = (totalAmount - receivedAmount)
          .clamp(0.0, double.infinity); // Prevent negative balance
    });
  }

  /// Function to build a selection field with a "Choose" button
  Widget _buildSelectionField({
    required String label,
    required String selectedValue,
    required Function(CustomerDetails) onItemSelected,
    required BuildContext context,
    Key? key,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              /// ✅ Non-typable Text Field
              Expanded(
                child: TextField(
                  controller: TextEditingController(text: selectedValue),
                  readOnly: true,
                  decoration: InputDecoration(
                    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFFF6F6F6)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFFF6F6F6)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: const Color(0xFF14AE5C)),
                    ),
                    filled: true,
                    fillColor: const Color(0xFFF6F6F6),
                  ),
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(width: 16),

              /// ✅ "Choose" Button to Open Selection Modal
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  backgroundColor: const Color(0xFF14AE5C),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: () => _showSelectionModal(
                  context: context,
                  selectedValue: selectedValue,
                  onItemSelected: onItemSelected,
                ),
                child: Text(
                  "Choose",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Function to show the selection modal
  void _showSelectionModal({
    required BuildContext context,
    required String selectedValue,
    required Function(CustomerDetails) onItemSelected,
  }) {
    showModalBottomSheet(
      isScrollControlled: true,
      context: context,
      isDismissible: false,
      backgroundColor: Colors.white,
      builder: (context) {
        return CustomerSelectionModal(
          selectedValue: selectedValue,
          onItemSelected: onItemSelected,
          selectedCustomer: null,
        );
      },
    );
  }

  // Function to build dropdown field
  Widget _buildDropdownField({
    required String label,
    required List<String> items,
    Key? key,
  }) {
    return Container(
      key: key,
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: Colors.black,
              letterSpacing: 0.3,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF6F6F6)),
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
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
                items: items.map((String item) {
                  return DropdownMenuItem<String>(
                    value: item,
                    child: Text(
                      item,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Function to build user input field
// Function to build user input field
Widget _buildInputField({
  Key? key,
  required String label,
  required TextEditingController controller,
  String? hint,
  int? maxLength,
  Function(String)? onChanged,
}) {
  return Container(
    key: key,
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),
        TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          maxLength: maxLength ?? 100000,
          decoration: InputDecoration(
            hintText: hint ?? "Enter amount",
            hintStyle: TextStyle(
              color: Colors.black.withOpacity(0.5),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            filled: true,
            fillColor: const Color(0xFFF6F6F6),
            counterText: "", // This hides the character counter
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFF6F6F6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFFF6F6F6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: const Color(0xFF14AE5C)),
            ),
          ),
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    ),
  );
}

Widget _buildDatePickerField({
  Key? key,
  required BuildContext context,
  required String label,
  required DateTime? value, // Accepts DateTime? instead of String
  required Function(DateTime) onDatePicked, // Pass DateTime instead of String
}) {
  return Container(
    key: key,
    width: double.infinity,
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(12),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 2),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 16),

        /// ✅ Date Picker Field with Box Shadow Instead of Border
        GestureDetector(
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: value ?? DateTime.now(),
              firstDate: DateTime.now(),
              lastDate: DateTime(2101),
            );
            if (pickedDate != null) {
              onDatePicked(
                  pickedDate); // Return DateTime instead of formatted string
            }
          },
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFFF6F6F6)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  value != null
                      ? "${value.month}/${value.day}/${value.year}" // Properly formatted date
                      : "Select Due Date", // Placeholder if no date is selected
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
                ),
                Icon(Icons.calendar_today, color: Colors.black.withOpacity(0.7), size: 20),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}
