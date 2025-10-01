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

    // Check if debt is overdue
    bool isOverdue = DateTime.now().isAfter(debtDetails.dueDate) && debtDetails.status != "paid";
    
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
      margin: const EdgeInsets.only(bottom: 0),
      decoration: BoxDecoration(
        color: isPaid ? Colors.grey[300] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isPaid ? Colors.grey[600]! : Colors.grey[500]!, 
          width: 1.5,
        ),
        boxShadow: isPaid
            ? []
            : [
                BoxShadow(
                  color: Colors.black.withOpacity(0.08),
                  offset: const Offset(0, 2),
                  blurRadius: 8,
                  spreadRadius: 0,
                ),
              ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Section - Date and Status
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Created",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: isPaid ? Colors.grey[600] : Colors.grey[600],
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        formattedDate,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? Colors.grey[700] : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: isPaid ? Colors.grey[400] : statusColor.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: isPaid ? Colors.grey[600]! : statusColor.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    debtDetails.status.toUpperCase(),
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: isPaid ? Colors.grey[700] : statusColor,
                      letterSpacing: 0.8,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // Main Content Section
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Due Date Section
                Expanded(
                  flex: 3,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.schedule_outlined,
                            size: 16,
                            color: isPaid ? Colors.grey[600] : Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Due Date",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isPaid ? Colors.grey[600] : Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        dueDate,
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: isPaid ? Colors.grey[700] : Colors.black87,
                          height: 1.2,
                        ),
                      ),
                      // Overdue indicator
                      if (isOverdue)
                        Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(color: Colors.red.withOpacity(0.3), width: 1),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.warning_amber_rounded,
                                  size: 12,
                                  color: Colors.red[700],
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  "OVERDUE",
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.red[700],
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),

                const SizedBox(width: 20),

                // Amount Section
                Expanded(
                  flex: 2,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Icon(
                            Icons.account_balance_wallet_outlined,
                            size: 16,
                            color: isPaid ? Colors.grey[600] : Colors.grey[700],
                          ),
                          const SizedBox(width: 6),
                          Text(
                            "Balance",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: isPaid ? Colors.grey[600] : Colors.grey[600],
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Text(
                        amount,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: isPaid ? Colors.grey[700] : Colors.black87,
                          height: 1.1,
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
