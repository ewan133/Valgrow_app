import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyYearBanner extends StatelessWidget {
  final int year;

  const MyYearBanner({super.key, required this.year});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 10, right: 10, bottom: 10, top: 10),
      child: Container(
        height: 57,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color.fromRGBO(20, 174, 92, 0.2),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: const Color(0xFF14AE5C), width: 1),
        ),
        child: Center(
          child: MyText(
            text: year.toString(),
            fontSize: 22,
            color: Colors.black,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}
