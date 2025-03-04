import 'package:flutter/material.dart';

class MyText extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final int? maxLines;
  final double? height;

  const MyText({
    super.key,
    required this.text,
    required this.fontSize,
    required this.color,
    required this.fontWeight,
    this.maxLines,
    this.height
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      maxLines: maxLines, // Use 'maxLines' directly
      style: TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: fontWeight,
        color: color,
        overflow: TextOverflow.ellipsis,
        height: height,
        
      ),
    );
  }
}
