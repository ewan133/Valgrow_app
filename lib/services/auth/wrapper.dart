import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valgrow_ui/pages/authpages/email_verification.dart';
import 'package:valgrow_ui/pages/home_and_nav/home.dart';
import 'package:valgrow_ui/pages/authpages/login.dart';

class WrapperPage extends StatefulWidget {
  const WrapperPage({super.key});

  @override
  State<WrapperPage> createState() => _WrapperPageState();
}

class _WrapperPageState extends State<WrapperPage> {
  bool _isRefreshing = true;

  @override
  void initState() {
    super.initState();
    _refreshUser(); // 🔄 Refresh user on app start
  }

  Future<void> _refreshUser() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        await user.reload(); // Force Firebase to update user info
        setState(() {
          _isRefreshing = false; // UI updates after refresh
        });
      } catch (e) {
        // ❌ No user found, navigate to LoginPage
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => const LoginPage()),
          );
        }
      }
    } else {
      setState(() {
        _isRefreshing = false; // UI updates when no user is found
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isRefreshing) {
      return const Scaffold(
        body: Center(
            child:
                CircularProgressIndicator()), // Show loading until refresh is complete
      );
    }

    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return const Center(
                child: Text("An error occurred. Please try again."));
          }

          final user = FirebaseAuth.instance.currentUser;

          if (user == null) {
            return const LoginPage(); // User not logged in
          } else if (!user.emailVerified) {
            return const EmailVerificationPage(); // Show verification page
          } else {
            return const HomePage(); // Redirect to home
          }
        },
      ),
    );
  }
}
