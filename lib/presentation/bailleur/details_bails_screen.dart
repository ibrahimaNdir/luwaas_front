import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../data/model/bails.dart';

// import '../../services/pdf_service.dart'; // Si tu as un service pour gérer le téléchargement

class DetailBailScreen extends StatelessWidget {
  final Bail bail;

  const DetailBailScreen({Key? key, required this.bail}) : super(key: key);

  // Méthode simulée pour l'impression
  void _printBail(BuildContext context) {
    // Ici, tu appelleras ton API Laravel : GET /api/baux/{id}/pdf
    // Puis tu utiliseras un package comme 'url_launcher' ou 'printing' pour afficher le PDF
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Téléchargement du bail en cours...")),
    );
    print("Appel API PDF pour le bail #${bail.id}");
  }

  @override
  Widget build(BuildContext context) {
    // Récupération des données
    final locataireName = bail.locataire?['name'] ?? 'Inconnu';
    final locatairePhone = bail.locataire?['telephone'] ?? 'Non renseigné';
    final logementTitre = bail.logement?['titre'] ?? 'Logement';
    final logementAdresse = bail.logement?['adresse'] ?? '';

    final dateFormat = DateFormat('dd MMMM yyyy');

    return Scaffold(
      backgroundColor: Colors.grey[50], // Fond légèrement grisé
      appBar: AppBar(
        title: Text("Bail #00${bail.id}"),
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. HEADER : STATUT
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                decoration: BoxDecoration(
                  color: bail.statut == 'actif' ? Colors.green[100] : Colors.red[100],
                  borderRadius: BorderRadius.circular(30),
                  border: Border.all(color: bail.statut == 'actif' ? Colors.green : Colors.red),
                ),
                child: Text(
                  "Statut : ${bail.statut.toUpperCase()}",
                  style: TextStyle(
                    color: bail.statut == 'actif' ? Colors.green[800] : Colors.red[800],
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // 2. CARTE LOCATAIRE & LOGEMENT
            _buildSectionTitle(Icons.people_outline, "Les Parties"),
            _buildCard(
              children: [
                _buildRowInfo("Bailleur", "Vous (Propriétaire)"),
                const Divider(),
                _buildRowInfo("Locataire", locataireName, subValue: locatairePhone),
                const Divider(),
                _buildRowInfo("Logement", logementTitre, subValue: logementAdresse),
              ],
            ),

            const SizedBox(height: 25),

            // 3. CARTE FINANCIÈRE
            _buildSectionTitle(Icons.monetization_on_outlined, "Conditions Financières"),
            _buildCard(
              children: [
                _buildRowInfo("Loyer Mensuel", "${bail.montantLoyer} FCFA", isBold: true),
                const Divider(),
                _buildRowInfo("Charges", "${bail.chargesMensuelles} FCFA"),
                const Divider(),
                _buildRowInfo("Total Mensuel", "${bail.montantLoyer + bail.chargesMensuelles} FCFA", isBold: true, color: const Color(0xFF1E3A8A)),
                const Divider(),
                _buildRowInfo("Caution Versée", "${bail.caution} FCFA"),
              ],
            ),

            const SizedBox(height: 25),

            // 4. DATES ET DURÉE
            _buildSectionTitle(Icons.calendar_today_outlined, "Durée et Échéance"),
            _buildCard(
              children: [
                _buildRowInfo("Date d'entrée", dateFormat.format(bail.dateDebut)),
                const Divider(),
                _buildRowInfo("Date de fin", dateFormat.format(bail.dateFin)),
                const Divider(),
                _buildRowInfo("Jour de paiement", "Le ${bail.jourEcheance} du mois"),
                const Divider(),
                _buildRowInfo("Renouvellement", bail.renouvellementAutomatique ? "Automatique (Tacite)" : "Manuel"),
              ],
            ),

            const SizedBox(height: 40),

            // 5. BOUTON D'ACTION PRINCIPAL
            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: () => _printBail(context),
                icon: const Icon(Icons.print, color: Colors.white),
                label: const Text(
                  "IMPRIMER LE CONTRAT",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A), // Bleu Luwaas
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  elevation: 5,
                ),
              ),
            ),

            const SizedBox(height: 20),

            // BOUTON SECONDAIRE (Optionnel : Résilier)
            Center(
              child: TextButton(
                onPressed: () {
                  // Logique de résiliation
                },
                child: const Text("Résilier ce bail", style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- WIDGETS HELPER ---

  Widget _buildSectionTitle(IconData icon, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 5),
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey[700]),
          const SizedBox(width: 8),
          Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey[800])),
        ],
      ),
    );
  }

  Widget _buildCard({required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 5)),
        ],
      ),
      padding: const EdgeInsets.all(16),
      child: Column(children: children),
    );
  }

  Widget _buildRowInfo(String label, String value, {String? subValue, bool isBold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
                  fontSize: 15,
                  color: color ?? Colors.black87,
                ),
              ),
              if (subValue != null)
                Text(subValue, style: const TextStyle(fontSize: 12, color: Colors.grey)),
            ],
          ),
        ],
      ),
    );
  }
}
