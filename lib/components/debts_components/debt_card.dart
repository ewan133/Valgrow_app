import 'package:flutter/material.dart';

class MyDebtsCard extends StatelessWidget {
  const MyDebtsCard({super.key});

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
              // Profile Image
              Container(
                width: 100,
                height: 100,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  image: DecorationImage(
                    image: AssetImage(
                        "assets/images/sample.jpg"), // Change to actual image
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

                    // Product Name
                    const Text(
                      "Sinandomeng Rice",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black,
                      ),
                    ),

                    // Phone Number
                    const Text(
                      "+63 9264 234 4562",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                        color: Colors.black,
                      ),
                    ),

                    const SizedBox(height: 8), // Spacing

                    // Price & Balance Row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: const [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align text to the left
                          children: const [
                            Text(
                              "Balance:",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 2), // Add spacing between texts
                            Text(
                              "₱ 234.00",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment
                              .start, // Align text to the left
                          children: const [
                            Text(
                              "Due Date:",
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Colors.black,
                              ),
                            ),
                            SizedBox(height: 2), // Add spacing between texts
                            Text(
                              "Feburary 01, 2025",
                              style: TextStyle(
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
          Positioned(
            top: -5, // Adjust this value to move it higher
            right: 0, // Adjust this value to move it more right
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
