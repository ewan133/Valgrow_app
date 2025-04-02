import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/models/expenses_details.dart';
import 'package:intl/intl.dart';

class MyExpensesInfoList extends StatelessWidget {
  final ExpenseModel expense;

  const MyExpensesInfoList({super.key, required this.expense});

  @override
  Widget build(BuildContext context) {
    final formattedDate = DateFormat("MMMM dd, yyyy").format(expense.date);

    return Container(
      height: 130,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        color: Colors.white,
        border: Border.all(
          color: Colors.black,
          width: 1,
          style: BorderStyle.solid,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            MyText(
              text: formattedDate,
              fontSize: 20,
              color: Colors.black,
              fontWeight: FontWeight.w600,
            ),
            const SizedBox(height: 15),

            // Details row
            Row(
              children: [
                // Category
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: "Type",
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                      MyText(
                        text: expense.category,
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ],
                  ),
                ),

                // Amount
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      MyText(
                        text: "Amount",
                        fontSize: 16,
                        color: Colors.black.withOpacity(0.6),
                        fontWeight: FontWeight.bold,
                      ),
                      MyText(
                        text: "₱${expense.amount.toStringAsFixed(2)}",
                        fontSize: 16,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
