import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class FcmService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  /// Appeler après login, quand tu connais le téléphone ou l'id Laravel
  Future<void> saveTokenForPhone(String phone) async {
    // Permission (iOS / Android 13+)
    await _messaging.requestPermission();

    final token = await _messaging.getToken();
    if (token == null) return;

    await FirebaseFirestore.instance
        .collection('device_tokens')
        .doc(phone) // ou .doc('$userId')
        .set({
      'token': token,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  /// Si le token change (réinstall, etc.), on met à jour dans Firestore
  void listenTokenRefresh(String phone) {
    _messaging.onTokenRefresh.listen((newToken) {
      FirebaseFirestore.instance
          .collection('device_tokens')
          .doc(phone)
          .set({
        'token': newToken,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    });
  }
}
