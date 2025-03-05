import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/pages/POS/paid_transaction.dart';
import 'package:valgrow_ui/pages/POS/unpaid_transaction.dart';

class TransactionPage extends StatefulWidget {
  const TransactionPage({super.key});

  @override
  State<TransactionPage> createState() => _TransactionPageState();
}

class _TransactionPageState extends State<TransactionPage> {
  bool _isPaidTransaction = true; // ✅ Set PaidTransaction as default

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Transaction"),
      body: Column(
        children: [
          // Toggle Button
          Padding(
            padding: const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
            child: Container(
              width: double.infinity, // ✅ Full-width container
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                border:
                    Border.all(color: Colors.black, width: 1), // ✅ Black border
              ),
              child: Row(
                children: [
                  // Paid Button (50%)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isPaidTransaction = true;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: _isPaidTransaction
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        foregroundColor:
                            _isPaidTransaction ? Colors.white : Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(8),
                            bottomLeft: Radius.circular(8),
                          ),
                        ),
                        minimumSize:
                            const Size(double.infinity, 55), // ✅ Reduced height
                        padding: const EdgeInsets.symmetric(
                            vertical: 8), // ✅ Less padding
                      ),
                      child: const Text(
                        "Paid",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w600), // ✅ Slightly smaller text
                      ),
                    ),
                  ),

                  // Unpaid Button (50%)
                  Expanded(
                    child: TextButton(
                      onPressed: () {
                        setState(() {
                          _isPaidTransaction = false;
                        });
                      },
                      style: TextButton.styleFrom(
                        backgroundColor: !_isPaidTransaction
                            ? Theme.of(context).colorScheme.primary
                            : Colors.white,
                        foregroundColor:
                            !_isPaidTransaction ? Colors.white : Colors.black,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.only(
                            topRight: Radius.circular(8),
                            bottomRight: Radius.circular(8),
                          ),
                        ),
                        minimumSize:
                            const Size(double.infinity, 55), // ✅ Reduced height
                        padding: const EdgeInsets.symmetric(
                            vertical: 8), // ✅ Less padding
                      ),
                      child: const Text(
                        "Unpaid",
                        style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.w600), // ✅ Slightly smaller text
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 10),

          // Transaction Page Display
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
              child: _isPaidTransaction
                  ? const PaidTransaction()
                  : const UnpaidTransaction(),
            ),
          ),
        ],
      ),
    );
  }
}
