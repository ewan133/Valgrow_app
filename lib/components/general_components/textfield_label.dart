import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfieldLabeled extends StatelessWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Color color;
  final bool isNumeric; // Accept numbers (int/decimal)

  const MyTextfieldLabeled({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.color,
    this.isNumeric = false, // Default to false (text input)
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
        TextField(
          controller: controller,
          keyboardType: isNumeric 
              ? const TextInputType.numberWithOptions(decimal: true) // Enable decimal keyboard
              : TextInputType.text, 
          inputFormatters: isNumeric 
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))] // Allow numbers + decimal
              : [], 
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: const Color(0xFFF6F6F6), // Background color
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
            hintStyle: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFFBDBDBD), // Hint text color
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
          ),
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
