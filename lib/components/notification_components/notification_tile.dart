import 'package:flutter/material.dart';

class NotificationTile extends StatelessWidget {
  final String title;
  final String message;
  final String time;
  final IconData icon;
  final bool isUnread;
  final VoidCallback onTap; // ✅ Callback for showing details

  const NotificationTile({
    super.key,
    required this.title,
    required this.message,
    required this.time,
    required this.onTap, // ✅ Receive callback function
    this.icon = Icons.notifications,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap, // ✅ Call onTap when tapped
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // ✅ Notification Icon with Background
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: isUnread ? Colors.blue.shade100 : Colors.grey.shade300,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    icon,
                    size: 28,
                    color: isUnread ? Colors.blueAccent : Colors.grey.shade700,
                  ),
                ),
                const SizedBox(width: 12),

                // ✅ Notification Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      RichText(
                        text: TextSpan(
                          style: TextStyle(
                            fontSize: 14.5,
                            color: Colors.black,
                            fontWeight: isUnread ? FontWeight.bold : FontWeight.w500,
                          ),
                          children: [
                            TextSpan(text: title),
                            const TextSpan(text: "\n"),
                            TextSpan(
                              text: message,
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[700],
                                fontWeight: FontWeight.normal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 4),
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

                // ✅ Unread Indicator (Blue Dot)
                if (isUnread)
                  Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Container(
                      width: 10,
                      height: 10,
                      decoration: const BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
