import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationDetails {
  final String notificationId;
  final String title;
  final String message;
  final String icon;
  final bool isUnread;
  final String storeId;
  final String userId;
  final DateTime timestamp;

  NotificationDetails({
    required this.notificationId,
    required this.title,
    required this.message,
    required this.icon,
    required this.isUnread,
    required this.storeId,
    required this.userId,
    required this.timestamp,
  });

  /// ✅ Convert Firestore Document → NotificationDetails Model
  factory NotificationDetails.fromDocument(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationDetails(
      notificationId: doc.id,
      title: data['title'] ?? '',
      message: data['message'] ?? '',
      icon: data['icon'] ?? 'notifications',
      isUnread: data['isUnread'] ?? true,
      storeId: data['storeId'] ?? '',
      userId: data['userId'] ?? '',
      timestamp: (data['timestamp'] as Timestamp).toDate(),
    );
  }

  /// ✅ Convert NotificationDetails to Map (For Firestore)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'icon': icon,
      'isUnread': isUnread,
      'storeId': storeId,
      'userId': userId,
      'timestamp': Timestamp.fromDate(timestamp),
    };
  }

  /// ✅ **copyWith Method** - Allows modifying individual properties
  NotificationDetails copyWith({
    String? title,
    String? message,
    String? icon,
    bool? isUnread,
    String? storeId,
    String? userId,
    DateTime? timestamp,
  }) {
    return NotificationDetails(
      notificationId: notificationId,
      title: title ?? this.title,
      message: message ?? this.message,
      icon: icon ?? this.icon,
      isUnread: isUnread ?? this.isUnread,
      storeId: storeId ?? this.storeId,
      userId: userId ?? this.userId,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  /// 🔥 **Convert Timestamp to 'Time Ago' Format**
  String getTimeAgo() {
    return timeago.format(timestamp, locale: 'en_short'); // e.g., "5m ago"
  }

  /// 🔥 **Convert Icon Name to Flutter Icon**
  IconData getIcon() {
    switch (icon) {
      case "payments":
        return Icons.payment;
      case "shopping_cart":
        return Icons.shopping_cart;
      case "warning":
        return Icons.warning;
      default:
        return Icons.notifications;
    }
  }
}
