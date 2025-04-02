import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyMonthTile extends StatelessWidget {
  final String title; // e.g. "January 2025"
  final double total; // e.g. 4000.00
  final VoidCallback? onTap;

  const MyMonthTile({
    super.key,
    required this.title,
    required this.total,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          const EdgeInsets.only(left: 15.0, right: 15, top: 0, bottom: 15),
      child: InkWell(
        borderRadius: BorderRadius.circular(15),
        onTap: onTap,
        child: Container(
          height: 60,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(15),
            border:
                Border.all(color: Colors.black, style: BorderStyle.solid, width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 2),
                blurRadius: 5,
                spreadRadius: 1,
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                offset: const Offset(0, 5),
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
                  text: title,
                  fontSize: 14,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                MyText(
                  text: "-₱${total.toStringAsFixed(2)}",
                  fontSize: 14,
                  color: Colors.red[700]!,
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
