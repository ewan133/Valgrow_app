import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class MyTextfieldLabeled extends StatefulWidget {
  final String label;
  final String hint;
  final TextEditingController controller;
  final Color color;
  final bool isNumeric; // Accept numbers (int/decimal)
  final bool isObscure; // Toggle for password fields
  final bool isReadOnly;
  final bool showRedAsterisk; // Show red asterisk for required fields

  const MyTextfieldLabeled({
    super.key,
    required this.controller,
    required this.label,
    required this.hint,
    required this.color,
    this.isNumeric = false, // Default to false (text input)
    this.isObscure = false, // Default to false (not a password field)
    this.isReadOnly = false,
    this.showRedAsterisk = false, // Default to false
  });

  @override
  _MyTextfieldLabeledState createState() => _MyTextfieldLabeledState();
}

class _MyTextfieldLabeledState extends State<MyTextfieldLabeled> {
  bool _obscureText = false;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isObscure;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        widget.showRedAsterisk
            ? Text.rich(
                TextSpan(
                  children: [
                    TextSpan(
                      text: widget.label,
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
                widget.label,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.black,
                ),
              ),
        TextField(
          readOnly: widget.isReadOnly,
          controller: widget.controller,
          keyboardType: widget.isNumeric
              ? const TextInputType.numberWithOptions(decimal: true)
              : TextInputType.text,
          inputFormatters: widget.isNumeric
              ? [FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*$'))]
              : [],
          obscureText: _obscureText, // Obscure text if enabled
          decoration: InputDecoration(
            hintText: widget.hint,
            filled: true,
            fillColor: const Color(0xFFF6F6F6), // Background color
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.color),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: widget.color),
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
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
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
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
