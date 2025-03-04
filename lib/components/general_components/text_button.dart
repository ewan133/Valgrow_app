import 'package:flutter/material.dart';

class MyTextButton extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final void Function()? onPressed;
  const MyTextButton(
      {super.key,
      required this.text,
      required this.fontSize,
      required this.color,
      required this.fontWeight,
      this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Text(
        text,
        style: TextStyle(
            fontFamily: 'Inter',
            fontSize: fontSize,
            fontWeight: fontWeight,
            color: color),
      ),
    );
  }
}
