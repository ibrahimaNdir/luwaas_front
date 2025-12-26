import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/model/bails.dart';
import '../../presentation/provider/BailProvider.dart';
import 'details_bails_screen.dart';

// ==========================================
// 1. L'ÉCRAN PRINCIPAL (Ccelui que tu appelles dans le MainScreen)
// ==========================================
class BailScreen extends StatefulWidget {
  const BailScreen({super.key});

  @override
  State<BailScreen> createState() => _BailScreenState();
}

class _BailScreenState extends State<BailScreen> {
  String _filter = "Tous";
  String _searchQuery = "";

  @override
  void initState() {
    super.initState();
    // Charger les baux au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<BailProvider>(context, listen: false).fetchBauxBailleur();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          "Mes Baux",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 24),
        ),
        centerTitle: false,
        automaticallyImplyLeading: false, // Enlève la flèche retour si besoin
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        child: Column(
          children: [
            // Barre de recherche
            Container(
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: TextField(
                onChanged: (val) => setState(() => _searchQuery = val),
                decoration: const InputDecoration(
                  hintText: "Rechercher",
                  prefixIcon: Icon(Icons.search, color: Colors.black54),
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),

            const SizedBox(height: 16),

            // Filtres
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _buildFilterChip("Tous"),
                  const SizedBox(width: 10),
                  _buildFilterChip("Actif"),
                  const SizedBox(width: 10),
                  _buildFilterChip("En retard"),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Liste
            Expanded(
              child: Consumer<BailProvider>(
                builder: (context, provider, child) {
                  if (provider.isLoadingBauxBailleur) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  // Filtrage
                  final filteredList = provider.bauxBailleur.where((bail) {
                    final name = (bail.locataire?['name'] ?? '').toString().toLowerCase();
                    final matchSearch = name.contains(_searchQuery.toLowerCase());

                    bool matchFilter = true;
                    if (_filter == "Actif") matchFilter = bail.statut == 'actif';
                    if (_filter == "En retard") matchFilter = bail.statut == 'en_retard';

                    return matchSearch && matchFilter;
                  }).toList();

                  if (filteredList.isEmpty) {
                    return const Center(child: Text("Aucun bail trouvé."));
                  }

                  return ListView.builder(
                    itemCount: filteredList.length,
                    itemBuilder: (context, index) {
                      final bail = filteredList[index];
                      // On utilise ici la classe BailCard définie plus bas
                      return BailCard(
                        bail: bail,
                        onTap: () {
                          // Navigation vers le détail
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => DetailBailScreen(bail: bail), // On passe l'objet bail
                            ),
                          );
                        },
                      );
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

  Widget _buildFilterChip(String label) {
    final isSelected = _filter == label;
    return GestureDetector(
      onTap: () => setState(() => _filter = label),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3A8A) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: const Color(0xFF1E3A8A)),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : const Color(0xFF1E3A8A),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ==========================================
// 2. LE WIDGET CARTE (Celui que tu avais collé)
// ==========================================
class BailCard extends StatelessWidget {
  final Bail bail;
  final VoidCallback onTap;

  const BailCard({
    Key? key,
    required this.bail,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final locataireName = bail.locataire?['name'] ?? 'Nom Inconnu';
    final logementTitre = bail.logement?['titre'] ?? 'Logement';
    final loyer = bail.montantLoyer;
    final dateFin = DateFormat('dd MMM yyyy').format(bail.dateFin);

    // Logique Statut
    bool isRetard = bail.statut == 'en_retard';
    Color statusBgColor = isRetard ? Colors.red.withOpacity(0.2) : Colors.green.withOpacity(0.2);
    Color statusTextColor = isRetard ? Colors.red : Colors.green;
    String statusText = isRetard ? "Retard" : "A jour"; // Texte court pour le design

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
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
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(locataireName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: statusBgColor, borderRadius: BorderRadius.circular(8)),
                child: Text(statusText, style: TextStyle(color: statusTextColor, fontWeight: FontWeight.bold, fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          // Logement
          Row(
            children: [
              const Icon(Icons.home_outlined, size: 20, color: Color(0xFF1E3A8A)),
              const SizedBox(width: 8),
              Expanded(child: Text(logementTitre, style: const TextStyle(color: Colors.black87), overflow: TextOverflow.ellipsis)),
            ],
          ),
          const SizedBox(height: 16),
          // Footer
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Loyer Mensuel", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text("$loyer FCFA", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text("Fin du Bail", style: TextStyle(color: Colors.grey[600], fontSize: 12)),
                  Text(dateFin, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Bouton
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onTap,
              icon: const Icon(Icons.description_outlined, color: Colors.white, size: 18),
              label: const Text("Voir Bail", style: TextStyle(color: Colors.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
