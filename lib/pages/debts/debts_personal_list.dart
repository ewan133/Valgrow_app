import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/debts_components/debt_payment.dart';
import 'package:valgrow_ui/components/debts_components/personal_debts_card.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';

class DebtsPersonalList extends StatefulWidget {
  const DebtsPersonalList({super.key});

  @override
  State<DebtsPersonalList> createState() => _DebtsPersonalListState();
}

class _DebtsPersonalListState extends State<DebtsPersonalList> {
  void showDebtPaymentDialog(BuildContext context) {
  showDialog(
    context: context,
    barrierDismissible: false, // Prevent closing by tapping outside
    builder: (context) => const DebtPaymentModal(),
  );
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(title: "Debts"),
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
        child: ListView(
          children: [
            // Scrollable Top Container
            Padding(
              padding: const EdgeInsets.only(bottom: 15.0),
              child: Container(
                width: double.infinity,
                height: 113,
                child: Row(
                  children: [
                    // Image
                    Container(
                      width: 113,
                      height: 113,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.black),
                        image: const DecorationImage(
                          image: AssetImage("assets/images/sample.jpg"), // Replace with actual image
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(width: 12), // Space between image and text

                    // Text Content
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Product Name
                          Text(
                            "Malupiton",
                            style: TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                            ),
                          ),

                          // Phone Number
                          const Text(
                            "+63 9264 234 4562",
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                          ),

                          const SizedBox(height: 5),

                          // Divider Line
                          const Divider(
                            color: Colors.black,
                            thickness: 1,
                          ),

                          // Price and Balance
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Total Balance
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: const [
                                  Text(
                                    "Total Balance:",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),

                              // Price
                              const Text(
                                "₱45.00",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ListView Items (Debts)
            ListView.builder(
              shrinkWrap: true, // ✅ Ensures it takes only required space
              physics: NeverScrollableScrollPhysics(), // ✅ Prevents nested scrolling issues
              itemCount: 5,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 13.0),
                  child: GestureDetector(
                    onTap: () => showDebtPaymentDialog(context), // ✅ Fix: Pass context properly
                    child: MyPersonalDebtsCard(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
