import 'package:cloud_firestore/cloud_firestore.dart';

import '../model/notification_model.dart';

class NotificationRemoteDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Stream<List<NotificationModel>> getUserNotificationsStream(int userId) {
    return _firestore
        .collection('notifications')
        .where('user_id', isEqualTo: userId.toString()) // "2" en string
        .orderBy('created_at', descending: true)        // champ Firestore
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromFirestore(doc))
          .toList();
    });
  }

  Future<void> markAsRead(String docId) async {
    await _firestore
        .collection('notifications')
        .doc(docId)
        .update({'is_read': true});                     // champ Firestore
  }

  Future<void> delete(String docId) async {
    await _firestore
        .collection('notifications')
        .doc(docId)
        .delete();
  }
}
