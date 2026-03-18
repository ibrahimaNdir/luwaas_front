import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/model/bails.dart';
import '../../data/model/paiements.dart';
import '../../presentation/provider/PaiementProvider.dart';

class PaymentHistoryScreen extends StatefulWidget {
  final Bail bail;

  const PaymentHistoryScreen({super.key, required this.bail});

  @override
  State<PaymentHistoryScreen> createState() => _PaymentHistoryScreenState();
}

class _PaymentHistoryScreenState extends State<PaymentHistoryScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<PaiementProvider>(context, listen: false)
          .fetchPaiements(widget.bail.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final paiementProvider = Provider.of<PaiementProvider>(context);

    final logement = widget.bail.logement ?? {};
    final numero = logement['numero'] ?? '';
    final titre = logement['titre'] ?? 'Logement';
    final displayTitle = numero.isNotEmpty ? numero : titre;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      appBar: AppBar(
        backgroundColor: const Color(0xFF1E3A8A),
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              displayTitle,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white,
              ),
            ),
            if (logement['titre'] != null && numero.isNotEmpty)
              Text(
                logement['titre'],
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.white60,
                  fontWeight: FontWeight.w400,
                ),
              ),
          ],
        ),
      ),
      body: Builder(
        builder: (_) {
          if (paiementProvider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(color: Color(0xFF1E3A8A)),
            );
          }

          if (paiementProvider.error != null) {
            return _buildErrorState(paiementProvider.error!);
          }

          final paiements = paiementProvider.paiements;

          if (paiements.isEmpty) {
            return _buildEmptyState();
          }

          // Séparer payés et impayés
          final unpaid = paiements
              .where((p) =>
          p.statut.toLowerCase() != 'paye' &&
              p.statut.toLowerCase() != 'payé')
              .toList();
          final paid = paiements
              .where((p) =>
          p.statut.toLowerCase() == 'paye' ||
              p.statut.toLowerCase() == 'payé')
              .toList();

          return ListView(
            padding: const EdgeInsets.only(bottom: 24),
            children: [
              // Barre de résumé
              _buildSummaryBar(paid, unpaid),

              // Section impayés
              if (unpaid.isNotEmpty) ...[
                _buildSectionLabel('À venir / En retard'),
                ...unpaid.map((p) => _buildPaymentCard(p)),
              ],

              // Section historique
              if (paid.isNotEmpty) ...[
                _buildSectionLabel('Historique'),
                ...paid.map((p) => _buildPaymentCard(p)),
              ],
            ],
          );
        },
      ),
    );
  }

  // ─── Barre de résumé ────────────────────────────────────────────────────────

  Widget _buildSummaryBar(List<Paiement> paid, List<Paiement> unpaid) {
    final totalPaid =
    paid.fold<double>(0, (sum, p) => sum + p.montantAttendu);
    final totalUnpaid =
    unpaid.fold<double>(0, (sum, p) => sum + p.montantAttendu);
    final total = totalPaid + totalUnpaid;
    final taux =
    total > 0 ? ((totalPaid / total) * 100).round() : 0;

    final fmt = NumberFormat("#,###", "fr_FR");

    return Container(
      color: const Color(0xFF1E3A8A),
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 20),
      child: Row(
        children: [
          _buildSumCard(
            label: 'Total payé',
            value: fmt.format(totalPaid).replaceAll(',', ' '),
            sub: 'FCFA · ${paid.length} mois',
          ),
          const SizedBox(width: 10),
          _buildSumCard(
            label: 'En attente',
            value: fmt.format(totalUnpaid).replaceAll(',', ' '),
            sub: 'FCFA · ${unpaid.length} impayé',
            highlight: unpaid.isNotEmpty,
          ),
          const SizedBox(width: 10),
          _buildSumCard(
            label: 'Taux',
            value: '$taux%',
            sub: 'Payés',
          ),
        ],
      ),
    );
  }

  Widget _buildSumCard({
    required String label,
    required String value,
    required String sub,
    bool highlight = false,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: highlight
              ? Colors.white.withOpacity(0.18)
              : Colors.white.withOpacity(0.10),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: Colors.white60,
                letterSpacing: 0.4,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 4),
            Text(
              value,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            Text(
              sub,
              style: const TextStyle(fontSize: 10, color: Colors.white54),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }

  // ─── Label de section ───────────────────────────────────────────────────────

  Widget _buildSectionLabel(String label) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 6),
      child: Text(
        label.toUpperCase(),
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: Color(0xFF64748B),
          letterSpacing: 0.6,
        ),
      ),
    );
  }

  // ─── Carte de paiement ──────────────────────────────────────────────────────

  Widget _buildPaymentCard(Paiement paiement) {
    final bool isPaid = paiement.statut.toLowerCase() == 'paye' ||
        paiement.statut.toLowerCase() == 'payé';

    final formattedMontant = NumberFormat("#,###", "fr_FR")
        .format(paiement.montantAttendu)
        .replaceAll(',', ' ');

    final formattedDate =
    DateFormat('dd MMM yyyy', 'fr_FR').format(paiement.dateEcheance);

    return GestureDetector(
      onTap: () {
        if (!isPaid) {
          Navigator.pushNamed(context, '/payment_process', arguments: paiement);
        }
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(isPaid ? 16 : 0),
            bottomLeft: Radius.circular(isPaid ? 16 : 0),
            topRight: const Radius.circular(16),
            bottomRight: const Radius.circular(16),
          ),
          border: !isPaid
              ? const Border(
            left: BorderSide(color: Color(0xFFF59E0B), width: 3),
          )
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icône
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: isPaid
                      ? const Color(0xFFDCFCE7)
                      : const Color(0xFFEEF2FF),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  isPaid
                      ? Icons.check_circle_outline_rounded
                      : Icons.calendar_today_outlined,
                  color: isPaid
                      ? const Color(0xFF16A34A)
                      : const Color(0xFF4338CA),
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),

              // Infos centrales
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      paiement.periode,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF1E293B),
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Row(
                      children: [
                        Icon(
                          Icons.access_time_rounded,
                          size: 12,
                          color: Colors.grey[500],
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            'Échéance : $formattedDate',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[500],
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    // Badge statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: isPaid
                            ? const Color(0xFFF0FDF4)
                            : const Color(0xFFFFFBEB),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isPaid
                                  ? const Color(0xFF16A34A)
                                  : const Color(0xFFF59E0B),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isPaid ? 'PAYÉ' : 'IMPAYÉ',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: isPaid
                                  ? const Color(0xFF15803D)
                                  : const Color(0xFFB45309),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 10),

              // Montant + bouton
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    formattedMontant,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const Text(
                    'FCFA',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                  if (!isPaid) ...[
                    const SizedBox(height: 6),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Text(
                        'Payer',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─── État vide ──────────────────────────────────────────────────────────────

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.receipt_long_outlined,
                size: 38,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun historique',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Aucun paiement trouvé pour ce logement.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // ─── État erreur ─────────────────────────────────────────────────────────────

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 60, color: Colors.red),
            const SizedBox(height: 16),
            const Text(
              'Erreur de chargement',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(error, textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<PaiementProvider>(context, listen: false)
                    .fetchPaiements(widget.bail.id);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}