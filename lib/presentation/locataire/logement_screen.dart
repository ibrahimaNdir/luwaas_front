import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../../data/model/logements.dart';
import '../../presentation/provider/LogementProvider.dart';
// import 'logement_detail_screen.dart'; // Écran de destination

class LogementsScreen extends StatefulWidget {
  const LogementsScreen({super.key});

  @override
  State<LogementsScreen> createState() => _LogementsScreenState();
}

class _LogementsScreenState extends State<LogementsScreen> {
  @override
  void initState() {
    super.initState();
    // Charger les données au démarrage de l'écran
    Future.microtask(() {
      Provider.of<LogementProvider>(context, listen: false).loadLogementsLocataire();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mes Logements",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
      ),
      backgroundColor: const Color(0xFFF4F6F9), // Fond légèrement gris
      body: Consumer<LogementProvider>(
        builder: (context, provider, child) {
          // --- Cas 1: Chargement ---
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // --- Cas 2: Erreur ---
          if (provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Erreur: ${provider.errorMessage}",
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.red),
                ),
              ),
            );
          }

          // --- Cas 3: Liste vide ---
          if (provider.logements.isEmpty) {
            return const Center(
              child: Text("Vous n'avez aucun logement pour le moment."),
            );
          }

          // --- Cas 4: Succès ---
          return RefreshIndicator(
            onRefresh: () => provider.loadLogementsLocataire(),
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: provider.logements.length,
              itemBuilder: (context, index) {
                final logement = provider.logements[index];
                return _buildLogementCard(context, logement);
              },
            ),
          );
        },
      ),
    );
  }

  /// Construit la carte pour un logement
  Widget _buildLogementCard(BuildContext context, Logement logement) {
    // Formatage du loyer
    final formattedLoyer = NumberFormat("#,###", "fr_FR")
        .format(logement.loyerMensuel ?? 0)
        .replaceAll(',', ' ');

    return GestureDetector(
      onTap: () {
        // --- NAVIGATION VERS LE DÉTAIL ---
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => LogementDetailScreen(logementId: logement.id!),
        //   ),
        // );
        print("Afficher détail du logement ID: ${logement.id}");
      },
      child: Card(
        elevation: 4,
        margin: const EdgeInsets.only(bottom: 16),
        clipBehavior: Clip.antiAlias, // Pour arrondir l'image
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- IMAGE ---
            Container(
              height: 180,
              width: double.infinity,
              child: (logement.photos != null && logement.photos!.isNotEmpty)
                  ? Image.network(
                logement.photos!.first.url, // Utilise l'URL de la première photo
                fit: BoxFit.cover,
                // Widget de chargement pendant que l'image se charge
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress == null) return child;
                  return const Center(child: CircularProgressIndicator());
                },
                // Widget en cas d'erreur de chargement de l'image
                errorBuilder: (context, error, stackTrace) {
                  return const Icon(Icons.broken_image, size: 50, color: Colors.grey);
                },
              )
                  : Container( // Placeholder si aucune photo
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(Icons.apartment, size: 60, color: Colors.white),
                ),
              ),
            ),

            // --- INFORMATIONS ---
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Loyer
                  Text(
                    "$formattedLoyer Fcfa / mois",
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E3A8A), // Bleu nuit
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Adresse
                 /* Text(
                    logement.propriete?.dresse ?? 'Adresse non disponible',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),*/
                  const SizedBox(height: 4),

                  // Type et pièces
                  Text(
                    '${logement.type} • ${logement.nombrePieces} pièces',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
