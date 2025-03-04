import 'package:flutter/material.dart';

class MyLogo extends StatelessWidget {
  final double logoSize; 
  const MyLogo({super.key, required this.logoSize});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: logoSize,
      width: logoSize,
      child: ClipRRect(
       // borderRadius: BorderRadius.circular(34), // Rounded corners
        child: Image.asset(
          'lib/images/valgrow_logo.png',
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}
