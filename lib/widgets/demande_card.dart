import 'package:flutter/material.dart';
import '../data/model/demande.dart';
import 'package:intl/intl.dart';

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
    // ✅ CORRECTION : Utiliser les bonnes clés et les getters du modèle
    final locataireName = demande.locataireNomComplet; // Getter du modèle
    final locatairePhoto = demande.locataire?['photo_url'];


    final logementTitre = demande.logementTitreComplet; // Getter du modèle
    final logementAdresse = demande.logementAdresse ?? '';

    // ✅ CORRECTION : Utiliser 'prix' au lieu de 'loyer_mensuel'
    final logementPrix = demande.logementPrix; // ✅ Au lieu de demande.logement?['prix']

    // ✅ CORRECTION : Utiliser 'photo_principale' au lieu de 'image_url'
    final logementImage = demande.logementPhotoUrl; // Getter du modèle

    print("🏠 Logement dans DemandeCard:");
    print("   Titre: $logementTitre");
    print("   Prix: $logementPrix FCFA");
    print("   Photo: $logementImage");
    print("   Locataire: $locataireName");

    // Couleur du badge selon le statut
    final statusColor = demande.statusColor; // Getter du modèle
    final statusText = demande.statusLibelle; // Getter du modèle

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
                        ? Image.network(
                      logementImage,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        print("❌ Erreur chargement image: $error");
                        return const Icon(Icons.home, color: Colors.grey, size: 40);
                      },
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return const Center(
                          child: CircularProgressIndicator(strokeWidth: 2),
                        );
                      },
                    )
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
                          color: Color(0xFF1E3A8A),
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (logementAdresse.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          logementAdresse,
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const SizedBox(height: 4),
                      Text(
                        "${NumberFormat('#,###', 'fr_FR').format(logementPrix)} FCFA / mois",
                        style: const TextStyle(
                          color: Colors.green,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
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
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
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
                    backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                    backgroundImage: locatairePhoto != null
                        ? NetworkImage(locatairePhoto)
                        : null,
                    child: locatairePhoto == null
                        ? Text(
                      locataireName.isNotEmpty ? locataireName[0].toUpperCase() : 'L',
                      style: const TextStyle(
                        color: Color(0xFF1E3A8A),
                        fontWeight: FontWeight.bold,
                      ),
                    )
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
                  // Date relative
                  Text(
                    DateFormat('dd/MM').format(demande.dateDemande),
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