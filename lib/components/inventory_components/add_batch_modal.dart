import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AddBatchModal extends StatefulWidget {

  final Function (double, int, DateTime)  onAddBatch;

  const AddBatchModal({super.key, required this.onAddBatch});

  @override
  State<AddBatchModal> createState() => _AddBatchModalState();
}

class _AddBatchModalState extends State<AddBatchModal> {
  final TextEditingController batchNameController = TextEditingController();
  final TextEditingController quantityController = TextEditingController();
  DateTime? selectedDate;

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Add Batch",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),

            // ✅ Batch Name Input
            TextField(
              controller: batchNameController,
              decoration: const InputDecoration(
                labelText: "Purchase Price",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Quantity Input
            TextField(
              controller: quantityController,
              keyboardType: TextInputType.number,
              decoration:  InputDecoration(
                labelText: "Quantity",
                border: OutlineInputBorder(borderSide: BorderSide(color: Colors.grey.shade400)),
                
              ),
            ),
            const SizedBox(height: 10),

            // ✅ Expiration Date Picker
            GestureDetector(
              onTap: () async {
                DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime(2100),
                );
                if (pickedDate != null) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      selectedDate == null
                          ? "Select Expiration Date"
                          : DateFormat('yyyy-MM-dd').format(selectedDate!),
                      style: TextStyle(
                        fontSize: 16,
                        color: selectedDate == null ? Colors.grey : Colors.black,
                      ),
                    ),
                    const Icon(Icons.calendar_today, size: 20),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // ✅ Buttons (Cancel & Add)
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Cancel"),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (batchNameController.text.isNotEmpty &&
                        quantityController.text.isNotEmpty &&
                        selectedDate != null) {
                      widget.onAddBatch(
                        double.parse(batchNameController.text),
                        int.parse(quantityController.text),
                        selectedDate!,
                      );
                      Navigator.pop(context);
                    }
                  },
                  child: const Text("Add"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
