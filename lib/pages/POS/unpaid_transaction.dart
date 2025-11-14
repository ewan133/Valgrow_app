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
  bool _isProcessing = false; // Loading state

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
          return sum + (item.total_stock * (item.unpaid_price ?? 0.0));
        });
        _balance = totalAmount; // ✅ Set _balance to totalAmount
      });
    });

    //_checkAndStartTutorial();
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
            borderRadius: BorderRadius.circular(15), // ✅ Rounded corners
          ),
          title: const Text(
            "Confirm Transaction",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "Are you sure you want to save this transaction?\n\n"
            "Customer: ${_selectedCustomer!.name}\n"
            "Total Amount: ₱${totalAmount.toStringAsFixed(2)}\n"
            "Received Amount: ₱${_receivedAmount.toStringAsFixed(2)}\n"
            "Balance: ₱${_balance.toStringAsFixed(2)}",
            style: const TextStyle(fontSize: 16),
          ),
          actions: [
            // ❌ Cancel Button
            TextButton(
              onPressed: () {
                Navigator.pop(context); // ✅ Close modal without saving
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
                _processPayment(); // ✅ Call function to process payment
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

  /// ✅ Function to Process Payment (Moved from `_confirmPayment()`)
  void _processPayment() async {
    if (!mounted) return;
    setState(() {
      _isProcessing = true;
    });

    try {
      final databaseProvider =
          Provider.of<DatabaseProvider>(context, listen: false);

      print("✅ Processing Payment...");
      String? transactionId = await databaseProvider.processPOS(
          totalAmount: totalAmount,
          amountPaid: _receivedAmount.toDouble() ?? 0.00,
          paymentMethod: "debt",
          customerId: _selectedCustomer!.customerId,
          isDebt: true,
          due_date: _selectedDueDate,
          customerName: _selectedCustomer!.name,
          reference_number: _referenceController.text);

      // ✅ Reset UI
      if (!mounted) return;
      setState(() {
        _receivingAmountController.clear();
        _balance = 0.00;
        _selectedCustomer = null;
        _selectedDueDate = null;
        _isProcessing = false;
      });

      // ✅ Navigate to Success Page
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => ReceiptPage(
            transactionId: transactionId!, // Pass actual transaction ID
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
      });
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

  /// ✅ Function to show Terms and Conditions Modal
  void _showTermsAndConditions(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Container(
            constraints: BoxConstraints(
              maxHeight: MediaQuery.of(context).size.height * 0.8,
              maxWidth: 600,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade700,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.description,
                          color: Colors.white, size: 28),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          "Terms of Agreement for Debt Recording",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                ),
                // Content
                Flexible(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Please read this agreement carefully before proceeding.\nBy checking the box below or continuing to use the ValGrow system, you acknowledge that you have read, understood, and agreed to the following Terms of Agreement between the Business Owner and the Customer.",
                          style: TextStyle(fontSize: 14, height: 1.5),
                        ),
                        const SizedBox(height: 20),
                        _buildTermSection(
                          "1. Purpose of Agreement",
                          "This Terms of Agreement (\"Agreement\") governs the use of the Utang Tracker feature in ValGrow, an Inventory and POS Management System developed for micro business. It ensures that all debt transactions (\"utang\") recorded through ValGrow are legitimate, transparent, and made with the consent of both the Customer and the Business Owner.",
                        ),
                        _buildTermSection(
                          "2. Consent and Authorization",
                          "By proceeding, you (the Customer) expressly consent to:\n\n• The recording of your debt transaction in the ValGrow system.\n\n• The collection of your name, contact number, and profile photo solely for transaction verification and communication purposes.\n\n• The use of your transaction data to track balances, due dates, and payment history.\n\nYou acknowledge that this digital confirmation serves as your explicit consent and digital signature for the transaction.",
                        ),
                        _buildTermSection(
                          "3. Business Owner's Responsibility",
                          "The Business Owner agrees to:\n\n• Record only legitimate and agreed-upon transactions with real customers.\n\n• Obtain the Customer's verbal or written consent before creating a debt record in the system.\n\n• Use accurate information (name, contact number, and photo) when adding customers.\n\n• Avoid misuse of the system by adding fake accounts or unauthorized entries.\n\nValGrow and its developers shall not be held liable for any misuse or false entries made by business owners or staff.",
                        ),
                        _buildTermSection(
                          "4. Customer's Responsibility",
                          "The Customer agrees to:\n\n• Verify and confirm that all recorded debt transactions in ValGrow are correct.\n\n• Pay the amount owed according to the agreed payment schedule.\n\n• Contact the business owner directly for clarifications or disputes regarding recorded debts.",
                        ),
                        _buildTermSection(
                          "5. Data Privacy and Protection",
                          "• All customer data recorded in ValGrow (name, number, transaction details) will be stored securely and used only for business transaction purposes.\n\n• Personal information will not be shared with third parties except as required by law or upon written consent.\n\n• Users have the right to request correction or deletion of inaccurate data by contacting the business owner.",
                        ),
                        _buildTermSection(
                          "6. Dispute and Verification",
                          "In case of discrepancies or disputes:\n\n• The Customer and Business Owner should attempt to resolve issues through direct communication.\n\n• If unresolved, either party may seek assistance from the Barangay Representative who supervises ValGrow usage in the area.",
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: const BorderRadius.only(
                      bottomLeft: Radius.circular(16),
                      bottomRight: Radius.circular(16),
                    ),
                  ),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue.shade700,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text(
                        "I Understand",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
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

  /// Helper widget to build each term section
  Widget _buildTermSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            content,
            style: const TextStyle(
              fontSize: 14,
              height: 1.6,
              color: Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    // ✅ Calculate total from basket dynamically
    totalAmount = databaseProvider.basket.fold(0.0, (sum, item) {
      return sum + (item.total_stock * (item.unpaid_price ?? 0.0));
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
                  // Header
                  const Text(
                    "Unpaid Transaction Details",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 15),

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

                  const SizedBox(height: 2),

                  // Terms and Conditions Button
                  Align(
                    alignment: Alignment.centerLeft,
                    child: TextButton.icon(
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        foregroundColor: Colors.blue.shade700,
                      ),
                      onPressed: () => _showTermsAndConditions(context),
                      icon: Icon(Icons.description_outlined, size: 16),
                      label: Text(
                        "View Terms and Conditions",
                        style: TextStyle(
                          fontSize: 14,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
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
                    height: 50,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF14AE5C),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(100),
                        ),
                      ),
                      onPressed: _isProcessing
                          ? null
                          : () {
                              _confirmPayment();
                            },
                      child: _isProcessing
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: const [
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
                              "Save Transaction",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),
                  const SizedBox(
                      height:
                          60), // Extra space to avoid keyboard and nav bar overlap
                ],
              ),
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
      padding: const EdgeInsets.only(top: 15, left: 15, right: 15, bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF6F6F6),
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade400, // ✅ Softer shadow instead of border
            blurRadius: 4,
            offset: const Offset(0, 2), // ✅ Moves shadow downward
          ),
        ],
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
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            /// ✅ Non-typable Text Field
            Expanded(
              child: TextField(
                controller: TextEditingController(text: selectedValue),
                readOnly: true,
                decoration: InputDecoration(
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade400),
                  ),
                  filled: true,
                  fillColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),

            /// ✅ "Choose" Button to Open Selection Modal
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              onPressed: () => _showSelectionModal(
                context: context,
                selectedValue: selectedValue,
                onItemSelected: onItemSelected,
              ),
              child: const Text(
                "Choose",
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ),
          ],
        ),
      ],
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
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
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
}

// Function to build user input field
Widget _buildInputField({
  Key? key,
  required String label,
  required TextEditingController controller,
  String? hint,
  int? maxLength,
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
        keyboardType:
            const TextInputType.numberWithOptions(decimal: true, signed: false),
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

Widget _buildDatePickerField({
  Key? key,
  required BuildContext context,
  required String label,
  required DateTime? value, // Accepts DateTime? instead of String
  required Function(DateTime) onDatePicked, // Pass DateTime instead of String
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
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(8),
            boxShadow: [
              BoxShadow(
                color: Colors.black,
                blurRadius: 0,
                offset: const Offset(0, 0),
                spreadRadius: 1,
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value != null
                    ? "${value.month}/${value.day}/${value.year}" // Properly formatted date
                    : "Select Due Date", // Placeholder if no date is selected
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black,
                ),
              ),
              const Icon(Icons.calendar_today, color: Colors.black),
            ],
          ),
        ),
      ),
    ],
  );
}
