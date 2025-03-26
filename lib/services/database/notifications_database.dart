import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:valgrow_ui/models/notifications_details.dart';

class NotificationsDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Fetch notifications for a specific user (sorted by latest)
  Future<List<NotificationDetails>> getUserNotifications(String userId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('notifications')
          .where('userId', isEqualTo: userId) // ✅ Filter by userId
          .orderBy('timestamp', descending: true) // ✅ Get latest first
          .get();

      // ✅ Convert Firestore documents to List of NotificationDetails
      List<NotificationDetails> notifications = querySnapshot.docs.map((doc) {
        return NotificationDetails.fromDocument(doc);
      }).toList();

      print("✅ Fetched ${notifications.length} notifications for user: $userId");

      return notifications;
    } catch (e) {
      print("❌ Error fetching notifications for user ($userId): $e");
      return []; // Return empty list on error
    }
  }
}
