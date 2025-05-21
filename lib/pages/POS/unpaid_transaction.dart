import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/pages/POS/customer_selection.dart';
import 'package:valgrow_ui/pages/POS/receipt.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

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
  }

  void _confirmPayment() {
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
      return sum + (item.total_stock * (item.unpaid_price ?? 0.0));
    });

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
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
                  title: "Total Amount",
                  value: "₱${totalAmount.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 15),

                // Receiving Amount (User Input)
                _buildInputField(
                  label: "Customer Money (for partial payments)",
                  controller: _receivingAmountController,
                  maxLength: 6,
                  onChanged: (value) => _calculateBalance(value, totalAmount),
                ),

                const SizedBox(height: 15),

                // Payment Method Dropdown
                _buildDropdownField(
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
                  title: "Balance",
                  value: "₱${_balance.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 15),

                // Customer Name Selection Field
                _buildSelectionField(
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
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14AE5C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: () {
                      _confirmPayment();
                    },
                    child: const Text(
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
                    height: 20), // Extra space to avoid keyboard overflow
              ],
            ),
          ),
        );
      },
    );
  }

  // Function to build summary cards for Total Amount & Balance
  Widget _buildSummaryCard({required String title, required String value}) {
    return Container(
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
  }) {
    return Column(
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
  }) {
    return Column(
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
// Function to build user input field
Widget _buildInputField({
  required String label,
  required TextEditingController controller,
  String? hint,
  int? maxLength,
  Function(String)? onChanged,
}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        label,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
      ),
      const SizedBox(height: 5),
      TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        onChanged: onChanged,
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
  required BuildContext context,
  required String label,
  required DateTime? value, // Accepts DateTime? instead of String
  required Function(DateTime) onDatePicked, // Pass DateTime instead of String
}) {
  return Column(
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
            firstDate: DateTime(2000),
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
