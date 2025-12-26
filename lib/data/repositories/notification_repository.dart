
import '../model/notification_model.dart';
import '../source/NotificationRemoteSource.dart';

class NotificationRepository {
  // On injecte la source de données
  final NotificationRemoteDataSource _remoteDataSource;

  NotificationRepository({NotificationRemoteDataSource? remoteDataSource})
      : _remoteDataSource = remoteDataSource ?? NotificationRemoteDataSource();

  // Les méthodes ne font que "passer le plat"
  Stream<List<NotificationModel>> getNotifications(int userId) {
    return _remoteDataSource.getUserNotificationsStream(userId);
  }

  Future<void> markAsRead(String id) async {
    await _remoteDataSource.markAsRead(id);
  }

  Future<void> deleteNotification(String id) async {
    await _remoteDataSource.delete(id);
  }
}
