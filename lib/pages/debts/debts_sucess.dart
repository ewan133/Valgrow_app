import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/pages/debts/debts_personal_list.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class DebtSuccessPage extends StatefulWidget {
  const DebtSuccessPage({super.key});

  @override
  State<DebtSuccessPage> createState() => _DebtSuccessPageState();
}

class _DebtSuccessPageState extends State<DebtSuccessPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context, listen: false);
    final selectedCustomer = provider.selectedCustomer;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),

          // ✅ Animated Checkmark using Lottie
          Lottie.asset(
            'lib/images/Animation - 1741778259924.json', // ✅ Path to your animation file
            width: 300,
            height: 300,
            fit: BoxFit.cover,
            controller: _animationController,
            repeat: false,
            onLoaded: (composition) {
              _animationController
                ..duration = composition.duration * 1.5
                ..forward();
            },
          ),

          const SizedBox(height: 20),

          // ✅ "Payment Successful" Text
          const Text(
            "Payment Successful!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 10),

          // ✅ Subtext Message
          const Text(
            "The debt payment has been recorded successfully.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // ✅ "Back to Debts" Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ElevatedButton(
              onPressed: () {
                if (selectedCustomer != null) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                      builder: (context) => DebtsPersonalList(
                        customerDetails: selectedCustomer, // ✅ Pass updated customer
                      ),
                    ),
                    (route) => route.isFirst,
                  );
                } else {
                  // If no customer is found, just go back to the debts page
                  Navigator.pop(context);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF14AE5C),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                elevation: 5,
              ),
              child: const SizedBox(
                width: double.infinity,
                child: Text(
                  "Back to Debts",
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(height: 40), // Extra spacing
        ],
      ),
    );
  }
}
