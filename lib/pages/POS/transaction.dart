import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tutorial_coach_mark/tutorial_coach_mark.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/pages/POS/paid_transaction.dart';
import 'package:valgrow_ui/pages/POS/unpaid_transaction.dart';
import 'package:valgrow_ui/components/global_keys.dart';

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
      backgroundColor: const Color(0xFFF6F6F6),
      appBar: MyAppbar(title: "Transaction"),
      body: Column(
        children: [
          // Toggle Button
          Container(
            margin: const EdgeInsets.all(20),
            padding: const EdgeInsets.all(4),
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
                // Paid Button (50%)
                Expanded(
                  child: TextButton(
                    key: paidTabKey,
                    onPressed: () {
                      setState(() {
                        _isPaidTransaction = true;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: _isPaidTransaction
                          ? const Color(0xFF14AE5C)
                          : Colors.transparent,
                      foregroundColor:
                          _isPaidTransaction ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      "Paid",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),

                const SizedBox(width: 4),

                // Unpaid Button (50%)
                Expanded(
                  child: TextButton(
                    key: unpaidTabKey,
                    onPressed: () {
                      setState(() {
                        _isPaidTransaction = false;
                      });
                    },
                    style: TextButton.styleFrom(
                      backgroundColor: !_isPaidTransaction
                          ? const Color(0xFF14AE5C)
                          : Colors.transparent,
                      foregroundColor:
                          !_isPaidTransaction ? Colors.white : Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(double.infinity, 48),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      elevation: 0,
                    ),
                    child: Text(
                      "Utang",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Transaction Page Display
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
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
