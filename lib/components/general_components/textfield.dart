import 'package:flutter/material.dart';

class MyTextfieldHintLabel extends StatefulWidget {
  final TextEditingController controller;
  final String hint;
  final bool isObscure; // Optional password mode

  const MyTextfieldHintLabel({
    super.key,
    required this.controller,
    required this.hint,
    this.isObscure = false, // Default to false (not a password field)
  });

  @override
  _MyTextfieldHintLabelState createState() => _MyTextfieldHintLabelState();
}

class _MyTextfieldHintLabelState extends State<MyTextfieldHintLabel> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure; // Initialize obscure text state
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      obscureText: _obscureText, // Toggle password visibility
      decoration: InputDecoration(
        labelText: widget.hint,
        filled: true,
        fillColor: const Color(0xFFF6F6F6), // Background color (Gray/01)
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Border radius
          borderSide: const BorderSide(color: Colors.black), // Border color
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black), // Border when not focused
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.black, width: 2), // Border when focused
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 16,
          fontWeight: FontWeight.w500,
          color: Color(0xFFBDBDBD), // Gray/03 color for hint text
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        suffixIcon: widget.isObscure
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility : Icons.visibility_off,
                  color: Colors.black54,
                ),
                onPressed: () {
                  setState(() {
                    _obscureText = !_obscureText;
                  });
                },
              )
            : null, // Show/hide button only if `isObscure` is true
      ),
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: Colors.black, // Text color
      ),
    );
  }
}
