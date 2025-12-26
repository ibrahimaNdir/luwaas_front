import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/bails.dart'; // ✅ CHANGÉ : On importe le modèle unifié
import '../../presentation/provider/BailProvider.dart';

class SelectLogementScreen extends StatefulWidget {
  const SelectLogementScreen({super.key});

  @override
  State<SelectLogementScreen> createState() => _SelectLogementScreenState();
}

class _SelectLogementScreenState extends State<SelectLogementScreen> {
  @override
  void initState() {
    super.initState();
    Future.microtask(() {
      Provider.of<BailProvider>(context, listen: false).fetchBauxLocataire();
    });
  }

  @override
  Widget build(BuildContext context) {
    final bailProvider = Provider.of<BailProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payer Loyer', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      backgroundColor: const Color(0xFFF4F4F6),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Builder(
          builder: (_) {
            if (bailProvider.isLoadingBauxLocataire) {
              return const Center(child: CircularProgressIndicator());
            }

            if (bailProvider.error != null) {
              return Center(child: Text(bailProvider.error!, style: const TextStyle(color: Colors.red)));
            }

            // ✅ CHANGÉ : On récupère une liste de 'Bail'
            final List<Bail> baux = bailProvider.bauxLocataire;

            if (baux.isEmpty) {
              return const Center(child: Text("Aucun bail trouvé."));
            }

            return ListView.separated(
              itemCount: baux.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final bail = baux[index];

                // ⚠️ IMPORTANT : Récupération des données du logement imbriqué
                // Assure-toi que ton Bail.fromJson gère bien l'objet 'logement'
                final logementData = bail.logement ?? {}; // Map<String, dynamic>

                final String numero = logementData['numero'] ?? 'Sans numéro';
                final String adresse = logementData['adresse'] ?? 'Adresse inconnue';
                final double surface = double.tryParse(logementData['surface'].toString()) ?? 0.0;

                // Si ton JSON renvoie 'superficie' au lieu de 'surface', adapte la ligne ci-dessus.

                return GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/payment_detail', arguments: bail);
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.03),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    child: Row(
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            color: const Color(0xFF2155FF).withOpacity(0.08),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(Icons.home_rounded, color: Color(0xFF2155FF)),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                numero, // ✅ Variable locale extraite
                                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  const Icon(Icons.apartment_rounded, size: 16, color: Colors.grey),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      adresse, // ✅ Variable locale extraite
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Row(
                                children: [
                                  Container(
                                    width: 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: bail.statut == 'actif' ? Colors.green : Colors.orange,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  Text(
                                    '${_formatStatut(bail.statut)} · ${surface.toStringAsFixed(0)}m²', // ✅ Surface extraite
                                    style: const TextStyle(fontSize: 13, color: Colors.grey),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  String _formatStatut(String statut) {
    switch (statut) {
      case 'actif': return 'Actif';
      case 'en_retard': return 'En retard';
      default: return statut;
    }
  }
}
