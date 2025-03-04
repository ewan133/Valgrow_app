import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyDateContainer extends StatelessWidget {
  const MyDateContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
        height: 56,
        width: double.infinity,
        alignment: Alignment.centerLeft,
        child: Padding(
          padding: const EdgeInsets.only(left: 20, right: 20),
          child: MyText(
              text: "January 99, 2099",
              fontSize: 16,
              color: Colors.black,
              fontWeight: FontWeight.w600),
        ));
  }
}
