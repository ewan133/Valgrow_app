import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valgrow_ui/services/auth/auth_service.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/logo.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/components/general_components/text_button.dart';
import 'package:valgrow_ui/components/general_components/textfield.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();
  final _auth = AuthService();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  // navigate to signup
  void navigateToSignup() {
    Navigator.pushNamed(context, "/signup");
  }

  _login() async {
    if (!mounted) return;

    try {
      await _auth.loginUserWithEmailAndPassword(_emailController.text.trim(),
          _passwordController.text.trim(), context);
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      String errorMessage = "Login failed. Please try again.";

      if (e.code == "user-not-found") {
        errorMessage = "No user found with this email.";
      } else if (e.code == "wrong-password") {
        errorMessage = "Incorrect password. Please try again.";
      } else if (e.code == "invalid-email") {
        errorMessage = "Invalid email format.";
      }

      // ✅ Show SnackBar using GlobalKey
      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.redAccent,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      scaffoldMessengerKey.currentState?.showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.redAccent,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double keyboardHeight =
        MediaQuery.of(context).viewInsets.bottom; // Detect keyboard height

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Main content is scrollable to prevent overflow
            Expanded(
              child: SingleChildScrollView(
                physics: ClampingScrollPhysics(), // Ensures smooth scrolling
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center, // Keep UI balanced
                    children: [
                      SizedBox(
                          height:
                              screenHeight * 0.12), // Keep space from the top
                      MyLogo(logoSize: 175),
                      MyText(
                        text: "Valgrow",
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 40),
                      MyText(
                        text: "Login",
                        fontSize: 32,
                        color: Colors.black,
                        fontWeight: FontWeight.w500,
                      ),
                      const SizedBox(height: 10),
                      MyTextfieldHintLabel(
                        controller: _emailController,
                        hint: "Email",
                      ),
                      const SizedBox(height: 10),
                      MyTextfieldHintLabel(
                        controller: _passwordController,
                        hint: "Password",
                      ),
                      const SizedBox(height: 20),
                      MyButton(
                        onTap: _login,
                        text: "Login",
                        color: Color(0xFF14AE5C),
                        borderRadius: 100,
                        width: double.infinity,
                      ),
                      const SizedBox(height: 10),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/change_password');
                        },
                        child: MyTextButton(
                          text: "Forgot your password?",
                          fontSize: 16,
                          color: Color(0xFF5DB075),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // Hide the bottom row when the keyboard is open
            if (keyboardHeight == 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      MyText(
                          text: "You don't have an account?",
                          fontSize: 18,
                          color: Color(0xFFB3B3B3),
                          fontWeight: FontWeight.w500),
                      const SizedBox(width: 5),
                      MyTextButton(
                          onPressed: navigateToSignup,
                          text: "Sign Up",
                          fontSize: 20,
                          color: Color(0xFF5DB075),
                          fontWeight: FontWeight.w500),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
