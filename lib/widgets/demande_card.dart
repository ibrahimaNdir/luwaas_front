import 'package:flutter/material.dart';

import '../data/model/demande.dart';
import 'package:intl/intl.dart'; // Pour formater la date/prix si besoin

class DemandeCard extends StatelessWidget {
  final Demande demande;
  final VoidCallback onTap;

  const DemandeCard({
    Key? key,
    required this.demande,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Récupération sécurisée des données imbriquées
    final locataireName = demande.locataire?['name'] ?? 'Locataire inconnu';
    final locatairePhoto = demande.locataire?['photo_url']; // URL ou null

    final logementTitre = demande.logement?['titre'] ?? 'Logement';
    final logementPrix = demande.logement?['prix'] ?? 0;
    final logementImage = demande.logement?['image_url']; // URL de la première photo

    // Couleur du badge selon le statut
    Color statusColor;
    String statusText;
    switch (demande.status) {
      case 'acceptee':
        statusColor = Colors.green;
        statusText = "Acceptée";
        break;
      case 'refusee':
        statusColor = Colors.red;
        statusText = "Refusée";
        break;
      default:
        statusColor = Colors.orange;
        statusText = "En attente";
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          children: [
            // PARTIE HAUTE : INFO LOGEMENT
            Row(
              children: [
                // Image du logement (Carré gauche)
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(15),
                  ),
                  child: Container(
                    width: 100,
                    height: 100,
                    color: Colors.grey[200],
                    child: logementImage != null
                        ? Image.network(logementImage, fit: BoxFit.cover)
                        : const Icon(Icons.home, color: Colors.grey, size: 40),
                  ),
                ),
                const SizedBox(width: 12),
                // Infos Logement
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        logementTitre,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1E3A8A), // Ton Bleu Luwaas
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        "$logementPrix FCFA / mois",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      // Badge Statut
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: statusColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: statusColor.withOpacity(0.5)),
                        ),
                        child: Text(
                          statusText,
                          style: TextStyle(color: statusColor, fontSize: 12),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // LIGNE DE SÉPARATION
            Divider(height: 1, color: Colors.grey[200]),

            // PARTIE BASSE : INFO DEMANDEUR
            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  // Photo Locataire (Rond)
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: Colors.grey[300],
                    backgroundImage: locatairePhoto != null
                        ? NetworkImage(locatairePhoto)
                        : null,
                    child: locatairePhoto == null
                        ? const Icon(Icons.person, size: 20, color: Colors.white)
                        : null,
                  ),
                  const SizedBox(width: 10),
                  // Nom + "A demandé..."
                  Expanded(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.black87, fontSize: 13),
                        children: [
                          TextSpan(
                            text: locataireName,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          const TextSpan(text: " a envoyé une demande"),
                        ],
                      ),
                    ),
                  ),
                  // Date relative (Il y a X temps)
                  Text(
                    DateFormat('dd/MM').format(demande.dateDemande), // Ou lib 'timeago' si tu l'as
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
