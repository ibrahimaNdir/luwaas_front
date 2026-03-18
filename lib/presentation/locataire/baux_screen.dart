import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/model/bails.dart';
import '../../presentation/provider/BailProvider.dart';

class BauxScreen extends StatefulWidget {
  const BauxScreen({super.key});

  @override
  State<BauxScreen> createState() => _BauxScreenState();
}

class _BauxScreenState extends State<BauxScreen> {
  String _selectedFilter = "Tous";
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BailProvider>(context, listen: false).fetchBauxLocataire();
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
          children: [
            // Header
            _buildHeader(),

            // Barre de recherche
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: _buildSearchBar(),
            ),

            // Filtres
            Padding(
              padding: const EdgeInsets.only(left: 16, bottom: 16),
              child: _buildFilterChips(),
            ),

            // Liste des baux
            Expanded(
              child: Consumer<BailProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoadingBauxLocataire) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1E3A8A),
                      ),
                    );
                  }

                  if (provider.error != null) {
                    return _buildErrorState(provider.error!);
                  }

                  final baux = provider.bauxLocataire;

                  // Filtrage
                  final query = _searchController.text.toLowerCase();
                  final filtered = baux.where((bail) {
                    final logementTitre = (bail.logement?['titre'] ?? '').toString().toLowerCase();
                    final logementAdresse = (bail.logement?['adresse'] ?? '').toString().toLowerCase();
                    final matchSearch = logementTitre.contains(query) || logementAdresse.contains(query);

                    bool matchFilter = true;
                    if (_selectedFilter == "Actif") matchFilter = bail.statut == 'actif';
                    if (_selectedFilter == "En attente") matchFilter = bail.statut == 'en_attente_paiement';

                    return matchSearch && matchFilter;
                  }).toList();

                  if (filtered.isEmpty) {
                    return _buildEmptyState();
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      return _buildBailCard(filtered[index]);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // HEADER
  // ══════════════════════════════════════════════════════════
  Widget _buildHeader() {
    return Consumer<BailProvider>(
      builder: (context, provider, _) {
        final baux = provider.bauxLocataire;
        final actifs = baux.where((b) => b.statut == 'actif').length;

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
                      Text(
                        "Mes Baux",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Gérez vos locations",
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.description_outlined,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              // KPI
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
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildKpiChip(
      String value,
      String label,
      IconData icon,
      Color bg, {
        Color? textColor,
      }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(icon, color: textColor ?? Colors.white, size: 16),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: TextStyle(
                  color: textColor ?? Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  height: 1.1,
                ),
              ),
              Text(
                label,
                style: TextStyle(
                  color: (textColor ?? Colors.white).withOpacity(0.8),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // BARRE DE RECHERCHE
  // ══════════════════════════════════════════════════════════
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
          hintText: "Rechercher un logement...",
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
          prefixIcon: const Icon(
            Icons.search,
            color: Color(0xFF1E3A8A),
            size: 20,
          ),
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
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // FILTRES
  // ══════════════════════════════════════════════════════════
  Widget _buildFilterChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          _buildFilterChip("Tous"),
          const SizedBox(width: 8),
          _buildFilterChip("Actif"),
          const SizedBox(width: 8),
          _buildFilterChip("En attente"),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label) {
    final isSelected = _selectedFilter == label;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = label),
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
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════════════
  // CARTE BAIL
  // ══════════════════════════════════════════════════════════
  Widget _buildBailCard(Bail bail) {
    final logementTitre = bail.logement?['titre'] ?? 'Logement';
    final logementAdresse = bail.logement?['adresse'] ?? '';
    final dateDebut = DateFormat('dd MMM yyyy').format(bail.dateDebut);
    final dateFin = DateFormat('dd MMM yyyy').format(bail.dateFin);
    final fmt = NumberFormat('#,###', 'fr_FR');

    final isActif = bail.statut == 'actif';
    final isEnAttente = bail.statut == 'en_attente_paiement';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: isEnAttente
            ? Border.all(color: const Color(0xFFF59E0B).withOpacity(0.3))
            : null,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () {
            // Navigation vers DetailBailScreen
            Navigator.pushNamed(
              context,
              '/detail_bail_locataire',
              arguments: bail,
            );
          },
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header : Logement + Badge statut
                Row(
                  children: [

                Container(
                width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2155FF).withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      'assets/icons/house_welcome.svg',
                      width: 24,
                      height: 24,
                      color: const Color(0xFF1E3A8A), // équivalent du color de Icon
                    ),
                  ),
                ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            logementTitre,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: Color(0xFF1E293B),
                            ),
                          ),
                          const SizedBox(height: 2),
                          if (logementAdresse.isNotEmpty)
                            Row(
                              children: [
                                const Icon(Icons.location_on_outlined, size: 13, color: Colors.grey),
                                const SizedBox(width: 4),
                                Expanded(
                                  child: Text(
                                    logementAdresse,
                                    style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: isActif
                            ? const Color(0xFF22C55E).withOpacity(0.1)
                            : isEnAttente
                            ? const Color(0xFFF59E0B).withOpacity(0.1)
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
                              color: isActif
                                  ? const Color(0xFF22C55E)
                                  : isEnAttente
                                  ? const Color(0xFFF59E0B)
                                  : Colors.grey,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isActif
                                ? "Actif"
                                : isEnAttente
                                ? "En attente"
                                : "Inactif",
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isActif
                                  ? const Color(0xFF16A34A)
                                  : isEnAttente
                                  ? const Color(0xFFD97706)
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

                // Infos financières et dates
                Row(
                  children: [
                    Expanded(
                      child: _buildInfoCell(
                        icon: Icons.account_balance_wallet_outlined,
                        iconColor: const Color(0xFF1E3A8A),
                        label: "Loyer mensuel",
                        value: "${fmt.format(bail.montantLoyer)} FCFA",
                        valueBold: true,
                      ),
                    ),
                    Container(width: 1, height: 36, color: const Color(0xFFF1F5F9)),
                    Expanded(
                      child: _buildInfoCell(
                        icon: Icons.calendar_today_outlined,
                        iconColor: const Color(0xFFF59E0B),
                        label: "Période",
                        value: "$dateDebut\nau $dateFin",
                        align: CrossAxisAlignment.end,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(Icons.chevron_right, color: Color(0xFF1E3A8A), size: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCell({
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
            Text(label, style: const TextStyle(color: Colors.grey, fontSize: 11)),
          ],
        ),
        const SizedBox(height: 3),
        Text(
          value,
          textAlign: align == CrossAxisAlignment.end ? TextAlign.end : TextAlign.start,
          style: TextStyle(
            fontWeight: valueBold ? FontWeight.bold : FontWeight.w600,
            fontSize: 13,
            color: const Color(0xFF1E293B),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════════════════
  // ÉTATS VIDES/ERREUR
  // ══════════════════════════════════════════════════════════
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
              child: const Icon(
                Icons.inbox_outlined,
                size: 40,
                color: Color(0xFF1E3A8A),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              "Aucun bail trouvé",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Vous n'avez pas encore de bail actif.",
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey[500], fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

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
              "Erreur de chargement",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Provider.of<BailProvider>(context, listen: false).fetchBauxLocataire();
              },
              icon: const Icon(Icons.refresh),
              label: const Text("Réessayer"),
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