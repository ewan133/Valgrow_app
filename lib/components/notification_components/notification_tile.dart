import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isUnread;

  const NotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    this.icon = Icons.notifications,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4), // ✅ Padding on both sides
      child: Container(
        decoration: BoxDecoration(
          color: isUnread ? Colors.blue.shade50 : Colors.white, // Highlight unread notifications
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnread ? Colors.blueAccent : Colors.grey.shade300,
            width: isUnread ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ✅ Notification Icon
            CircleAvatar(
              radius: 28,
              backgroundColor: isUnread ? Colors.blueAccent : Colors.grey[300],
              child: Icon(
                icon,
                size: 26,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),

            // ✅ Notification Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isUnread ? Colors.black : Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    message,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),

            // ✅ Timestamp
            Text(
              time,
              style: const TextStyle(
                fontSize: 12,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
