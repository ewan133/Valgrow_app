import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:valgrow_ui/models/customer_model.dart';

class MyDebtsCard extends StatelessWidget {
  final CustomerDetails? customerDetails;
  final double totalBalance;
  final DateTime? nearestDueDate;

  const MyDebtsCard({
    Key? key,
    required this.customerDetails,
    required this.totalBalance,
    required this.nearestDueDate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Calculate remaining days
    String dueDateText = "No Due Date";
    Color dueDateColor = Colors.black;
    Color dueDateBackground = Colors.grey.shade200;

    if (nearestDueDate != null) {
      DateTime today = DateTime.now();
      Duration difference = nearestDueDate!.difference(today);
      int daysLeft = difference.inDays;

      if (daysLeft > 0) {
        dueDateText = "$daysLeft ${daysLeft == 1 ? "day" : "days"}";
        dueDateColor = Colors.orange.shade900; // 🔶 Soon-to-be due
        dueDateBackground = Colors.orange.shade100;
      } else if (daysLeft == 0) {
        dueDateText = "Today";
        dueDateColor = Colors.blue.shade900; // 🔵 Due today
        dueDateBackground = Colors.blue.shade100;
      } else {
        dueDateText = "Overdue";
        dueDateColor = Colors.red.shade900; // 🔴 Past due
        dueDateBackground = Colors.red.shade100;
      }
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.white, Colors.grey.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: Colors.grey.shade300, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(0, 4),
            blurRadius: 6,
          )
        ],
        borderRadius: BorderRadius.circular(18),
      ),
      child: Row(
        children: [
          // Profile Image (Use customer image if available)
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade400, width: 2),
              image: DecorationImage(
                image: customerDetails?.imageUrl != null
                    ? NetworkImage(customerDetails!.imageUrl)
                    : const AssetImage("assets/images/sample.jpg")
                        as ImageProvider,
                fit: BoxFit.cover,
              ),
            ),
          ),
          const SizedBox(width: 12), // Spacing

          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 5), // Add space from top

                // Customer Name
                Text(
                  customerDetails?.name ?? "Unknown",
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                ),

                // Phone Number
                Text(
                  customerDetails?.phone ?? "No Phone",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                    color: Colors.grey.shade700,
                  ),
                ),

                const SizedBox(height: 10), // Spacing

                // Balance & Due Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Total Balance:",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          "₱ ${totalBalance.toStringAsFixed(2)}",
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.green,
                          ),
                        ),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        const Text(
                          "Next Due Date in:",
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 5),
                          decoration: BoxDecoration(
                            color: dueDateBackground,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            dueDateText,
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: dueDateColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
