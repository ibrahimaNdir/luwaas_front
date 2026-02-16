import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationProvider extends ChangeNotifier {
  int _unreadCount = 0;
  int get unreadCount => _unreadCount;

  StreamSubscription<QuerySnapshot>? _notificationSubscription;
  String? _currentUserId;

  /// 🎧 Écoute en temps réel les notifications non lues
  void listenToNotifications(String userId) {
    // ✅ Éviter de relancer si déjà actif pour ce user
    if (_currentUserId == userId && _notificationSubscription != null) {
      return;
    }

    // ✅ Annuler l'ancienne écoute
    _notificationSubscription?.cancel();
    _currentUserId = userId;

    // ✅ Nouvelle écoute en temps réel avec gestion d'erreurs
    _notificationSubscription = FirebaseFirestore.instance
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('read', isEqualTo: false)
        .snapshots()
        .listen(
          (snapshot) {
        _unreadCount = snapshot.docs.length;
        notifyListeners();
      },
      onError: (error) {
        debugPrint('❌ Erreur stream notifications: $error');
        _unreadCount = 0;
        notifyListeners();
      },
    );
  }

  /// ✅ Marquer UNE notification comme lue
  Future<void> markAsRead(String userId, String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'read': true});

      // Le stream mettra à jour automatiquement _unreadCount
      debugPrint('✅ Notification $notificationId marquée comme lue');
    } catch (e) {
      debugPrint('❌ Erreur markAsRead: $e');
      rethrow;
    }
  }

  /// ✅ Marquer TOUTES les notifications comme lues
  Future<void> markAllRead(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .where('read', isEqualTo: false)
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ Aucune notification à marquer');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.update(doc.reference, {'read': true});
      }
      await batch.commit();

      debugPrint('✅ ${snapshot.docs.length} notifications marquées comme lues');
      // Le stream mettra à jour automatiquement
    } catch (e) {
      debugPrint('❌ Erreur markAllRead: $e');
      rethrow;
    }
  }

  /// 🗑️ Supprimer UNE notification
  Future<void> deleteNotification(String userId, String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .delete();

      debugPrint('✅ Notification $notificationId supprimée');
      // Le stream mettra à jour automatiquement
    } catch (e) {
      debugPrint('❌ Erreur deleteNotification: $e');
      rethrow;
    }
  }

  /// 🗑️ Supprimer TOUTES les notifications
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .get();

      if (snapshot.docs.isEmpty) {
        debugPrint('⚠️ Aucune notification à supprimer');
        return;
      }

      final batch = FirebaseFirestore.instance.batch();
      for (var doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      debugPrint('✅ ${snapshot.docs.length} notifications supprimées');
    } catch (e) {
      debugPrint('❌ Erreur deleteAllNotifications: $e');
      rethrow;
    }
  }

  /// 🔄 Réinitialiser le provider (utile au logout)
  void reset() {
    _notificationSubscription?.cancel();
    _notificationSubscription = null;
    _currentUserId = null;
    _unreadCount = 0;
    notifyListeners();
    debugPrint('🔄 NotificationProvider réinitialisé');
  }

  /// 🗑️ Nettoyer à la destruction
  @override
  void dispose() {
    _notificationSubscription?.cancel();
    debugPrint('🗑️ NotificationProvider dispose');
    super.dispose();
  }
}