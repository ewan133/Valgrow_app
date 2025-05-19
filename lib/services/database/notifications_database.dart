import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:valgrow_ui/models/notifications_details.dart';

class NotificationsDatabase {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// ✅ Fetch notifications for a specific store (sorted by latest)
  Future<List<NotificationDetails>> getStoreNotifications(
      String storeId) async {
    try {
      QuerySnapshot querySnapshot = await _db
          .collection('notifications')
          .where('storeId', isEqualTo: storeId) // ✅ Fetch by storeId
          .orderBy('timestamp', descending: true) // ✅ Show latest first
          .get();

      // ✅ Convert Firestore documents to List of NotificationDetails
      List<NotificationDetails> notifications = querySnapshot.docs.map((doc) {
        return NotificationDetails.fromDocument(doc);
      }).toList();

      print(
          "✅ Fetched ${notifications.length} notifications for store: $storeId");
      return notifications;
    } catch (e) {
      print("❌ Error fetching notifications for store ($storeId): $e");
      return []; // Return empty list on error
    }
  }

  /// ✅ Mark a single notification as read
  Future<void> markNotificationAsRead(String notificationId) async {
    try {
      await _db.collection('notifications').doc(notificationId).update({
        'isUnread': false,
      });

      print("✅ Notification $notificationId marked as read");
    } catch (e) {
      print("❌ Error marking notification as read: $e");
    }
  }

  Future<void> markAllNotificationsAsRead(String storeId) async {
    try {
      final snapshot = await _db
          .collection('notifications')
          .where('storeId', isEqualTo: storeId)
          .where('isUnread', isEqualTo: true)
          .get();

      if (snapshot.docs.isEmpty) {
        print("ℹ️ No unread notifications found for store $storeId");
        return;
      }

      WriteBatch batch = _db.batch();

      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'isUnread': false});
      }

      await batch.commit();
      print("✅ All notifications marked as read for store $storeId");
    } catch (e) {
      print("❌ Failed to mark notifications as read: $e");
    }
  }

  Future<void> checkAndInsertOverdueDebtNotifications(String storeId) async {
    try {
      print("🔍 Checking for overdue debts in store: $storeId...");

      final today = DateTime.now();

      // 🔹 Get overdue debts with separate queries for 'unpaid' and 'partial'
      final unpaidDebtsQuery = await _db
          .collection('debts')
          .where('storeId', isEqualTo: storeId)
          .where('status', isEqualTo: "unpaid")
          .where('due_date', isLessThan: today)
          .get();

      final partialDebtsQuery = await _db
          .collection('debts')
          .where('storeId', isEqualTo: storeId)
          .where('status', isEqualTo: "partial")
          .where('due_date', isLessThan: today)
          .get();

      final overdueDebts = [
        ...unpaidDebtsQuery.docs,
        ...partialDebtsQuery.docs,
      ];

      if (overdueDebts.isEmpty) {
        print("✅ No overdue debts found for store: $storeId");
        return;
      }

      // 🔹 Check existing notifications to avoid duplicates
      final existingNotificationsQuery = await _db
          .collection('notifications')
          .where('storeId', isEqualTo: storeId)
          .where('title', isEqualTo: "Overdue Debt Alert")
          .get();

      final existingNotifiedCustomers = existingNotificationsQuery.docs
          .map((doc) => doc["customerId"] as String)
          .toSet();

      final WriteBatch batch = _db.batch();

      for (var debtDoc in overdueDebts) {
        final data = debtDoc.data() as Map<String, dynamic>;
        final String customerId = data['customerId'];
        final String transactionId = data['transactionId'];
        final double balance = (data['balance'] ?? 0.0).toDouble();
        final DateTime dueDate = (data['due_date'] as Timestamp).toDate();

        if (existingNotifiedCustomers.contains(customerId)) {
          print("⚠️ Already notified customer $customerId – skipping.");
          continue;
        }

        final customerDoc =
            await _db.collection('customers').doc(customerId).get();
        final customerName = customerDoc.exists
            ? (customerDoc['name'] ?? "Unknown Customer")
            : "Unknown Customer";

        final formattedDueDate = DateFormat("MMMM d, y").format(dueDate);

        final notificationRef = _db.collection('notifications').doc();

        batch.set(notificationRef, {
          "storeId": storeId,
          "userId": storeId,
          "customerId": customerId,
          "transactionId": transactionId,
          "title": "Overdue Debt Alert",
          "message":
              "$customerName has an overdue debt of ₱$balance since $formattedDueDate.",
          "icon": "warning",
          "isUnread": true,
          "timestamp": FieldValue.serverTimestamp(),
        });

        print("🚨 Overdue debt notification added for Customer: $customerName");
      }

      await batch.commit();
      print("✅ Overdue debt notifications processed successfully!");
    } catch (e) {
      print("❌ Error checking/inserting overdue debt notifications: $e");
    }
  }
}
