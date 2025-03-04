import 'package:flutter/material.dart';

class MyButton extends StatelessWidget {
  final void Function()? onTap;
  final String text;
  final Color color;
  final double width;
  final double borderRadius;
  const MyButton(
      {super.key,
      this.onTap,
      required this.text,
      required this.color,
      required this.width,
      required this.borderRadius});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width, // Takes full available width
      height: 51, // Fixed height
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(borderRadius), // Circular border
          ),
        ),
        child: Text(
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white, // White text color
          ),
        ),
      ),
    );
  }
}
