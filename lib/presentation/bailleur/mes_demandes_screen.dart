import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../widgets/demande_card.dart';
import '../../presentation/provider/DemandeProvider.dart';
 import 'detail_demande_screen.dart'; // On va le créer juste après

class MesDemandesScreen extends StatefulWidget {
  const MesDemandesScreen({Key? key}) : super(key: key);

  @override
  State<MesDemandesScreen> createState() => _MesDemandesScreenState();
}

class _MesDemandesScreenState extends State<MesDemandesScreen> {
  @override
  void initState() {
    super.initState();
    // Charge les données dès l'ouverture de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DemandeProvider>(context, listen: false).fetchDemandesBailleur();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA), // Gris très clair pour le fond
      appBar: AppBar(
        title: const Text("Mes Demandes"),
        backgroundColor: const Color(0xFF1E3A8A), // Bleu Luwaas
        elevation: 0,
      ),
      body: Consumer<DemandeProvider>(
        builder: (context, provider, child) {
          // 1. Chargement
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // 2. Erreur
          if (provider.errorMessage != null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, color: Colors.red, size: 50),
                  const SizedBox(height: 10),
                  Text(provider.errorMessage!),
                  TextButton(
                    onPressed: () => provider.fetchDemandesBailleur(),
                    child: const Text("Réessayer"),
                  )
                ],
              ),
            );
          }

          // 3. Liste vide
          if (provider.demandes.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.folder_open, size: 60, color: Colors.grey),
                  SizedBox(height: 10),
                  Text("Aucune demande pour le moment."),
                ],
              ),
            );
          }

          // 4. Affichage de la liste
          return RefreshIndicator(
            onRefresh: () => provider.fetchDemandesBailleur(),
            child: ListView.builder(
              itemCount: provider.demandes.length,
              itemBuilder: (context, index) {
                final demande = provider.demandes[index];
                return DemandeCard(
                  demande: demande,
                  onTap: () {
                    // Navigation vers le détail

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailDemandeScreen(demande: demande),
                      ),
                    );

                    print("Clic sur demande #${demande.id}");
                  },
                );
              },
            ),
          );
        },
      ),
    );
  }
}
