import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:valgrow_ui/pages/POS/POS.dart';

class SuccessPage extends StatefulWidget {
  const SuccessPage({super.key});

  @override
  State<SuccessPage> createState() => _SuccessPageState();
}

class _SuccessPageState extends State<SuccessPage>
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
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Spacer(),

          // ✅ Animated Checkmark using Lottie
          Lottie.asset(
            'lib/images/Animation - 1741778259924.json', // ✅ Path to your JSON animation
            width: 300,
            height: 300,
            fit: BoxFit.cover,
            controller: _animationController, // ✅ Assign AnimationController
            repeat: false, // ✅ Don't loop
            onLoaded: (composition) {
              _animationController
                ..duration = composition.duration * 1.5 // ✅ Adjust speed
                ..forward(); // ✅ Start animation automatically
            },
          ),

          const SizedBox(height: 20),

          // ✅ "Saved Successfully" Text
          const Text(
            "Saved Successfully!",
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
            "Your transaction has been recorded.",
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w400,
              color: Colors.grey,
            ),
            textAlign: TextAlign.center,
          ),

          const Spacer(),

          // ✅ "Continue" Button with smooth animation
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: ElevatedButton(
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const POSPage()),
                  (route) =>
                      route.isFirst, // ✅ Remove all pages except the first one
                );
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
                  "Continue",
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

          const SizedBox(height: 40), // Extra padding for spacing
        ],
      ),
    );
  }
}
