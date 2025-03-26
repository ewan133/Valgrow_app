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
      Provider.of<DatabaseProvider>(context, listen: false).fetchUserNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<DatabaseProvider>(context);
    final notifications = provider.notifications;
    final isLoading = provider.isLoadingNotifications;

    return Scaffold(
      appBar: MyAppbar(title: "Notifications"),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // ✅ Show loader while fetching
          : notifications.isEmpty
              ? const Center(child: Text("No notifications available."))
              : ListView.builder(
                  itemCount: notifications.length,
                  itemBuilder: (context, index) {
                    final notification = notifications[index];
                    return NotificationTile(
                      title: notification.title,
                      message: notification.message,
                      time: notification.getTimeAgo(), // ✅ Convert timestamp to human-readable format
                      icon: notification.getIcon(), // ✅ Dynamic icon handling
                      isUnread: notification.isUnread,
                    );
                  },
                ),
    );
  }
}
