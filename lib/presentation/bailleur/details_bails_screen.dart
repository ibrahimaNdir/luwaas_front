import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../data/model/bails.dart';

class DetailBailScreen extends StatelessWidget {
  final Bail bail;

  const DetailBailScreen({Key? key, required this.bail}) : super(key: key);

  void _printBail(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Row(
          children: [
            Icon(Icons.check_circle_outline, color: Colors.white),
            SizedBox(width: 10),
            Text("Génération du contrat en cours…"),
          ],
        ),
        backgroundColor: const Color(0xFF1E3A8A),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final locataireName =
    "${bail.locataire?['prenom'] ?? ''} ${bail.locataire?['nom'] ?? ''}"
        .trim();
    final locatairePhone = bail.locataire?['telephone'] ?? 'Non renseigné';
    final locataireInitials = _getInitials(locataireName);
    final logementTitre = bail.logement?['titre'] ?? 'Logement';
    final logementAdresse = bail.logement?['adresse'] ?? '';
    final logementNumero = bail.logement?['numero'] ?? '';
    final logementType = bail.logement?['type'] ?? '';
    final dateFormat = DateFormat('dd MMM yyyy');
    final isActif = bail.statut == 'actif';
    final totalMensuel = bail.montantLoyer + bail.chargesMensuelles;

    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: CustomScrollView(
        slivers: [
          // ── HERO HEADER ──────────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: const Color(0xFF1E3A8A),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new,
                  color: Colors.white, size: 20),
              onPressed: () => Navigator.of(context).pop(),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.more_vert, color: Colors.white),
                onPressed: () {},
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _buildHeroBackground(
                context,
                isActif: isActif,
                bailId: bail.id,
                locataireName: locataireName,
                locataireInitials: locataireInitials,
                logementTitre: logementTitre,
                logementAdresse: logementAdresse,
              ),
            ),
          ),

          // ── BODY ─────────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ── MONTANT PRINCIPAL (Financial KPI) ──────────────
                  _buildFinancialKpi(
                    totalMensuel: totalMensuel,
                    loyer: bail.montantLoyer,
                    charges: bail.chargesMensuelles,
                    caution: bail.caution,
                  ),

                  const SizedBox(height: 24),

                  // ── PARTIES ────────────────────────────────────────
                  _buildSectionTitle("Les Parties"),
                  const SizedBox(height: 10),
                  _buildPartiesCard(
                    locataireName: locataireName,
                    locatairePhone: locatairePhone,
                    locataireInitials: locataireInitials,
                    logementNumero: logementNumero,
                    logementType: logementType,
                  ),

                  const SizedBox(height: 24),

                  // ── DURÉE & DATES ──────────────────────────────────
                  _buildSectionTitle("Durée & Échéance"),
                  const SizedBox(height: 10),
                  _buildDatesCard(
                    dateFormat: dateFormat,
                    dateDebut: bail.dateDebut,
                    dateFin: bail.dateFin,
                    jourEcheance: bail.jourEcheance,
                    renouvellement: bail.renouvellementAutomatique,
                  ),

                  const SizedBox(height: 36),

                  // ── CTA PRINCIPAL ──────────────────────────────────
                  _buildPrintButton(context),

                  const SizedBox(height: 16),

                  // ── RÉSILIER ───────────────────────────────────────
                  Center(
                    child: TextButton.icon(
                      onPressed: () => _showResiliationDialog(context),
                      icon: const Icon(Icons.cancel_outlined,
                          color: Color(0xFFDC2626), size: 18),
                      label: const Text(
                        "Résilier ce bail",
                        style: TextStyle(
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── HERO BACKGROUND ──────────────────────────────────────────────────
  Widget _buildHeroBackground(
      BuildContext context, {
        required bool isActif,
        required int bailId,
        required String locataireName,
        required String locataireInitials,
        required String logementTitre,
        required String logementAdresse,
      }) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
        ),
      ),
      child: Stack(
        children: [
          // Cercle décoratif subtil
          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 180,
              height: 180,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),
          Positioned(
            bottom: 10,
            left: -30,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.04),
              ),
            ),
          ),
          // Contenu du header
          Padding(
            padding:
            const EdgeInsets.fromLTRB(20, 80, 20, 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Bail #${bailId.toString().padLeft(4, '0')}",
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            letterSpacing: 1.5,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          logementTitre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (logementAdresse.isNotEmpty)
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined,
                                  color: Colors.white60, size: 13),
                              const SizedBox(width: 4),
                              Text(
                                logementAdresse,
                                style: const TextStyle(
                                    color: Colors.white60, fontSize: 12),
                              ),
                            ],
                          ),
                      ],
                    ),
                    // Badge statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isActif
                            ? const Color(0xFF22C55E).withOpacity(0.2)
                            : const Color(0xFFEF4444).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: isActif
                              ? const Color(0xFF22C55E)
                              : const Color(0xFFEF4444),
                          width: 1,
                        ),
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 7,
                            height: 7,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isActif
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            isActif ? "Actif" : "Inactif",
                            style: TextStyle(
                              color: isActif
                                  ? const Color(0xFF22C55E)
                                  : const Color(0xFFEF4444),
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── FINANCIAL KPI CARD ───────────────────────────────────────────────
  Widget _buildFinancialKpi({
    required int totalMensuel,
    required int loyer,
    required int charges,
    required int caution,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E3A8A), Color(0xFF3B5FC0)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3A8A).withOpacity(0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          // Total mensuel
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Total mensuel",
                      style: TextStyle(color: Colors.white60, fontSize: 13)),
                  SizedBox(height: 4),
                ],
              ),
              const Icon(Icons.account_balance_wallet_outlined,
                  color: Colors.white30, size: 28),
            ],
          ),
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "${_formatAmount(totalMensuel)} FCFA",
              style: const TextStyle(
                color: Colors.white,
                fontSize: 32,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ),
          const SizedBox(height: 20),
          // Détail loyer / charges / caution
          Row(
            children: [
              Expanded(
                  child: _buildKpiItem(
                      "Loyer", "${_formatAmount(loyer)} F", Icons.home_outlined)),
              _buildDivider(),
              Expanded(
                  child: _buildKpiItem("Charges",
                      "${_formatAmount(charges)} F", Icons.bolt_outlined)),
              _buildDivider(),
              Expanded(
                  child: _buildKpiItem("Caution",
                      "${_formatAmount(caution)} F", Icons.shield_outlined)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKpiItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white54, size: 18),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13)),
        Text(label,
            style: const TextStyle(color: Colors.white54, fontSize: 11)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
        height: 40,
        width: 1,
        color: Colors.white.withOpacity(0.15));
  }

  // ── PARTIES CARD ──────────────────────────────────────────────────────
  Widget _buildPartiesCard({
    required String locataireName,
    required String locatairePhone,
    required String locataireInitials,
    required String logementNumero,
    required String logementType,
  }) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Bailleur
          _buildPartyRow(
            avatar: _buildAvatar("V", const Color(0xFF1E3A8A)),
            title: "Bailleur",
            name: "Vous",
            sub: "Propriétaire",
          ),
          _buildCardDivider(),
          // Locataire
          _buildPartyRow(
            avatar: _buildAvatar(
                locataireInitials, const Color(0xFF0891B2)),
            title: "Locataire",
            name: locataireName.isEmpty ? "Non renseigné" : locataireName,
            sub: locatairePhone,
            trailing: _buildCallButton(locatairePhone),
          ),
          _buildCardDivider(),
          // Logement
          _buildInfoRow(
            icon: Icons.meeting_room_outlined,
            iconColor: const Color(0xFF7C3AED),
            label: "Logement",
            value: logementNumero.isEmpty ? "—" : logementNumero,
            sub: logementType,
          ),
        ],
      ),
    );
  }

  // ── DATES CARD ────────────────────────────────────────────────────────
  Widget _buildDatesCard({
    required DateFormat dateFormat,
    required DateTime dateDebut,
    required DateTime dateFin,
    required int jourEcheance,
    required bool renouvellement,
  }) {
    return Container(
      decoration: _cardDecoration(),
      padding: const EdgeInsets.all(18),
      child: Column(
        children: [
          // Timeline visuelle
          _buildDateTimeline(dateFormat, dateDebut, dateFin),
          _buildCardDivider(),
          _buildInfoRow(
            icon: Icons.calendar_month_outlined,
            iconColor: const Color(0xFFF59E0B),
            label: "Jour de paiement",
            value: "Le $jourEcheance du mois",
          ),
          _buildCardDivider(),
          _buildInfoRow(
            icon: renouvellement
                ? Icons.autorenew
                : Icons.touch_app_outlined,
            iconColor: renouvellement
                ? const Color(0xFF22C55E)
                : const Color(0xFF6B7280),
            label: "Renouvellement",
            value: renouvellement ? "Tacite reconduction" : "Manuel",
            valueColor: renouvellement
                ? const Color(0xFF22C55E)
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildDateTimeline(
      DateFormat fmt, DateTime debut, DateTime fin) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          // Date de début
          Expanded(
            child: Column(
              children: [
                const Text("Début",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(fmt.format(debut),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
          // Ligne centrale
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    Expanded(
                      child: Container(
                          height: 2,
                          decoration: const BoxDecoration(
                            gradient: LinearGradient(colors: [
                              Color(0xFF1E3A8A),
                              Color(0xFF2563EB)
                            ]),
                          )),
                    ),
                    const Icon(Icons.arrow_forward_ios,
                        size: 10, color: Color(0xFF2563EB)),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _durationLabel(debut, fin),
                  style: const TextStyle(
                      color: Color(0xFF2563EB),
                      fontSize: 11,
                      fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          // Date de fin
          Expanded(
            child: Column(
              children: [
                const Text("Fin",
                    style: TextStyle(color: Colors.grey, fontSize: 12)),
                const SizedBox(height: 4),
                Text(fmt.format(fin),
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── CTA BOUTON IMPRIMER ───────────────────────────────────────────────
  Widget _buildPrintButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton.icon(
        onPressed: () => _printBail(context),
        icon: const Icon(Icons.file_download_outlined, color: Colors.white, size: 22),
        label: const Text(
          "Télécharger le Contrat",
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.3,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 4,
          shadowColor: const Color(0xFF1E3A8A).withOpacity(0.4),
        ),
      ),
    );
  }

  // ── DIALOG RÉSILIATION ────────────────────────────────────────────────
  void _showResiliationDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text("Résilier le bail ?"),
        content: const Text(
            "Cette action est irréversible. Le bail sera marqué comme résilié."),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Annuler")),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFDC2626)),
            child: const Text("Résilier",
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // ── WIDGETS HELPER ────────────────────────────────────────────────────

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 2),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.bold,
          color: Color(0xFF1E293B),
        ),
      ),
    );
  }

  Widget _buildPartyRow({
    required Widget avatar,
    required String title,
    required String name,
    required String sub,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          avatar,
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(name,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 15)),
                Text(sub,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
          if (trailing != null) trailing,
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    String? sub,
    Color? valueColor,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label,
                    style: const TextStyle(color: Colors.grey, fontSize: 12)),
                Text(value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: valueColor ?? const Color(0xFF1E293B),
                    )),
                if (sub != null && sub.isNotEmpty)
                  Text(sub,
                      style: const TextStyle(
                          color: Colors.grey, fontSize: 12)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCardDivider() =>
      const Divider(height: 1, thickness: 1, color: Color(0xFFF1F5F9));

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.06),
          blurRadius: 16,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  Widget _buildAvatar(String initials, Color color) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Center(
        child: Text(initials,
            style: TextStyle(
                color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  Widget _buildCallButton(String phone) {
    if (phone == 'Non renseigné') return const SizedBox();
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF0891B2).withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.phone_outlined, color: Color(0xFF0891B2), size: 14),
          SizedBox(width: 4),
          Text("Appeler",
              style:
              TextStyle(color: Color(0xFF0891B2), fontSize: 12)),
        ],
      ),
    );
  }

  // ── UTILITAIRES ────────────────────────────────────────────────────────
  String _getInitials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }

  String _formatAmount(int amount) {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return formatter.format(amount);
  }

  String _durationLabel(DateTime debut, DateTime fin) {
    final months = (fin.year - debut.year) * 12 + (fin.month - debut.month);
    if (months < 12) return "$months mois";
    final years = months ~/ 12;
    final rem = months % 12;
    return rem == 0 ? "$years an${years > 1 ? 's' : ''}" : "$years a $rem m";
  }
}