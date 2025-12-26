import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String body;
  final String type;
  final bool isRead;
  final DateTime createdAt;
  final int userId;

  NotificationModel({
    required this.id,
    required this.title,
    required this.body,
    required this.type,
    required this.isRead,
    required this.createdAt,
    required this.userId,
  });

  factory NotificationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return NotificationModel(
      id: doc.id,
      title: data['titre'] ?? '',              // 🔁 Firestore: titre
      body: data['message'] ?? '',             // 🔁 Firestore: message
      type: data['type'] ?? 'info',
      isRead: data['is_read'] ?? false,        // 🔁 Firestore: is_read
      createdAt: _parseDate(data['created_at']), // 🔁 Firestore: created_at
      userId: _parseUserId(data['user_id']),   // 🔁 Firestore: "2" (string)
    );
  }

  static DateTime _parseDate(dynamic date) {
    if (date is Timestamp) return date.toDate();
    if (date is int) return DateTime.fromMillisecondsSinceEpoch(date * 1000);
    return DateTime.now();
  }

  static int _parseUserId(dynamic value) {
    if (value is int) return value;
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }
}
