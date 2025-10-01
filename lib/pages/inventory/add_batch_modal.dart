import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AddBatchModal extends StatefulWidget {
  final Function(double, int, DateTime?) onAddBatch;

  const AddBatchModal({super.key, required this.onAddBatch});

  @override
  State<AddBatchModal> createState() => _AddBatchModalState();
}

class _AddBatchModalState extends State<AddBatchModal> {
  final TextEditingController _purchasePriceController =
      TextEditingController();
  final TextEditingController _quantityController = TextEditingController();
  DateTime? _selectedDate;

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
              "Add Stocks",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 15),

            // 🔹 Purchase Price Input
            TextField(
              controller: _purchasePriceController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Purchase Price",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: Padding(
                  padding: const EdgeInsets.all(
                      14), // ✅ Adjust padding for alignment
                  child: Text(
                    "₱",
                    style: TextStyle(
                      fontSize: 20, // ✅ Adjust size for better visibility
                      fontWeight: FontWeight.bold,
                      color: Colors.black, // ✅ Optional: Customize the color
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 15),

            // 🔹 Quantity Input
            TextField(
              controller: _quantityController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                prefixIcon: const Icon(Icons.production_quantity_limits),
              ),
            ),
            const SizedBox(height: 15),

            // 🔹 Expiration Date Picker (Optional)
            // 🔹 Expiration Date Picker (Optional)
            // GestureDetector(
            //   onTap: () async {
            //     DateTime? pickedDate = await showDatePicker(
            //       context: context,
            //       initialDate: DateTime.now(),
            //       firstDate: DateTime.now(),
            //       lastDate: DateTime(2100),
            //     );
            //     if (pickedDate != null) {
            //       setState(() {
            //         _selectedDate = pickedDate;
            //       });
            //     }
            //   },
            //   child: Container(
            //     padding:
            //         const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
            //     decoration: BoxDecoration(
            //       color: Colors.grey.shade100,
            //       border: Border.all(
            //           color: Colors.grey.shade400, width: 1.5), // ✅ Grey Border
            //       borderRadius: BorderRadius.circular(12),
            //     ),
            //     child: Row(
            //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //       children: [
            //         Text(
            //           _selectedDate == null
            //               ? "No Expiration Date (Optional)" // ✅ Display when null
            //               : DateFormat('yyyy-MM-dd').format(_selectedDate!),
            //           style: TextStyle(
            //             fontSize: 16,
            //             color:
            //                 _selectedDate == null ? Colors.grey : Colors.black,
            //           ),
            //         ),
            //         const Icon(Icons.calendar_today,
            //             size: 20, color: Colors.grey),
            //       ],
            //     ),
            //   ),
            // ),

           // const SizedBox(height: 20),

            // 🔹 Buttons (Cancel & Add) aligned to right
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

                // ✅ Add Button (Green)
                ElevatedButton(
                  onPressed: () {
                    if (_purchasePriceController.text.isEmpty ||
                        _quantityController.text.isEmpty ||
                        double.tryParse(_purchasePriceController.text) ==
                            null ||
                        int.tryParse(_quantityController.text) == null) {
                      Fluttertoast.showToast(
                        msg: "Please enter valid values",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.BOTTOM,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                        fontSize: 16.0,
                      );
                      return;
                    }

                    widget.onAddBatch(
                      double.parse(_purchasePriceController.text),
                      int.parse(_quantityController.text),
                      _selectedDate, // ✅ Now allows null
                    );
                    Navigator.pop(context);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    "Add",
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
