import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/notification_components/notification_tile.dart';
import 'package:valgrow_ui/services/database/database_provider.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  void initState() {
    super.initState();
    // ✅ Fetch notifications when the page loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DatabaseProvider>(context, listen: false)
          .fetchUserNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    final notifications = provider.notifications;
    final isLoading = provider.isLoadingNotifications;

    return Scaffold(
      appBar: MyAppbar(
        title: "Notifications",
        actionWidget: notifications.isNotEmpty
            ? TextButton(
                onPressed: () async {
                  await provider.markAllNotificationsAsRead();
                },
                child: const Text(
                  "Seen All",
                  style: TextStyle(fontSize: 16, color: Colors.black),
                ),
              )
            : null,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : notifications.isEmpty
              ? const Center(child: Text("No notifications available."))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];

                    return NotificationTile(
                      title: notification.title,
                      message: notification.message,
                      time: notification.getTimeAgo(),
                      icon: notification.getIcon(),
                      isUnread: notification.isUnread,
                      onTap: () async {
                        print("🔹 Notification Clicked: ${notification.notificationId}");
                        
                        // ✅ Show notification details
                        await _showNotificationDetails(context, notification);

                        // ✅ Mark as read AFTER closing the dialog
                        if (notification.isUnread) {
                          print("📌 Marking as read: ${notification.notificationId}");
                          await provider.markNotificationAsRead(notification.notificationId);
                        }
                      },
                    );
                  },
                ),
    );
  }

  /// ✅ **Show Alert Dialog with Notification Details**
  Future<void> _showNotificationDetails(BuildContext context, notification) async {
    print("🔔 Showing Notification Alert: ${notification.title}");

    await showDialog(
      context: context,
      barrierDismissible: true, // ✅ Allow dismissing when tapping outside
      builder: (BuildContext dialogContext) {
        print("🟢 Alert Dialog is being built");

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          title: Row(
            children: [
              Icon(notification.getIcon(), color: Colors.blue),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  notification.title,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notification.message,
                style: const TextStyle(fontSize: 16, color: Colors.black87),
              ),
              const SizedBox(height: 12),
              Text(
                "Received: ${notification.getTimeAgo()}",
                style: TextStyle(fontSize: 14, color: Colors.grey.shade700),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                print("🔴 Alert Dialog Closed");
                Navigator.pop(dialogContext);
              },
              child: const Text("Close", style: TextStyle(fontSize: 16)),
            ),
          ],
        );
      },
    );
  }
}
