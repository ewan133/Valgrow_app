import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class PaidTransaction extends StatefulWidget {
  const PaidTransaction({super.key});

  @override
  State<PaidTransaction> createState() => _PaidTransactionState();
}

class _PaidTransactionState extends State<PaidTransaction> {
  final TextEditingController _receivingAmountController =
      TextEditingController();
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
        return SingleChildScrollView(
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
                  title: "Total Amount",
                  value: "₱${totalAmount.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 15),

                // Receiving Amount (User Input)
                _buildInputField(
                  label: "Enter Received Amount",
                  controller: _receivingAmountController,
                  onChanged: (value) => _calculateChange(value, totalAmount),
                ),

                if (!_isAmountValid)
                  const Padding(
                    padding: EdgeInsets.only(top: 5),
                    child: Text(
                      "⚠ Amount must be at least the total",
                      style: TextStyle(color: Colors.red, fontSize: 14),
                    ),
                  ),

                const SizedBox(height: 15),

                // Change (Read-Only)
                _buildSummaryCard(
                  title: "Change",
                  value: "₱${_change.toStringAsFixed(2)}",
                ),

                const SizedBox(height: 15),

                // Payment Method Dropdown
                _buildDropdownField(
                  label: "Select Payment Method",
                  items: ["Cash", "Gcash"],
                ),

                const SizedBox(height: 25),

                // Confirm Payment Button (Disabled if amount is insufficient)
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          _isAmountValid ? const Color(0xFF14AE5C) : Colors.grey,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(100),
                      ),
                    ),
                    onPressed: _isAmountValid
                        ? () {
                            _confirmPayment(totalAmount);
                          }
                        : null, // Disable button if amount is invalid
                    child: const Text(
                      "Confirm Payment",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
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
  Widget _buildSummaryCard({required String title, required String value}) {
    return Container(
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
          decoration: InputDecoration(
            hintText: "Enter amount",
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 15),
            filled: true,
            fillColor: Colors.white,
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

  // Function to auto-calculate change and validate received amount
  void _calculateChange(String value, double totalAmount) {
    double receivedAmount = _parseCurrency(value);

    setState(() {
      _receivedAmount = receivedAmount;
      _change = receivedAmount - totalAmount;
      _isAmountValid = receivedAmount >= totalAmount;
    });
  }

  // Function to parse currency values safely
  double _parseCurrency(String value) {
    return double.tryParse(value.replaceAll(RegExp(r'[^0-9.]'), '')) ?? 0.0;
  }

  // ✅ Function to confirm payment and call `processPOS()`
  void _confirmPayment(double totalAmount) {
    final databaseProvider =
        Provider.of<DatabaseProvider>(context, listen: false);

    double receivedAmount = _parseCurrency(_receivingAmountController.text);
    bool isDebt = receivedAmount < totalAmount; // ✅ If received amount < total, it's a debt

    print("✅ Processing Payment...");
    databaseProvider.processPOS(
      totalAmount: totalAmount,
      amountPaid: receivedAmount,
      paymentMethod: _selectedPaymentMethod.toLowerCase(),
      customerId: null, 
      isDebt: isDebt,
    );

    // ✅ Reset UI
    setState(() {
      _receivingAmountController.clear();
      _change = 0.00;
      _selectedPaymentMethod = "Cash";
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text("Payment ${isDebt ? 'on Debt' : 'Completed'} Successfully!"),
        backgroundColor: Colors.green,
      ),
    );
  }
}
