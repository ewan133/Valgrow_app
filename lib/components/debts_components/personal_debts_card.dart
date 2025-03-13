import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valgrow_ui/models/debts_model.dart';

class MyPersonalDebtsCard extends StatelessWidget {
  final DebtDetails debtDetails; // ✅ Required debt details

  const MyPersonalDebtsCard({Key? key, required this.debtDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Format the date
    String formattedDate = DateFormat.yMMMMd().format(debtDetails.createdAt);
    String dueDate = DateFormat.yMMMMd().format(debtDetails.dueDate);
    String amount = "₱${debtDetails.balance.toStringAsFixed(2)}";

    // Status Color Logic
    Color statusColor;
    switch (debtDetails.status) {
      case "paid":
        statusColor = Colors.green;
        break;
      case "partial":
        statusColor = Colors.orange;
        break;
      default:
        statusColor = Colors.red;
    }

    return Center(
      child: Container(
        width: double.infinity,
        height: 110,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.black),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.25),
              offset: const Offset(0, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Date & Status Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  formattedDate, // ✅ Use actual created date
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),
                Text(
                  debtDetails.status.toUpperCase(), // ✅ Display status
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: statusColor, // ✅ Color-coded status
                  ),
                ),
              ],
            ),

            const SizedBox(height: 5), // Spacing

            // Due Date & Amount Row
            Row(
              children: [
                // Left Column (Due Date)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Due Date:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(0, 0, 0, 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        dueDate, // ✅ Use actual due date
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Column (Amount)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Balance:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Color.fromRGBO(0, 0, 0, 0.6),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        amount, // ✅ Use actual balance amount
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
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
