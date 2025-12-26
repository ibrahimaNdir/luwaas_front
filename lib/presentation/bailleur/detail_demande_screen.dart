import 'package:flutter/material.dart';
import 'package:provider/provider.dart';


import 'package:luwaas/data/model/demande.dart';
import '../../presentation/provider/DemandeProvider.dart';

// import 'formulaire_bail_screen.dart'; // On créera ce fichier juste après pour tester la navigation

class DetailDemandeScreen extends StatefulWidget {
  final Demande demande;

  const DetailDemandeScreen({Key? key, required this.demande}) : super(key: key);

  @override
  State<DetailDemandeScreen> createState() => _DetailDemandeScreenState();
}

class _DetailDemandeScreenState extends State<DetailDemandeScreen> {
  bool _isActionLoading = false;

  // Méthode pour gérer l'acceptation/refus
  Future<void> _updateStatut(bool accepter) async {
    setState(() => _isActionLoading = true);

    final provider = Provider.of<DemandeProvider>(context, listen: false);

    if (accepter) {
      await provider.accepterDemande(widget.demande.id);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Demande acceptée ! Vous pouvez créer le bail."), backgroundColor: Colors.green),
        );
      }
    } else {
      await provider.refuserDemande(widget.demande.id);
      if (mounted) {
        Navigator.pop(context); // On quitte l'écran si refusé
      }
    }

    if (mounted) {
      setState(() => _isActionLoading = false);
    }
  }

  void _goToCreationBail() {
    // Navigation vers le formulaire de bail (pré-rempli)
    /*
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormulaireBailScreen(
          demande: widget.demande, // On passe la demande pour pré-remplir
        ),
      ),
    );
    */
    print("Navigation vers FormulaireBailScreen avec Demande #${widget.demande.id}");
  }

  @override
  Widget build(BuildContext context) {
    // On écoute le provider pour voir si le statut change en temps réel (ex: après avoir cliqué sur Accepter)
    final freshDemande = Provider.of<DemandeProvider>(context)
        .demandes
        .firstWhere((d) => d.id == widget.demande.id, orElse: () => widget.demande);

    final locataire = freshDemande.locataire;
    final logement = freshDemande.logement;

    return Scaffold(
      appBar: AppBar(
        title: const Text("Détail de la demande"),
        backgroundColor: const Color(0xFF1E3A8A),
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
                  child: logement?['image_url'] != null
                      ? Image.network(logement!['image_url'], fit: BoxFit.cover)
                      : const Icon(Icons.home, size: 80, color: Colors.grey),
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
                      "${logement?['prix'] ?? 0} FCFA / mois",
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                )
              ],
            ),

            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. STATUS
                  Row(
                    children: [
                      const Text("Statut actuel : ", style: TextStyle(fontSize: 16, color: Colors.grey)),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: _getStatusColor(freshDemande.status).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          freshDemande.status.toUpperCase().replaceAll('_', ' '),
                          style: TextStyle(
                            color: _getStatusColor(freshDemande.status),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // 3. INFO LOCATAIRE
                  const Text("Demandeur", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
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
                            backgroundImage: locataire?['photo_url'] != null ? NetworkImage(locataire!['photo_url']) : null,
                            child: locataire?['photo_url'] == null ? const Icon(Icons.person) : null,
                          ),
                          const SizedBox(width: 15),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(locataire?['name'] ?? "Inconnu", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Text(locataire?['email'] ?? "", style: TextStyle(color: Colors.grey[600])),
                              Text(locataire?['telephone'] ?? "Pas de numéro", style: TextStyle(color: Colors.grey[600])),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // 4. MESSAGE DU LOCATAIRE (Optionnel)
                  const Text("Message", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Color(0xFF1E3A8A))),
                  const SizedBox(height: 5),
                  Text(
                    "Bonjour, je suis très intéressé par ce logement. Est-il possible de le visiter ce week-end ?",
                    style: TextStyle(color: Colors.grey[800], height: 1.5),
                  ),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, offset: const Offset(0, -5))],
        ),
        child: SafeArea(
          child: _buildActionButtons(freshDemande),
        ),
      ),
    );
  }

  // Logique d'affichage des boutons
  Widget _buildActionButtons(Demande demande) {
    if (_isActionLoading) {
      return const SizedBox(height: 50, child: Center(child: CircularProgressIndicator()));
    }

    // CAS 1 : EN ATTENTE -> Accepter ou Refuser
    if (demande.status == 'en_attente') {
      return Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => _updateStatut(false), // Refuser
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.red,
                side: const BorderSide(color: Colors.red),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text("REFUSER"),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: ElevatedButton(
              onPressed: () => _updateStatut(true), // Accepter
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(vertical: 15),
              ),
              child: const Text("ACCEPTER", style: TextStyle(color: Colors.white)),
            ),
          ),
        ],
      );
    }

    // CAS 2 : ACCEPTÉE -> Créer le Bail
    if (demande.status == 'acceptee') {
      return ElevatedButton.icon(
        onPressed: _goToCreationBail,
        icon: const Icon(Icons.description, color: Colors.white),
        label: const Text("CRÉER LE BAIL", style: TextStyle(color: Colors.white, fontSize: 16)),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green[700], // Vert pour l'action positive
          padding: const EdgeInsets.symmetric(vertical: 15),
        ),
      );
    }

    // CAS 3 : REFUSÉE OU AUTRE -> Bouton inactif
    return ElevatedButton(
      onPressed: null,
      style: ElevatedButton.styleFrom(disabledBackgroundColor: Colors.grey[300]),
      child: Text("Demande ${demande.status}", style: const TextStyle(color: Colors.grey)),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'acceptee': return Colors.green;
      case 'refusee': return Colors.red;
      default: return Colors.orange;
    }
  }
}
