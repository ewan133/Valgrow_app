import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/button.dart';
import 'package:valgrow_ui/components/general_components/logo.dart';
import 'package:valgrow_ui/components/general_components/text.dart';
import 'package:valgrow_ui/components/general_components/textfield_label.dart';
import 'package:valgrow_ui/services/auth/auth_service.dart';
import 'package:valgrow_ui/services/database/database_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});
  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage> {
  final _auth = AuthService();
  final _db = DatabaseService();
  // controllers for input
  final _nameController = TextEditingController();
  final _numberController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _emailController.dispose();
    _passwordController.dispose();
  }

  // navigate to login
  void goLogin() {
    Navigator.pushNamed(context, '/login');
  }

  _signup() async {
    // Trim all input values
    String name = _nameController.text.trim();
    String number = _numberController.text.trim();
    String email = _emailController.text.trim();
    String password = _passwordController.text.trim();
    String confirmPassword = _confirmPasswordController.text.trim();
    String role = 'Store Owner';
    String storename = name + "'s Store";

    // Check if any field is empty
    if (name.isEmpty ||
        number.isEmpty ||
        email.isEmpty ||
        role.isEmpty ||
        storename.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please fill in all fields"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Validate phone number format
    if (!RegExp(r'^09\d{9}$').hasMatch(number)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text("Invalid phone number. Must be 11 digits starting with 09"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Check password match
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Passwords do not match!"),
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    try {
      // Create user with email and password
      User? user = await _auth.createUserWithEmailAndPassword(email, password);
      // If the user is null, an error occurred and has been handled
      if (user == null) return;

      // Create appropriate profile based on role
      if (role == "Store Owner") {
        await _db.createStoreOwnerProfile(email, name, number);
      }

      // Navigate back on success
      Navigator.pop(context);
      
      log("User created successfully");
    } on FirebaseAuthException catch (e) {
      // Use the exceptionHandler to show the error and remain on the signup page
      _auth.exceptionHandler(e.code, context);
    } catch (e) {
      // Handle any other errors during the process
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error during signup: ${e.toString()}"),
          duration: const Duration(seconds: 3),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: MyText(
            text: "Sign Up",
            fontSize: 26,
            color: Colors.black,
            fontWeight: FontWeight.w600),
        centerTitle: true,
        actions: [
          TextButton(
              onPressed: goLogin,
              child: MyText(
                  text: "Login",
                  fontSize: 16,
                  color: Color(0xFF5DB075),
                  fontWeight: FontWeight.normal))
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 25),
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              //LOGO
              Padding(
                padding: const EdgeInsets.only(top: 10),
                child: MyLogo(logoSize: 150),
              ),
              //VALGROW NAME
              MyText(
                text: "Valgrow",
                fontSize: 26,
                color: Colors.black,
                fontWeight: FontWeight.w500,
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: MyTextfieldLabeled(
                    color: Colors.black,
                    controller: _nameController,
                    label: "Name:",
                    hint: ""),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: MyTextfieldLabeled(
                    color: Colors.black,
                    controller: _emailController,
                    label: "Email:",
                    hint: ""),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: MyTextfieldLabeled(
                    color: Colors.black,
                    controller: _numberController,
                    label: "Phone Number:",
                    hint: ""),
              ),

              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: MyTextfieldLabeled(
                    color: Colors.black,
                    controller: _passwordController,
                    label: "Password:",
                    hint: ""),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 15),
                child: MyTextfieldLabeled(
                    color: Colors.black,
                    controller: _confirmPasswordController,
                    label: "Confirm Password:",
                    hint: ""),
              ),

              Padding(
                padding: const EdgeInsets.only(bottom: 20.0),
                child: MyButton(
                  onTap: _signup,
                  text: "Sign Up",
                  color: Color(0xFF14AE5C),
                  borderRadius: 100,
                  width: double.infinity,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
