import 'package:flutter/material.dart';
import 'package:valgrow_ui/components/general_components/appbar.dart';
import 'package:valgrow_ui/components/notification_components/notification_tile.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Notifications"),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              children: [
                NotificationTile(
                  title: "New Order Received",
                  message: "You have a new order from John Doe.",
                  time: "2h ago",
                  icon: Icons.shopping_cart,
                  isUnread: true,
                ),
                NotificationTile(
                  title: "Stock Running Low",
                  message: "Item XYZ is low on stock.",
                  time: "5h ago",
                  icon: Icons.warning_amber_rounded,
                  isUnread: false,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
