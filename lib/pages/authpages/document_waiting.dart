import 'package:flutter/material.dart';
import 'package:valgrow_ui/services/auth/auth_service.dart';

class DocumentVerificationPage extends StatelessWidget {
  const DocumentVerificationPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Icon(Icons.verified_user,
                  size: 100, color: Color(0xFF14AE5C)),
              const SizedBox(height: 20),
              const Text(
                "Your Document is Under Review",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 10),
              const Text(
                "We are currently verifying your submitted document. This process may take some time. Please check back later.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  final _auth = AuthService();
                  _auth.signout(context);
                  Navigator.pushNamed(context, '/login'); // Navigate back
                },
                icon: const Icon(
                  Icons.home,
                  color: Colors.white,
                  size: 30,
                ),
                label: const Text("Back to Login"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF14AE5C),
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 60),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
