import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../provider/notification_provider.dart'; // ✅ CORRIGÉ : provider (sans s)

class NotifScreen extends StatelessWidget {
  const NotifScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId == null) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 60, color: Colors.red),
              const SizedBox(height: 16),
              const Text('Utilisateur non connecté'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => Navigator.pushReplacementNamed(context, '/login'),
                child: const Text('Se connecter'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notifications'),
        backgroundColor: const Color(0xFF1E3E8A),
        foregroundColor: Colors.white,
        actions: [
          // 🔔 Badge + Bouton "Marquer tout lu"
          Consumer<NotificationProvider>(
            builder: (context, provider, child) {
              if (provider.unreadCount == 0) {
                return IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Aucune notification non lue',
                  onPressed: null, // Désactivé
                );
              }

              return Badge(
                label: Text('${provider.unreadCount}'),
                backgroundColor: Colors.red,
                child: IconButton(
                  icon: const Icon(Icons.done_all),
                  tooltip: 'Marquer tout lu',
                  onPressed: () => provider.markAllRead(userId),
                ),
              );
            },
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('notifications')
            .orderBy('createdAt', descending: true)
            .snapshots(),
        builder: (context, snapshot) {
          // État de chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Erreur
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 60, color: Colors.red),
                  const SizedBox(height: 16),
                  Text('Erreur: ${snapshot.error}'),
                ],
              ),
            );
          }

          // Aucune notification
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_none, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 16),
                  Text(
                    'Aucune notification',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          final notifications = snapshot.data!.docs;

          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notifDoc = notifications[index];
              final notif = notifDoc.data() as Map<String, dynamic>;

              return _buildNotificationCard(
                context,
                userId,
                notifDoc.id,
                notif,
              );
            },
          );
        },
      ),
    );
  }

  /// 🎨 Carte de notification universelle
  Widget _buildNotificationCard(
      BuildContext context,
      String userId,
      String notifId,
      Map<String, dynamic> notif,
      ) {
    final isRead = notif['read'] ?? false;
    final title = notif['title'] ?? 'Notification';
    final body = notif['body'] ?? '';
    final type = notif['type'] ?? 'general';
    final createdAt = (notif['createdAt'] as Timestamp?)?.toDate();

    // ✅ Icône et couleur selon le TYPE
    final style = _getNotificationStyle(type);

    return Dismissible(
      key: Key(notifId),
      direction: DismissDirection.endToStart,
      confirmDismiss: (direction) async {
        // ✅ Confirmation avant suppression
        return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Supprimer cette notification ?'),
            content: const Text('Cette action est irréversible.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Annuler'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text(
                  'Supprimer',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        );
      },
      onDismissed: (_) {
        Provider.of<NotificationProvider>(context, listen: false)
            .deleteNotification(userId, notifId);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Notification supprimée'),
            duration: Duration(seconds: 2),
          ),
        );
      },
      background: Container(
        color: Colors.red,
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.delete, color: Colors.white, size: 30),
            SizedBox(height: 4),
            Text(
              'Supprimer',
              style: TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
      child: Card(
        elevation: isRead ? 1 : 3,
        color: isRead ? Colors.white : Colors.blue[50],
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.all(16),
          leading: CircleAvatar(
            radius: 28,
            backgroundColor: style['color'],
            child: Icon(style['icon'], color: Colors.white, size: 28),
          ),
          title: Text(
            title,
            style: TextStyle(
              fontWeight: isRead ? FontWeight.w600 : FontWeight.bold,
              fontSize: 16,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 6),
              Text(
                body,
                style: const TextStyle(fontSize: 14, color: Colors.black87),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              if (createdAt != null) ...[
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Text(
                      _formatDate(createdAt),
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ],
            ],
          ),
          trailing: Icon(
            isRead ? Icons.mark_email_read : Icons.mark_email_unread,
            color: isRead ? Colors.grey : Colors.blue,
          ),
          onTap: () {
            // Marquer comme lu
            if (!isRead) {
              Provider.of<NotificationProvider>(context, listen: false)
                  .markAsRead(userId, notifId);
            }

            // ✅ Afficher les détails
            _showNotificationDetails(context, notif);
          },
        ),
      ),
    );
  }

  /// 🎨 Style selon le type de notification
  Map<String, dynamic> _getNotificationStyle(String type) {
    switch (type) {
      case 'nouvelle_demande':
        return {'icon': Icons.home_work, 'color': Colors.blue};
      case 'demande_acceptee':
        return {'icon': Icons.check_circle, 'color': Colors.green};
      case 'demande_refusee':
        return {'icon': Icons.cancel, 'color': Colors.red};
      case 'paiement_recu':
      case 'rappel_loyer':
        return {'icon': Icons.payments, 'color': Colors.orange};
      case 'fin_bail_proche':
        return {'icon': Icons.event, 'color': Colors.purple};
      case 'retard_paiement':
        return {'icon': Icons.warning, 'color': Colors.red[700]!};
      default:
        return {'icon': Icons.notifications, 'color': const Color(0xFF1E3E8A)};
    }
  }

  /// 📅 Formater la date
  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'À l\'instant';
    if (diff.inMinutes < 60) return 'Il y a ${diff.inMinutes} min';
    if (diff.inHours < 24) return 'Il y a ${diff.inHours}h';
    if (diff.inDays < 7) return 'Il y a ${diff.inDays}j';

    return DateFormat('dd/MM/yy à HH:mm').format(date);
  }

  /// 📋 Afficher les détails
  void _showNotificationDetails(BuildContext context, Map<String, dynamic> notif) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(
              _getNotificationStyle(notif['type'] ?? 'general')['icon'],
              color: _getNotificationStyle(notif['type'] ?? 'general')['color'],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                notif['title'] ?? 'Détails',
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                notif['body'] ?? '',
                style: const TextStyle(fontSize: 15),
              ),
              if (notif['data'] != null) ...[
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 8),
                const Text(
                  'Informations complémentaires :',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                const SizedBox(height: 8),
                ...((notif['data'] as Map<String, dynamic>).entries.map((e) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.arrow_right, size: 16),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${e.key}: ${e.value}',
                            style: const TextStyle(fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList()),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }
}