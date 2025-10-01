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
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 16,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Profile Image (Use customer image if available)
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFFF6F6F6),
              border: Border.all(color: const Color(0xFFF6F6F6), width: 2),
            ),
            child: customerDetails?.imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      customerDetails!.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.person,
                          color: Colors.black.withOpacity(0.5),
                          size: 24,
                        );
                      },
                    ),
                  )
                : Icon(
                    Icons.person,
                    color: Colors.black.withOpacity(0.5),
                    size: 24,
                  ),
          ),
          const SizedBox(width: 16), // Spacing

          // Text Section
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Customer Name
                Text(
                  customerDetails?.name ?? "Unknown",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.black,
                    letterSpacing: -0.2,
                  ),
                ),
                const SizedBox(height: 2),

                // Phone Number
                Text(
                  customerDetails?.phone ?? "No Phone",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: Colors.black.withOpacity(0.6),
                    letterSpacing: 0.3,
                  ),
                ),

                const SizedBox(height: 12), // Spacing

                // Balance & Due Date
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "Total Balance",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w500,
                              color: Colors.black.withOpacity(0.6),
                              letterSpacing: 0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            "₱${totalBalance.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              color: const Color(0xFF14AE5C),
                              letterSpacing: -0.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: dueDateBackground,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        dueDateText,
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: dueDateColor,
                          letterSpacing: 0.2,
                        ),
                      ),
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
