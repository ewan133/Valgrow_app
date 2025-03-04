import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyHistoryTile extends StatelessWidget {
  const MyHistoryTile({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 73,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      decoration: BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 40, right: 40),
            child: Row(
              children: [
                MyText(
                    text: "Sales",
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
                Spacer(),
                MyText(
                    text: "+900.00",
                    fontSize: 18,
                    color: Colors.black,
                    fontWeight: FontWeight.w600),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: MyText(
                text: "5:27 PM",
                fontSize: 10,
                color: const Color.fromARGB(181, 0, 0, 0),
                fontWeight: FontWeight.w600),
          )
        ],
      ),
    );
  }
}
