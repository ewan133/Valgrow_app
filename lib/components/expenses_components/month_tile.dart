import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyMonthTile extends StatelessWidget {
  const MyMonthTile({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 15.0, right: 15, top: 0 , bottom: 15),
      child: Container(
        height: 60,
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
              color: Colors.black, style: BorderStyle.solid, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: Offset(0, 2),
              blurRadius: 5,
              spreadRadius: 1,
            ),
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              offset: Offset(0, 5),
              blurRadius: 10,
              spreadRadius: -3,
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              MyText(
                  text: "January",
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
              Spacer(),
              MyText(
                  text: "-4000.00",
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600),
            ],
          ),
        ),
      ),
    );
  }
}
