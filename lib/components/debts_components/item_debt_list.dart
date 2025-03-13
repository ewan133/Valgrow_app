import 'package:flutter/material.dart';

class MyItemDebtList extends StatelessWidget {
  final String itemName;
  final int quantity;
  final double price;

  const MyItemDebtList({
    super.key,
    required this.itemName,
    required this.quantity,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // ✅ Item Name + Quantity
          Text(
            "$itemName x$quantity",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          // ✅ Total Price
          Text(
            "₱${price.toStringAsFixed(2)}",
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
