import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/model/notification_model.dart';
import '../provider/NotificationProvider.dart';

class NotificationsScreen extends StatefulWidget {
  // L'ID de l'utilisateur est nécessaire pour filtrer les notifications
  final int userId;

  const NotificationsScreen({Key? key, required this.userId}) : super(key: key);

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {

  @override
  Widget build(BuildContext context) {
    // On accède au Provider pour récupérer les données
    final notifProvider = Provider.of<NotificationProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Notifications"),
        centerTitle: true,
      ),
      // StreamBuilder écoute les changements en temps réel
      body: StreamBuilder<List<NotificationModel>>(
        stream: notifProvider.getNotifications(widget.userId),
        builder: (context, snapshot) {
          // 1. Chargement
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Erreur
          if (snapshot.hasError) {
            return Center(child: Text("Une erreur est survenue : ${snapshot.error}"));
          }

          // 3. Aucune donnée
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.notifications_off_outlined, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text("Aucune notification pour le moment.",
                      style: TextStyle(color: Colors.grey, fontSize: 16)),
                ],
              ),
            );
          }

          // 4. Affichage de la liste
          final notifications = snapshot.data!;

          return ListView.builder(
            itemCount: notifications.length,
            itemBuilder: (context, index) {
              final notif = notifications[index];

              return Dismissible(
                // Permet de swiper pour supprimer
                key: Key(notif.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  color: Colors.red,
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: const Icon(Icons.delete, color: Colors.white),
                ),
                onDismissed: (direction) {
                  notifProvider.delete(notif.id); // Suppression via le Provider
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Notification supprimée")),
                  );
                },
                child: Card(
                  // Couleur différente si non lu
                  color: notif.isRead ? Colors.white : Colors.blue.shade50,
                  elevation: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: notif.isRead ? Colors.grey.shade300 : Colors.blue,
                      child: Icon(
                        _getIconForType(notif.type), // Icône dynamique
                        color: notif.isRead ? Colors.grey.shade600 : Colors.white,
                      ),
                    ),
                    title: Text(
                      notif.title,
                      style: TextStyle(
                        fontWeight: notif.isRead ? FontWeight.normal : FontWeight.bold,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 5),
                        Text(notif.body, maxLines: 2, overflow: TextOverflow.ellipsis),
                        const SizedBox(height: 5),
                        Text(
                          DateFormat('dd/MM à HH:mm').format(notif.createdAt),
                          style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                    onTap: () {
                      _handleNotificationClick(context, notif, notifProvider);
                    },
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  // --- Méthodes Utilitaires ---

  // 1. Choisir l'icône selon le type
  IconData _getIconForType(String type) {
    switch (type) {
      case 'nouvelle_demande':
        return Icons.home_work_outlined;
      case 'demande_acceptee':
        return Icons.check_circle_outline;
      case 'loyer_recu':
        return Icons.attach_money;
      case 'rappel_paiement':
        return Icons.warning_amber_rounded;
      case 'info':
      default:
        return Icons.notifications;
    }
  }

  // 2. Gérer le clic (Marquer lu + Navigation)
  void _handleNotificationClick(BuildContext context, NotificationModel notif, NotificationProvider provider) {
    // Marquer comme lu
    if (!notif.isRead) {
      provider.markAsRead(notif.id);
    }

    // Navigation intelligente
    switch (notif.type) {
      case 'nouvelle_demande':
      // Rediriger vers la liste des demandes (Côté Bailleur)
      // Navigator.pushNamed(context, '/proprietaire/demandes');
        break;

      case 'demande_acceptee':
      // Rediriger vers la liste des baux (Côté Locataire)
      // Navigator.pushNamed(context, '/locataire/baux');
        break;

      case 'test':
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ceci est un test réussi ! 🚀"))
        );
        break;

      default:
      // Par défaut, on ne fait rien ou on affiche un message
        break;
    }
  }
}
