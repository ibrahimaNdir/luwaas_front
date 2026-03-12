import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:luwaas/data/model/demande.dart';
import '../../presentation/provider/DemandeProvider.dart';

class DetailDemandeScreen extends StatefulWidget {
  final Demande demande;

  const DetailDemandeScreen({Key? key, required this.demande}) : super(key: key);

  @override
  State<DetailDemandeScreen> createState() => _DetailDemandeScreenState();
}

class _DetailDemandeScreenState extends State<DetailDemandeScreen> {
  bool _isActionLoading = false;

  Future<void> _updateStatut(bool accepter) async {
    setState(() => _isActionLoading = true);

    final provider = Provider.of<DemandeProvider>(context, listen: false);

    try {
      if (accepter) {
        await provider.accepterDemande(widget.demande.id);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Demande de visite acceptée ! Vous pouvez maintenant contacter le locataire."),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
        }
      } else {
        // Confirmation avant de refuser
        final confirm = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text("Refuser la demande"),
            content: const Text("Êtes-vous sûr de vouloir refuser cette demande de visite ?"),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text("Annuler"),
              ),
              TextButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: TextButton.styleFrom(foregroundColor: Colors.red),
                child: const Text("Refuser"),
              ),
            ],
          ),
        );

        if (confirm == true) {
          await provider.refuserDemande(widget.demande.id);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text("Demande de visite refusée"),
                backgroundColor: Colors.red,
                duration: Duration(seconds: 2),
              ),
            );
          }
        } else {
          setState(() => _isActionLoading = false);
          return;
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Erreur: $e"),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isActionLoading = false);
      }
    }
  }

  void _goToCreationBail() {
    print("Navigation vers FormulaireBailScreen avec Demande #${widget.demande.id}");
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Fonctionnalité 'Créer le bail' à venir..."),
        backgroundColor: Colors.blue,
      ),
    );
    // TODO: Naviguer vers l'écran de création de bail
    /*
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulaireBailScreen(demande: freshDemande),
      ),
    );
    */
  }

  // ✅ Fonction pour appeler le locataire
  void _appellerLocataire() {
    final tel = widget.demande.locataireTelephone;
    if (tel != null && tel.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Appel vers $tel..."),
          backgroundColor: Colors.blue,
        ),
      );
      // TODO: Implémenter l'appel téléphonique
      // import 'package:url_launcher/url_launcher.dart';
      // final Uri phoneUri = Uri(scheme: 'tel', path: tel);
      // launchUrl(phoneUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Numéro de téléphone non disponible"),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final freshDemande = Provider.of<DemandeProvider>(context)
        .demandes
        .firstWhere((d) => d.id == widget.demande.id, orElse: () => widget.demande);

    final locataireNom = freshDemande.locataireNomComplet;
    final locataireEmail = freshDemande.locataireEmail ?? "Non renseigné";
    final locataireTel = freshDemande.locataireTelephone ?? "Non renseigné";

    final logementTitre = freshDemande.logementTitreComplet;
    final logementAdresse = freshDemande.logementAdresse ?? "";
    final logementPrix = freshDemande.logementPrix;
    final logementImage = freshDemande.logementPhotoUrl;
    final logementPhotos = freshDemande.logementPhotos;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail de la demande", style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF1E3A8A),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER : IMAGE LOGEMENT + PRIX
            Stack(
              children: [
                Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: logementImage != null
                      ? Image.network(
                    logementImage,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Center(
                        child: Icon(Icons.home, size: 80, color: Colors.grey),
                      );
                    },
                  )
                      : const Center(
                    child: Icon(Icons.home, size: 80, color: Colors.grey),
                  ),
                ),
                Positioned(
                  bottom: 20,
                  left: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      "${NumberFormat('#,###', 'fr_FR').format(logementPrix)} FCFA / mois",
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. TITRE DU LOGEMENT
                  Text(
                    logementTitre,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  if (logementAdresse.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 16, color: Colors.grey[600]),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            logementAdresse,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 20),

                  // 3. STATUS - Affichage conditionnel selon le statut
                  _buildStatusWidget(freshDemande),

                  const SizedBox(height: 20),

                  // 4. INFO LOCATAIRE
                  const Text(
                    "Demandeur",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Row(
                        children: [
                          CircleAvatar(
                            radius: 30,
                            backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
                            child: Text(
                              locataireNom.isNotEmpty
                                  ? locataireNom[0].toUpperCase()
                                  : 'L',
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.bold,
                                fontSize: 24,
                              ),
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  locataireNom,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Icon(Icons.email, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Expanded(
                                      child: Text(
                                        locataireEmail,
                                        style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.phone, size: 14, color: Colors.grey[600]),
                                    const SizedBox(width: 4),
                                    Text(
                                      locataireTel,
                                      style: TextStyle(color: Colors.grey[600], fontSize: 13),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          // ✅ Bouton d'appel (si demande acceptée)
                          if (freshDemande.isAcceptee && locataireTel != "Non renseigné")
                            IconButton(
                              onPressed: _appellerLocataire,
                              icon: const Icon(Icons.phone, color: Color(0xFF1E3A8A)),
                              tooltip: "Appeler le locataire",
                            ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 5. GALERIE PHOTOS
                  if (logementPhotos != null && logementPhotos.isNotEmpty) ...[
                    const Text(
                      "Photos du logement",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                    const SizedBox(height: 10),
                    SizedBox(
                      height: 100,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: logementPhotos.length,
                        itemBuilder: (context, index) {
                          final photo = logementPhotos[index];
                          final photoUrl = photo['url'];
                          return Container(
                            margin: const EdgeInsets.only(right: 10),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                photoUrl,
                                width: 100,
                                height: 100,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Container(
                                    width: 100,
                                    height: 100,
                                    color: Colors.grey[300],
                                    child: const Icon(Icons.image, color: Colors.grey),
                                  );
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],

                  // 6. DATE DE LA DEMANDE
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: Colors.grey[700]),
                        const SizedBox(width: 8),
                        Text(
                          "Demande reçue le ${DateFormat('dd/MM/yyyy à HH:mm').format(freshDemande.dateDemande)}",
                          style: TextStyle(color: Colors.grey[700]),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 80), // Espace pour les boutons
                ],
              ),
            ),
          ],
        ),
      ),

      // ZONE D'ACTION (Boutons en bas)
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: _buildActionButtons(freshDemande),
        ),
      ),
    );
  }

  // ✅ Widget pour afficher le statut selon l'état de la demande
  Widget _buildStatusWidget(Demande demande) {
    if (demande.isEnAttente) {
      // En attente - Badge normal
      return Row(
        children: [
          const Text(
            "Statut : ",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.orange),
            ),
            child:  Text(
              demande.statusLibelle,
              style: TextStyle(
                color: Colors.orange,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    } else if (demande.isAcceptee) {
      // Acceptée - Message avec icône verte
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.green.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.green.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "La demande de visite a été acceptée pour ce client.",
                style: TextStyle(
                  color: Colors.green,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    } else if (demande.isRefusee) {
      // Refusée - Message avec icône rouge
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.red.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.red.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.close, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text(
                "La demande de visite a été refusée pour ce client.",
                style: TextStyle(
                  color: Colors.red,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
          ],
        ),
      );
    } else {
      // Autres statuts (bail_signe, etc.)
      return Row(
        children: [
          const Text(
            "Statut : ",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: demande.statusColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: demande.statusColor),
            ),
            child: Text(
              demande.statusLibelle,
              style: TextStyle(
                color: demande.statusColor,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      );
    }
  }

  // ✅ Boutons d'action selon le statut
  Widget _buildActionButtons(Demande demande) {
    if (_isActionLoading) {
      return const SizedBox(
        height: 50,
        child: Center(child: CircularProgressIndicator()),
      );
    }

    // CAS 1 : EN ATTENTE -> Boutons Accepter / Refuser
    if (demande.isEnAttente) {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatut(false),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red, width: 2),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text("REFUSER", style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatut(true),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                "ACCEPTER",
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ],
      );
    }

    // CAS 2 : ACCEPTÉE -> Bouton "Créer un bail"
    if (demande.isAcceptee) {
      return SizedBox(
        width: double.infinity,
        child: ElevatedButton.icon(
          onPressed: _goToCreationBail,
          icon: const Icon(Icons.description, color: Colors.white),
          label: const Text(
            "CRÉER UN BAIL",
            style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
          ),
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green[700],
            padding: const EdgeInsets.symmetric(vertical: 15),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),
      );
    }

    // CAS 3 : REFUSÉE -> Pas de boutons (juste le message s'affiche en haut)
    if (demande.isRefusee) {
      return const SizedBox.shrink(); // Rien à afficher
    }

    // CAS 4 : Autres statuts
    return const SizedBox.shrink();
  }
}