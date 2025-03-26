import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class ReduceStocksModal extends StatefulWidget {
  final Function(int, String) onSave; // ✅ Callback with reason
  final int currentStock; // ✅ Pass current stock count

  const ReduceStocksModal(
      {super.key, required this.onSave, required this.currentStock});

  @override
  State<ReduceStocksModal> createState() => _ReduceStocksModalState();
}

class _ReduceStocksModalState extends State<ReduceStocksModal> {
  final TextEditingController _stockController = TextEditingController();
  String? _selectedReason; // Stores reason for stock reduction

  // 🔹 Function to show FlutterToast notifications
  void _showToast(String message, {bool isError = false}) {
    Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      backgroundColor: isError ? Colors.red : Colors.green,
      textColor: Colors.white,
      fontSize: 16.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 30), // ✅ Wider modal
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 🔹 Header
            const Text(
              "Reduce Stock",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // 🔹 Number Input Field
            TextField(
              controller: _stockController,
              keyboardType: TextInputType.number,
              enabled: widget.currentStock > 0, // 🔹 Disable if stock is 0
              decoration: InputDecoration(
                labelText: widget.currentStock > 0
                    ? "Enter Quantity"
                    : "Stock is empty",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.production_quantity_limits),
              ),
            ),
            const SizedBox(height: 15),

            // 🔹 Dropdown for Reason (Mandatory)
            DropdownButtonFormField<String>(
              value: _selectedReason,
              items: ["Expired Stocks", "Personal Use", "Others"].map((reason) {
                return DropdownMenuItem(
                  value: reason,
                  child: Text(reason),
                );
              }).toList(),
              onChanged: (newValue) {
                setState(() {
                  _selectedReason = newValue;
                });
              },
              decoration: InputDecoration(
                labelText: "Reason for Reduction",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.warning_amber_rounded),
              ),
            ),
            const SizedBox(height: 20),

            // 🔹 Buttons (Aligned Right)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // ❌ Cancel Button (Black)
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 10),
                    textStyle: const TextStyle(fontSize: 16),
                  ),
                  child: const Text("Cancel"),
                ),

                const SizedBox(width: 10), // Spacing between buttons

                // ✅ Reduce Button (Red)
                ElevatedButton(
                  onPressed: widget.currentStock > 0 // 🔹 Disable if stock is 0
                      ? () {
                          if (_stockController.text.isEmpty ||
                              int.tryParse(_stockController.text) == null) {
                            _showToast("Please enter a valid stock quantity",
                                isError: true);
                            return;
                          }

                          int stockValue = int.parse(_stockController.text);

                          if (stockValue > widget.currentStock) {
                            _showToast(
                                "Cannot reduce more than available stock!",
                                isError: true);
                            return;
                          }

                          if (_selectedReason == null) {
                            _showToast("Please select a reason for reduction",
                                isError: true);
                            return;
                          }

                          widget.onSave(stockValue, _selectedReason!);
                          _showToast("Stock successfully reduced");

                          Navigator.pop(context);
                        }
                      : null, // Disable button if stock is 0
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Reduce",
                    style: TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
