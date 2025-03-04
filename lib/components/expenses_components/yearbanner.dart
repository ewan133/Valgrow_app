import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyYearBanner extends StatelessWidget {
  const MyYearBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        height: 57,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Color.fromRGBO(20, 174, 92, 0.3),
        ),
        child: Center(
          child: MyText(
              text: "2025",
              fontSize: 24,
              color: Colors.black,
              fontWeight: FontWeight.w600),
        ),
      ),
    );
  }
}
