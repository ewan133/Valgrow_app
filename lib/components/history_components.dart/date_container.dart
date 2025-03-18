import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyDateContainer extends StatelessWidget {
  final DateTime date;

  const MyDateContainer({super.key, required this.date});

  @override
  Widget build(BuildContext context) {
    String formattedDate = DateFormat('MMMM d, yyyy').format(date);

    return Container(
      height: 56,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      color: Colors.transparent, // Ensuring a distinct background
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: MyText(
          text: formattedDate, // ✅ Displays dynamic date
          fontSize: 16,
          color: Colors.black,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
