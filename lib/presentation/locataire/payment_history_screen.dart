import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/model/bailspaiement.dart';
import '../../data/model/paiements.dart';
import '../../presentation/provider/PaiementProvider.dart';
class PaymentHistoryScreen extends StatefulWidget {
  final BailPaiement bail;

  const PaymentHistoryScreen({super.key, required this.bail});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    // Charger l'historique des paiements dès l'ouverture
    Future.microtask(() {
      Provider.of<PaiementProvider>(context, listen: false)
          .fetchPaiements(widget.bail.id); // On passe l'ID du bail (ou logement_id selon ton API)
    });
  }

  @override
  Widget build(BuildContext context) {
    final paiementProvider = Provider.of<PaiementProvider>(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F4F6),
      appBar: AppBar(
        title: Text(
          widget.bail.numero, // Affiche "A-220"
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Builder(
        builder: (_) {
          if (paiementProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (paiementProvider.error != null) {
            return Center(child: Text(paiementProvider.error!));
          }

          final paiements = paiementProvider.paiements;

          if (paiements.isEmpty) {
            return const Center(child: Text("Aucun historique disponible."));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: paiements.length,
            separatorBuilder: (context, index) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final paiement = paiements[index];
              return _buildPaymentCard(paiement);
            },
          );
        },
      ),
    );
  }

  Widget _buildPaymentCard(Paiement paiement) {
    final bool isPaid = paiement.statut.toLowerCase() == 'paye' ||
        paiement.statut.toLowerCase() == 'payé';

    // Formatage du montant (ex: 130 000)
    final formattedMontant = NumberFormat("#,###", "fr_FR")
        .format(paiement.montantAttendu)
        .replaceAll(',', ' ');

    // Formatage date échéance (ex: 2025-01-05)
    final formattedDate = DateFormat('yyyy-MM-dd').format(paiement.dateEcheance);

    return GestureDetector(
      onTap: () {
        // TODO: Naviguer vers le détail du paiement si besoin
        Navigator.pushNamed(context, '/detail_paiement', arguments: paiement);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Icône Calendrier Bleue
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: const Color(0xFF1E3A8A), // Bleu foncé type "Blueprint"
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(Icons.calendar_today_outlined,
                      color: Colors.white, size: 24),
                ),
                const SizedBox(width: 12),

                // Informations centrales (Mois + Statut)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paiement.periode, // ex: "Janvier 2025"
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        isPaid ? 'PAYER' : 'IMPAYER',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: isPaid ? Colors.green : Colors.red, // Vert ou Rouge
                        ),
                      ),
                    ],
                  ),
                ),

                // Montant à droite
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '$formattedMontant',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A), // Bleu foncé
                      ),
                    ),
                    const Text(
                      'Fcfa',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Ligne de séparation date échéance
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerLeft, // Aligné sous le titre comme sur l'image
              child: Padding(
                padding: const EdgeInsets.only(left: 60), // Décalage pour aligner sous le texte
                child: Text(
                  'Echeance :$formattedDate',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
