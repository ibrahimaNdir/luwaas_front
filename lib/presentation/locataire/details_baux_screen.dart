import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/model/bails.dart';

class DetailBailLocataireScreen extends StatelessWidget {
  const DetailBailLocataireScreen({Key? key, required Bail bail}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final bail = ModalRoute.of(context)!.settings.arguments as Bail;
    final fmt = NumberFormat('#,###', 'fr_FR');

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        title: const Text(
          'Détails du bail',
          style: TextStyle(color: Colors.black87),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black87),
        actions: [
          IconButton(
            icon: const Icon(Icons.picture_as_pdf_outlined),
            onPressed: () {
              // TODO: Télécharger PDF
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Téléchargement du PDF..."),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header avec statut
            _buildHeader(bail, fmt),

            const SizedBox(height: 16),

            // Infos logement
            _buildSection(
              title: "Logement",
              icon: Icons.home_outlined,
              child: _buildLogementInfo(bail),
            ),

            const SizedBox(height: 12),

            // Infos financières
            _buildSection(
              title: "Informations financières",
              icon: Icons.account_balance_wallet_outlined,
              child: _buildFinancesInfo(bail, fmt),
            ),

            const SizedBox(height: 12),

            // Période du bail
            _buildSection(
              title: "Période du bail",
              icon: Icons.calendar_today_outlined,
              child: _buildPeriodeInfo(bail),
            ),

            const SizedBox(height: 12),

            // Propriétaire
            _buildSection(
              title: "Propriétaire",
              icon: Icons.person_outline,
              child: _buildProprietaireInfo(bail),
            ),

            const SizedBox(height: 16),

            // Boutons d'action
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Bouton Payer le loyer
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          '/payment_detail',
                          arguments: bail,
                        );
                      },
                      icon: const Icon(Icons.payment, color: Colors.white),
                      label: const Text(
                        "Payer le loyer",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  // Bouton Télécharger le contrat
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // TODO: Télécharger PDF
                      },
                      icon: const Icon(Icons.download),
                      label: const Text(
                        "Télécharger le contrat",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader(Bail bail, NumberFormat fmt) {
    final logement = bail.logement ?? {};
    final titre = logement['titre'] ?? 'Logement';
    final numero = logement['numero'] ?? '';

    final isActif = bail.statut == 'actif';
    final isEnAttente = bail.statut == 'en_attente_paiement';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
      ),
      child: Column(
        children: [
          // Icône
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Icon(
              Icons.description,
              size: 40,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),

          // Titre
          Text(
            numero.isNotEmpty ? numero : titre,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Badge statut
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isActif
                  ? const Color(0xFF22C55E)
                  : isEnAttente
                  ? const Color(0xFFF59E0B)
                  : Colors.grey,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isActif
                  ? "Bail actif"
                  : isEnAttente
                  ? "En attente de paiement"
                  : "Inactif",
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Loyer mensuel
          Column(
            children: [
              const Text(
                "Loyer mensuel",
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                "${fmt.format(bail.montantLoyer)} FCFA",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // SECTIONS
  // ══════════════════════════════════════════════════════════
  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header de section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E3A8A).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(icon, color: const Color(0xFF1E3A8A), size: 20),
                  ),
                  const SizedBox(width: 12),
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B),
                    ),
                  ),
                ],
              ),
            ),

            const Divider(height: 1),

            // Contenu
            Padding(
              padding: const EdgeInsets.all(16),
              child: child,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogementInfo(Bail bail) {
    final logement = bail.logement ?? {};

    return Column(
      children: [
        _buildInfoRow(
          "Titre",
          logement['titre'] ?? 'N/A',
        ),
        _buildInfoRow(
          "Numéro",
          logement['numero'] ?? 'N/A',
        ),
        _buildInfoRow(
          "Adresse",
          logement['adresse'] ?? 'N/A',
        ),
        _buildInfoRow(
          "Superficie",
          "${logement['superficie'] ?? 0} m²",
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildFinancesInfo(Bail bail, NumberFormat fmt) {
    return Column(
      children: [
        _buildInfoRow(
          "Loyer mensuel",
          "${fmt.format(bail.montantLoyer)} FCFA",
        ),
        _buildInfoRow(
          "Charges mensuelles",
          "${fmt.format(bail.chargesMensuelles)} FCFA",
        ),
        _buildInfoRow(
          "Caution",
          "${fmt.format(bail.caution)} FCFA",
        ),
        _buildInfoRow(
          "Jour d'échéance",
          "Le ${bail.jourEcheance} de chaque mois",
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildPeriodeInfo(Bail bail) {
    final dateDebut = DateFormat('dd MMMM yyyy' ).format(bail.dateDebut);
    final dateFin = DateFormat('dd MMMM yyyy').format(bail.dateFin);
    final duree = bail.dateFin.difference(bail.dateDebut).inDays ~/ 30;

    return Column(
      children: [
        _buildInfoRow("Date de début", dateDebut),
        _buildInfoRow("Date de fin", dateFin),
        _buildInfoRow(
          "Durée",
          "$duree mois",
        ),
        _buildInfoRow(
          "Renouvellement auto",
          bail.renouvellementAutomatique ? "Oui" : "Non",
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildProprietaireInfo(Bail bail) {
    // TODO: Récupérer les vraies infos du propriétaire depuis le bail
    return Column(
      children: [
        _buildInfoRow("Nom", "Propriétaire"),
        _buildInfoRow("Téléphone", "+221 XX XXX XX XX"),
        _buildInfoRow(
          "Email",
          "proprietaire@email.com",
          isLast: true,
        ),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value, {bool isLast = false}) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            flex: 3,
            child: Text(
              value,
              style: const TextStyle(
                color: Color(0xFF1E293B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }
}