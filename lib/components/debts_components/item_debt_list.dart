import 'package:flutter/material.dart';

class MyItemDebtList extends StatelessWidget {
  const MyItemDebtList({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text("Royal Cute x5",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
        Text("₱60.00",
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      ],
    );
  }
}
