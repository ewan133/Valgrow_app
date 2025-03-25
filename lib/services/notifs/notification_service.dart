import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:valgrow_ui/services/database/database_service.dart';
import 'package:valgrow_ui/services/notifs/notification_auth.dart';
// Service to get OAuth Token

class NotificationService {
  final String _fcmEndpoint =
      "https://fcm.googleapis.com/v1/projects/YOUR_PROJECT_ID/messages:send";

  /// ✅ **Send Push Notification (For a Specific User)**
  Future<void> sendPushNotification(
      String ownerId, String title, String message) async {
    try {
      // 🔹 Check if `ownerId` is valid
      if (ownerId.isEmpty) {
        print("❌ Error: Owner ID is empty.");
        return;
      }

      print("Fetching FCM token for owner ID: $ownerId");

      // ✅ Fetch the store owner's FCM token from Firestore
      String? fcmToken = await DatabaseService().getStoreOwnerFcmToken(ownerId);

      if (fcmToken == null) {
        print("❌ No FCM token found for store owner: $ownerId.");
        return;
      }

      // ✅ Get OAuth Access Token Dynamically
      String? accessToken = await FirebaseAuthService.getAccessToken();
      if (accessToken == null) {
        print("❌ Failed to get OAuth access token.");
        return;
      }

      // ✅ Send push notification using HTTP v1 API
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({
          "message": {
            "token": fcmToken,
            "notification": {
              "title": title,
              "body": message,
            },
            "android": {
              "priority": "high",
            },
            "apns": {
              "headers": {
                "apns-priority": "10",
              },
            },
          }
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Push Notification Sent Successfully: $title");
      } else {
        print("❌ Failed to send push notification: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending push notification: $e");
    }
  }

  /// ✅ **Send Push Notification to a Store Topic (All Employees)**
  Future<void> sendTopicNotification(
      String storeId, String title, String message) async {
    try {
      // ✅ Get OAuth Access Token
      String? accessToken = await FirebaseAuthService.getAccessToken();
      if (accessToken == null) {
        print("❌ Failed to get OAuth access token.");
        return;
      }

      // ✅ Send topic-based notification
      final response = await http.post(
        Uri.parse(_fcmEndpoint),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $accessToken",
        },
        body: jsonEncode({
          "message": {
            "topic": storeId, // Topic name should match storeId
            "notification": {
              "title": title,
              "body": message,
            },
            "android": {
              "priority": "high",
            },
            "apns": {
              "headers": {
                "apns-priority": "10",
              },
            },
          }
        }),
      );

      if (response.statusCode == 200) {
        print("✅ Topic Notification Sent to store: $storeId");
      } else {
        print("❌ Failed to send topic notification: ${response.body}");
      }
    } catch (e) {
      print("❌ Error sending topic notification: $e");
    }
  }

  /// ✅ **Subscribe to a Store Topic (For Store Employees)**
  Future<void> subscribeToStoreTopic(String storeId) async {
    try {
      await FirebaseMessaging.instance.subscribeToTopic(storeId);
      print("✅ Subscribed to store topic: $storeId");
    } catch (e) {
      print("❌ Error subscribing to topic: $e");
    }
  }

  /// ✅ **Unsubscribe from a Store Topic (When Employee Leaves)**
  Future<void> unsubscribeFromStoreTopic(String storeId) async {
    try {
      await FirebaseMessaging.instance.unsubscribeFromTopic(storeId);
      print("✅ Unsubscribed from store topic: $storeId");
    } catch (e) {
      print("❌ Error unsubscribing from topic: $e");
    }
  }
}
