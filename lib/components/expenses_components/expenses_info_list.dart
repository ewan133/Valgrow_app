import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyExpensesInfoList extends StatelessWidget {
  const MyExpensesInfoList({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(15),
          color: Colors.white,
          border: Border.all(
              color: Colors.black, width: 1, style: BorderStyle.solid)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
                text: "January 06, 2025",
                fontSize: 20,
                color: Colors.black,
                fontWeight: FontWeight.w600),
            SizedBox(
              height: 15,
            ),
            // details row
            Row(
              children: [
                // type column
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                          text: "Type",
                          fontSize: 16,
                          color: Color.fromRGBO(0, 0, 0, 0.6),
                          fontWeight: FontWeight.bold),
                      MyText(
                          text: "Electric Bill",
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.normal),
                    ],
                  ),
                ),
                Expanded(
                  flex: 5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                          text: "Amount",
                          fontSize: 16,
                          color: Color.fromRGBO(0, 0, 0, 0.6),
                          fontWeight: FontWeight.bold),
                      MyText(
                          text: "₱2500.00",
                          fontSize: 16,
                          color: Colors.black,
                          fontWeight: FontWeight.w500),
                    ],
                  ),
                )
              ],
            )
          ],
        ),
      ),
    );
  }
}
