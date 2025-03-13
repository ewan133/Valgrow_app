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
    return Container(
      width: 379,
      height: 134,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            offset: const Offset(0, 4),
            blurRadius: 4,
          )
        ],
        borderRadius: BorderRadius.circular(15),
      ),
      child: Stack(
        children: [
          // Row Layout for Image and Text
          Row(
            children: [
              // Profile Image (Use customer image if available)
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: customerDetails?.imageUrl != null
                        ? NetworkImage(customerDetails!.imageUrl)
                        : const AssetImage("assets/images/sample.jpg")
                            as ImageProvider,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10), // Spacing

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
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    // Phone Number
                    Text(
                      customerDetails?.phone ?? "No Phone",
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8), // Spacing

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
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              "₱ ${totalBalance.toStringAsFixed(2)}",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Next Due Date:",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              nearestDueDate != null
                                  ? DateFormat.yMMMd().format(nearestDueDate!)
                                  : "No Debts",
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
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

          // "View" Positioned at Top-Right
          const Positioned(
            top: -5,
            right: 0,
            child: Text(
              "View",
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF14AE5C),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
