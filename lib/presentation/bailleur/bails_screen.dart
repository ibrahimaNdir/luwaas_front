import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/model/bails.dart';
import '../../presentation/provider/BailProvider.dart';
import 'details_bails_screen.dart';
import 'add_bails_screen.dart';

// ============================================================
// ÉCRAN PRINCIPAL
// ============================================================
class BailScreen extends StatefulWidget {
  const BailScreen({super.key});

  @override
  State<BailScreen> createState() => _BailScreenState();
}

class _BailScreenState extends State<BailScreen> {
  String _filter = "Tous";
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // ✅ FIX : Plus de Future.delayed — pas de risque de crash contexte invalide
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BailProvider>(context, listen: false).fetchBauxBailleur();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF0F4FF),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── HEADER FIXE ──────────────────────────────────
            _buildHeader(),

            // ── BARRE DE RECHERCHE ────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildSearchBar(),
            ),

            // ── FILTRES ───────────────────────────────────────
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: _buildFilterChips(),
            ),

            // ── LISTE ─────────────────────────────────────────
            Expanded(
              child: Consumer<BailProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoadingBauxBailleur) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E3A8A),
                      ),
                    );
                  }

                  final query = _searchController.text.toLowerCase();

                  // ✅ FIX : on cherche sur prenom + nom (pas 'name')
                  final filtered = provider.bauxBailleur.where((bail) {
                    final nom =
                    "${bail.locataire?['prenom'] ?? ''} ${bail.locataire?['nom'] ?? ''}"
                        .toLowerCase();
                    final logement =
                    (bail.logement?['titre'] ?? '').toString().toLowerCase();
                    final matchSearch =
                        nom.contains(query) || logement.contains(query);

                    bool matchFilter = true;
                    if (_filter == "Actif") matchFilter = bail.statut == 'actif';
                    if (_filter == "En retard")
                      matchFilter = bail.statut == 'en_retard';

                    return matchSearch && matchFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (_, i) => BailCard(
                      bail: filtered[i],
                      onTap: () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => DetailBailScreen(bail: filtered[i]),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      // ── FAB AJOUTER ────────────────────────────────────────
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          // ✅ NAVIGATION VERS FormulaireBailScreen (PARCOURS 2)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const FormulaireBailScreen(),
            ),
          );
        },
        backgroundColor: const Color(0xFF1E3A8A),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          "Nouveau bail",
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
        elevation: 4,
      ),
    );
  }

  // ── HEADER avec KPI ──────────────────────────────────────────
  Widget _buildHeader() {
    return Consumer<BailProvider>(
      builder: (context, provider, _) {
        final baux = provider.bauxBailleur;
        final actifs = baux.where((b) => b.statut == 'actif').length;
        final retards = baux.where((b) => b.statut == 'en_retard').length;
        final totalLoyer = baux.fold<int>(0, (sum, b) => sum + b.montantLoyer);
        final fmt = NumberFormat('#,###', 'fr_FR');

        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Bonjour 👋",
                          style:
                          TextStyle(color: Colors.white70, fontSize: 13)),
                      SizedBox(height: 2),
                      Text("Mes Baux",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.notifications_outlined,
                        color: Colors.white, size: 22),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              // KPI Row
              Row(
                children: [
                  _buildKpiChip(
                    "${baux.length}",
                    "Total",
                    Icons.receipt_long_outlined,
                    Colors.white.withOpacity(0.15),
                  ),
                  const SizedBox(width: 10),
                  _buildKpiChip(
                    "$actifs",
                    "Actifs",
                    Icons.check_circle_outline,
                    const Color(0xFF22C55E).withOpacity(0.25),
                    textColor: const Color(0xFF86EFAC),
                  ),
                  const SizedBox(width: 10),
                  if (retards > 0)
                    _buildKpiChip(
                      "$retards",
                      "Retard",
                      Icons.warning_amber_outlined,
                      const Color(0xFFEF4444).withOpacity(0.25),
                      textColor: const Color(0xFFFCA5A5),
                    ),
                  if (retards == 0) const Spacer(),
                  const Spacer(),
                  // Total loyer (right-aligned)
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      const Text("Loyer mensuel total",
                          style:
                          TextStyle(color: Colors.white60, fontSize: 11)),
                      const SizedBox(height: 2),
                      Text("${fmt.format(totalLoyer)} F",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiChip(String value, String label, IconData icon, Color bg,
      {Color? textColor}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor ?? Colors.white, size: 15),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value,
                  style: TextStyle(
                      color: textColor ?? Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      height: 1.1)),
              Text(label,
                  style: TextStyle(
                      color: (textColor ?? Colors.white).withOpacity(0.8),
                      fontSize: 10)),
            ],
          ),
        ],
      ),
    );
  }

  // ── BARRE DE RECHERCHE ───────────────────────────────────────
  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextField(
        controller: _searchController,
        onChanged: (_) => setState(() {}),
        decoration: InputDecoration(
          hintText: "Rechercher un locataire ou logement…",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(Icons.search, color: Color(0xFF1E3A8A), size: 20),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
            icon: const Icon(Icons.clear, size: 18, color: Colors.grey),
            onPressed: () {
              _searchController.clear();
              setState(() {});
            },
          )
              : null,
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  // ── FILTRES ──────────────────────────────────────────────────
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _chip("Tous"),
          const SizedBox(width: 8),
          _chip("Actif"),
          const SizedBox(width: 8),
          _chip("En retard"),
        ],
      ),
    );
  }

  Widget _chip(String label) {
    final isSelected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: isSelected
              ? [
            BoxShadow(
              color: const Color(0xFF1E3A8A).withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ]
              : [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey[600],
            fontWeight:
            isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── EMPTY STATE ──────────────────────────────────────────────
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
                borderRadius: BorderRadius.circular(20),
              ),
              child: const Icon(Icons.inbox_outlined,
                  size: 40, color: Color(0xFF1E3A8A)),
            ),
            const SizedBox(height: 16),
            const Text(
              "Aucun bail trouvé",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B)),
            ),
            const SizedBox(height: 8),
            Text(
              "Essayez de modifier vos filtres\nou ajoutez votre premier bail.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
            const SizedBox(height: 24),
            OutlinedButton.icon(
              onPressed: () {
                setState(() {
                  _filter = "Tous";
                  _searchController.clear();
                });
              },
              icon: const Icon(Icons.refresh, size: 18),
              label: const Text("Réinitialiser les filtres"),
              style: OutlinedButton.styleFrom(
                foregroundColor: const Color(0xFF1E3A8A),
                side: const BorderSide(color: Color(0xFF1E3A8A)),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10)),
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CARTE BAIL
// ============================================================
class BailCard extends StatelessWidget {
  final Bail bail;
  final VoidCallback onTap;

  const BailCard({Key? key, required this.bail, required this.onTap})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locataireName =
    "${bail.locataire?['prenom'] ?? ''} ${bail.locataire?['nom'] ?? ''}"
        .trim();
    final initials = _initials(locataireName);
    final logementTitre = bail.logement?['titre'] ?? 'Logement';
    final logementAdresse = bail.logement?['adresse'] ?? '';
    final dateFin = DateFormat('dd MMM yyyy').format(bail.dateFin);
    final fmt = NumberFormat('#,###', 'fr_FR');

    final isRetard = bail.statut == 'en_retard';
    final isActif = bail.statut == 'actif';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isRetard
            ? Border.all(color: const Color(0xFFEF4444).withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      // ✅ FIX : InkWell sur toute la carte, pas de bouton dupliqué
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── ROW 1 : Locataire + Statut ──────────────
                Row(
                  children: [
                    // Avatar initiales
                    Container(
                      width: 46,
                      height: 46,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E3A8A).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(initials,
                            style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            locataireName.isEmpty
                                ? "Locataire inconnu"
                                : locataireName,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 15,
                                color: Color(0xFF1E293B)),
                          ),
                          const SizedBox(height: 2),
                          Row(
                            children: [
                              const Icon(Icons.home_outlined,
                                  size: 13, color: Colors.grey),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  logementAdresse.isNotEmpty
                                      ? "$logementTitre · $logementAdresse"
                                      : logementTitre,
                                  style: const TextStyle(
                                      color: Colors.grey, fontSize: 12),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Badge statut
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isRetard
                            ? const Color(0xFFEF4444).withOpacity(0.1)
                            : isActif
                            ? const Color(0xFF22C55E).withOpacity(0.1)
                            : Colors.grey.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 6,
                            height: 6,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: isRetard
                                  ? const Color(0xFFEF4444)
                                  : isActif
                                  ? const Color(0xFF22C55E)
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isRetard
                                ? "Retard"
                                : isActif
                                ? "À jour"
                                : "Inactif",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isRetard
                                  ? const Color(0xFFDC2626)
                                  : isActif
                                  ? const Color(0xFF16A34A)
                                  : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 14),
                const Divider(height: 1, color: Color(0xFFF1F5F9)),
                const SizedBox(height: 14),

                // ── ROW 2 : Loyer + Fin de bail + Flèche ────
                Row(
                  children: [
                    Expanded(
                      child: _infoCell(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: const Color(0xFF1E3A8A),
                        label: "Loyer mensuel",
                        value: "${fmt.format(bail.montantLoyer)} F",
                        valueBold: true,
                      ),
                    ),
                    Container(
                        width: 1, height: 36, color: const Color(0xFFF1F5F9)),
                    Expanded(
                      child: _infoCell(
                        icon: Icons.event_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        label: "Fin du bail",
                        value: dateFin,
                        align: CrossAxisAlignment.end,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right,
                        color: Color(0xFF1E3A8A), size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _infoCell({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    bool valueBold = false,
    CrossAxisAlignment align = CrossAxisAlignment.start,
  }) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Row(
          mainAxisAlignment: align == CrossAxisAlignment.end
              ? MainAxisAlignment.end
              : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 13, color: iconColor),
            const SizedBox(width: 4),
            Text(label,
                style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: TextStyle(
            fontWeight:
            valueBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 14,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  String _initials(String name) {
    if (name.isEmpty) return "?";
    final parts = name.trim().split(" ");
    if (parts.length >= 2) {
      return "${parts[0][0]}${parts[1][0]}".toUpperCase();
    }
    return name[0].toUpperCase();
  }
}