import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/models/customer_model.dart';
import 'package:valgrow_ui/pages/POS/customer_selection.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class UnpaidTransaction extends StatefulWidget {
  const UnpaidTransaction({super.key});

  @override
  State<UnpaidTransaction> createState() => _UnpaidTransactionState();
}

class _UnpaidTransactionState extends State<UnpaidTransaction> {
  final TextEditingController _receivingAmountController =
      TextEditingController();

  double _receivedAmount = 0.00;
  double _balance = 0.00;
  CustomerDetails? _selectedCustomer; // Default customer
  String _selectedDueDate = "MM/DD/YYYY"; // Default Due Date


  @override
  Widget build(BuildContext context) {
    final databaseProvider = Provider.of<DatabaseProvider>(context);

    // ✅ Calculate total from basket dynamically
    double totalAmount = databaseProvider.basket.fold(0.0, (sum, item) {
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
                  label: "Enter Received Amount",
                  controller: _receivingAmountController,
                  onChanged: (value) => _calculateBalance(value, totalAmount),
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
                  selectedValue: _selectedCustomer?.name ?? "Select or Add", // ✅ Fix: Avoid force unwrapping null
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
                  label: "Due Date",
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
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF14AE5C),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: () {
                      // _saveTransaction(totalAmount);
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
      padding: const EdgeInsets.all(15),
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

  // Function to auto-calculate balance
  void _calculateBalance(String value, double totalAmount) {
    double receivedAmount = double.tryParse(value) ?? 0.0;
    setState(() {
      _receivedAmount = receivedAmount;
      _balance = totalAmount - receivedAmount;
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
            onItemSelected: onItemSelected, selectedCustomer: null,);
      },
    );
  }
}

// Function to build user input field
Widget _buildInputField({
  required String label,
  required TextEditingController controller,
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

      /// ✅ Wrapping the TextField inside a `Container` to apply shadow
      Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8), // ✅ Adds rounded corners
          boxShadow: [
            BoxShadow(
                color: Colors.black, // ✅ Soft shadow
                blurRadius: 0,
                offset: const Offset(0, 0), // ✅ Moves shadow downward slightly
                spreadRadius: 1),
          ],
        ),
        child: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          onChanged: onChanged,
          decoration: const InputDecoration(
            hintText: "Enter amount",
            contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderSide: BorderSide.none, // ✅ No extra border
              borderRadius: BorderRadius.all(
                  Radius.circular(8)), // ✅ Match outer container
            ),
          ),
        ),
      ),
    ],
  );
}

Widget _buildDatePickerField({
  required BuildContext context, // ✅ Pass context as a required parameter
  required String label,
  required String value,
  required Function(String) onDatePicked,
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
            context: context, // ✅ Now using the passed context correctly
            initialDate: DateTime.now(),
            firstDate: DateTime(2000),
            lastDate: DateTime(2101),
          );
          if (pickedDate != null) {
            onDatePicked(
                "${pickedDate.month}/${pickedDate.day}/${pickedDate.year}");
          }
        },
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
          decoration: BoxDecoration(
            color: const Color(0xFFF6F6F6),
            borderRadius: BorderRadius.circular(8), // ✅ Rounded corners
            boxShadow: [
              BoxShadow(
                color: Colors.black, // ✅ Simulating a black border
                blurRadius: 0,
                offset: const Offset(0, 0), // ✅ Ensures sharp edges
                spreadRadius: 1, // ✅ Makes it look like a solid border
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
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
