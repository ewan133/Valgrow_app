import 'dart:developer';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:valgrow_ui/services/auth/wrapper.dart';
import 'package:valgrow_ui/services/database/management_database.dart';

class AuthService {
  final _auth = FirebaseAuth.instance;
  final _db = ManagementDatabase();

  // log the error in debug console
  exceptionHandler(String code, BuildContext context) {
    String message;
    switch (code) {
      case "invalid-credentials":
        message = "Invalid credentials.";
        break;
      case "weak-password":
        message = "Password must be at least 8 characters.";
        break;
      case "email-already-in-use":
        message = "Email already used.";
        break;
      default:
        message = "Something went wrong.";
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: Duration(seconds: 3)),
    );
  }

  // send or resend the email verification
  Future<void> sendEmailVerificationLink() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } catch (e) {
      print(e.toString());
    }
  }

  // login with email and password
  Future<void> loginUserWithEmailAndPassword(
      String email, String password, BuildContext context) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = cred.user;

      if (user != null) {
        await user.reload(); // 🔄 Refresh user info
        user = _auth.currentUser;
      }

      log("User Logged In: ${user?.email}");

      // 🔹 Navigate to WrapperPage to refresh authentication state
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const WrapperPage()),
      );
    } on FirebaseAuthException catch (e) {
      log("Login Failed: ${e.message}");
      throw e;
    }
  }

  // logout the user
  Future<void> signout() async {
    try {
      await _auth.signOut();
      log("User logged out");
    } catch (e) {
      log("Something went wrong");
    }
  }

  // create account with email and password
  Future<User?> createUserWithEmailAndPassword(
      String email, String password) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
          email: email, password: password);
      return cred.user;
    } on FirebaseAuthException catch (e) {
      // Instead of handling the error here, you could rethrow it
      // and let _signup() decide what to do.
      throw e;
    }
  }

  // send email for password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(
        email: email,
      );
    } catch (e) {}
  }

  // get user uid
  String getUserUid() {
    return _auth.currentUser!.uid;
  }

  Future<void> createUserAsAdmin({
    required String email,
    required String password,
    required String name,
    required String phone,
    required String storeCode,
    required BuildContext context,
  }) async {
    try {
      final callable =
          FirebaseFunctions.instance.httpsCallable('createUserAsAdmin');
      final result = await callable.call({
        'email': email,
        'password': password,
      });

      final data = result.data;
      String newUserId = data['uid'];

      _db.createEmployeeProfile(email, name, phone, storeCode, newUserId);
      

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("✅ Created user: ${data['email']}")),
      );
    } on FirebaseFunctionsException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("❌ Failed to create user: ${e.message}")),
      );
    }
  }
}
