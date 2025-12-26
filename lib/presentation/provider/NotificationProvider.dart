import 'package:flutter/material.dart';
import '../../data/model/notification_model.dart';
import '../../data/repositories/notification_repository.dart';

class NotificationProvider with ChangeNotifier {
  final NotificationRepository _repository = NotificationRepository();

  // On garde le stream ici
  Stream<List<NotificationModel>> getNotifications(int userId) {
    return _repository.getNotifications(userId);
  }

  // Action : Marquer comme lu
  Future<void> markAsRead(String id) async {
    await _repository.markAsRead(id);
    // Pas besoin de notifyListeners() car le Stream mettra à jour l'UI tout seul !
  }

  // Action : Supprimer
  Future<void> delete(String id) async {
    await _repository.deleteNotification(id);
  }
}
