import 'package:flutter/material.dart';

class MyDropdown extends StatelessWidget {
  final String text;
  final Color color;
  final List<String> choices;
  final String? selectedValue;
  final Function(String?) onChanged;
  final bool showAddNew;
  final bool showRedAsterisk; // Show red asterisk for required fields

  const MyDropdown({
    super.key,
    required this.text,
    required this.color,
    required this.choices,
    required this.selectedValue,
    required this.onChanged,
    this.showAddNew = true,
    this.showRedAsterisk = false, // Default to false
  });

  Future<String?> _showAddNewDialog(BuildContext context) async {
    TextEditingController controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add New'),
        content: TextField(
          controller: controller,
          maxLength: 20,
          decoration: const InputDecoration(
            hintText: 'Enter new value (max 20 chars)',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                Navigator.pop(context, controller.text);
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        showRedAsterisk
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: text,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                    ),
                    const TextSpan(
                      text: ' *',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
              )
            : Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
        DropdownButtonFormField<String>(
          value: choices.contains(selectedValue) ? selectedValue : null,
          decoration: InputDecoration(
            filled: true,
            fillColor: const Color(0xFFF6F6F6),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: color),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Colors.black, width: 2),
            ),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
          hint: const Text(
            'Select',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFFBDBDBD),
            ),
          ),
          items: [
            if (showAddNew)
              const DropdownMenuItem(
                value: '_add_new_',
                child: Text('Add New...'),
              ),
            ...choices.map((choice) => DropdownMenuItem(
                  value: choice,
                  child: Text(choice),
                )),
          ],
          onChanged: (value) {
            if (value == '_add_new_') {
              _showAddNewDialog(context).then((newValue) {
                if (newValue != null && newValue.isNotEmpty) {
                  onChanged(newValue);
                }
              });
            } else {
              onChanged(value);
            }
          },
        ),
      ],
    );
  }
}
