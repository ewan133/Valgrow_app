import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valgrow_ui/components/general_components/text.dart';

class MyHistoryTile extends StatelessWidget {
  final String transactionType; // Sales, Expense, Debts, Debt Payment, etc.
  final double amount; // Transaction amount
  final DateTime timestamp; // Transaction time

  const MyHistoryTile({
    super.key,
    required this.transactionType,
    required this.amount,
    required this.timestamp,
  });

  @override
  Widget build(BuildContext context) {
    // ✅ Determine if transaction should be negative or positive
    bool isDebt = transactionType == "Debts"; // Debts should be negative
   // bool isDebtPayment = transactionType == "Debt Payment"; // Debt Payment should be positive

    double adjustedAmount = isDebt ? -amount : amount; // Only debts are negative

    // ✅ Format amount and timestamp
    String formattedAmount = adjustedAmount >= 0
        ? "+${adjustedAmount.toStringAsFixed(2)}"
        : "-${adjustedAmount.abs().toStringAsFixed(2)}";

    String formattedTime = DateFormat.jm().format(timestamp); // Example: 5:27 PM

    return Container(
      height: 70,
      width: double.infinity,
      alignment: Alignment.centerLeft,
      decoration: const BoxDecoration(
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
                  text: transactionType, // ✅ Dynamic transaction type
                  fontSize: 18,
                  color: Colors.black,
                  fontWeight: FontWeight.w600,
                ),
                const Spacer(),
                MyText(
                  text: formattedAmount, // ✅ Dynamic amount
                  fontSize: 18,
                  color: isDebt ? Colors.red : Colors.green, // 🔴 Red for debts, 🟢 Green for debt payment/sales
                  fontWeight: FontWeight.w600,
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 40, right: 40),
            child: MyText(
              text: formattedTime, // ✅ Dynamic time
              fontSize: 10,
              color: const Color.fromARGB(181, 0, 0, 0),
              fontWeight: FontWeight.w600,
            ),
          )
        ],
      ),
    );
  }
}
