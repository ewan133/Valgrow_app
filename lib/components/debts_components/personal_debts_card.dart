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

    bool isPaid = debtDetails.status == "paid";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isPaid ? Colors.grey[300] : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid ? Colors.grey[400]! : const Color(0xFFF6F6F6),
          width: 1,
        ),
        boxShadow: isPaid
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.06),
                  blurRadius: 16,
                  offset: const Offset(0, 2),
                  spreadRadius: 0,
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
                  formattedDate,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: isPaid ? Colors.grey[700] : Colors.black,
                    letterSpacing: -0.2,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.grey[200] : statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    debtDetails.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: isPaid ? Colors.grey[600] : statusColor,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Due Date & Amount Row
            Row(
              children: [
                // Left Column (Due Date)
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Due Date",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isPaid ? Colors.grey[600] : Colors.black.withOpacity(0.6),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        dueDate,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? Colors.grey[700] : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),

                // Right Column (Amount)
                Expanded(
                  flex: 1,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Balance",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isPaid ? Colors.grey[600] : Colors.black.withOpacity(0.6),
                          letterSpacing: 0.3,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        amount,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: isPaid ? Colors.grey[700] : Colors.black,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
    );
  }
}
