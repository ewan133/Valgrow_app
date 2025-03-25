import 'dart:convert';
import 'package:googleapis_auth/auth_io.dart';
import 'package:http/http.dart' as http;
import 'package:googleapis_auth/googleapis_auth.dart';
import 'package:flutter/services.dart';

class FirebaseAuthService {
  /// ✅ **Load Firebase Service Account Credentials**
  static Future<ServiceAccountCredentials?> _loadServiceAccount() async {
    try {
      // 🔹 Load service account JSON file from assets
      final String jsonString = await rootBundle.loadString(
          "assets/valgrow-new-firebase-adminsdk-fbsvc-676de15d19.json"); // Ensure this file is in assets

      final Map<String, dynamic> json = jsonDecode(jsonString);
      return ServiceAccountCredentials.fromJson(json);
    } catch (e) {
      print("❌ Error loading service account: $e");
      return null;
    }
  }

  /// ✅ **Get OAuth 2.0 Access Token for Firebase**
  static Future<String?> getAccessToken() async {
    try {
      // Load credentials
      final credentials = await _loadServiceAccount();
      if (credentials == null) return null;

      // Get OAuth token
      final client = await clientViaServiceAccount(
        credentials,
        ["https://www.googleapis.com/auth/firebase.messaging"],
      );

      return client.credentials.accessToken.data;
    } catch (e) {
      print("❌ Error getting OAuth token: $e");
      return null;
    }
  }
}
