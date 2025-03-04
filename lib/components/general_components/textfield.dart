import 'package:flutter/material.dart';

class MyTextfieldHintLabel extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  const MyTextfieldHintLabel({super.key, required this.controller, required this.hint});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        filled: true,
        fillColor: Color(0xFFF6F6F6), // Background color (Gray/01)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Border radius
          borderSide: BorderSide(color: Colors.black), // Border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.black), // Border when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide:
              BorderSide(color: Colors.black, width: 2), // Border when focused
        ),
        hintStyle: TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFBDBDBD), // Gray/03 color for hint text
        ),
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 15),
      ),
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black, // Text color
      ),
    );
  }
}
