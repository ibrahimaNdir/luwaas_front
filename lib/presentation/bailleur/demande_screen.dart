import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/provider/DemandeProvider.dart'; // Vérifie le chemin
import '../../data/model/demande.dart'; // Vérifie le chemin
import '';
import '../../widgets/demande_card.dart';
import 'detail_demande_screen.dart'; // Importe ton fichier DemandeCard qu'on a vu juste avant !
 import 'detail_demande_screen.dart'; // À créer plus tard pour voir les détails/accepter

class DemandeScreen extends StatefulWidget {
  const DemandeScreen({super.key});

  @override
  State<DemandeScreen> createState() => _DemandeScreenState();
}

class _DemandeScreenState extends State<DemandeScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les demandes dès l'ouverture de l'écran
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<DemandeProvider>(context, listen: false).fetchDemandesBailleur();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100], // Fond gris clair pour faire ressortir les cartes blanches
      appBar: AppBar(
        title: const Text(
          "Demandes reçues",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        actions: [
          // Bouton rafraîchir
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              Provider.of<DemandeProvider>(context, listen: false).fetchDemandesBailleur();
            },
          ),
        ],
      ),
      body: Consumer<DemandeProvider>(
        builder: (context, provider, child) {
          // 1. Chargement
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
          }

          // 2. Erreur
          if (provider.errorMessage != null) { // ou provider.error selon ton provider
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 50, color: Colors.red),
                  const SizedBox(height: 10),
                  Text(provider.errorMessage!, style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: provider.fetchDemandesBailleur,
                    child: const Text("Réessayer"),
                  )
                ],
              ),
            );
          }

          // 3. Liste vide
          if (provider.demandes.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.inbox_outlined, size: 80, color: Colors.grey[400]),
                  const SizedBox(height: 15),
                  Text(
                    "Aucune demande pour l'instant",
                    style: TextStyle(color: Colors.grey[600], fontSize: 16),
                  ),
                ],
              ),
            );
          }

          // 4. Liste pleine (Affichage des cartes)
          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 10),
            itemCount: provider.demandes.length,
            itemBuilder: (context, index) {
              final demande = provider.demandes[index];
              return DemandeCard(
                demande: demande,
                onTap: () {
                  // Navigation vers le détail pour Accepter/Refuser
                   Navigator.push(context, MaterialPageRoute(builder: (_) => DetailDemandeScreen(demande: demande)));

                },
              );
            },
          );
        },
      ),
    );
  }
}
