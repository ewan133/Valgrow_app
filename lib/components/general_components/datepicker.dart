import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class MyDatePicker extends StatefulWidget {
  final String label;
  final Function(DateTime) onDateSelected; // ✅ Added callback function

  const MyDatePicker({
    super.key,
    required this.label,
    required this.onDateSelected, // ✅ Ensure this is correctly passed
  });

  @override
  State<MyDatePicker> createState() => _MyDatePickerState();
}

class _MyDatePickerState extends State<MyDatePicker> {
  DateTime? selectedDate;
  final DateFormat formatter = DateFormat('MM/dd/yyyy');

  Future<void> _selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      
      widget.onDateSelected(pickedDate); // ✅ Call the callback function
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Padding(
          padding: const EdgeInsets.only(left: 10.0),
          child: Text(
            widget.label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
        ),

        // Date Picker Container
        GestureDetector(
          onTap: () => _selectDate(context),
          child: Container(
            width: double.infinity,
            height: 55,
            decoration: BoxDecoration(
              color: const Color(0xFFF6F6F6), // Light gray background
              border: Border.all(color: Colors.black, width: 1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Date Text
                Padding(
                  padding: const EdgeInsets.only(left: 12),
                  child: Text(
                    selectedDate == null
                        ? "MM/DD/YYYY"
                        : formatter.format(selectedDate!),
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                      color: selectedDate == null
                          ? const Color(0xFFBDBDBD) // Placeholder gray
                          : Colors.black,
                    ),
                  ),
                ),
                
                // Calendar Icon
                const Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: Icon(Icons.calendar_today, color: Color(0xFFAAAAAA), size: 16),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
