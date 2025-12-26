import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/model/logements.dart';
import '../../presentation/provider/DemandeProvider.dart';

class DetailsLogementScreen extends StatefulWidget {
  final Logement logement;

  const DetailsLogementScreen({super.key, required this.logement});

  @override
  State<DetailsLogementScreen> createState() => _DetailsLogementScreenState();
}

class _DetailsLogementScreenState extends State<DetailsLogementScreen> {
  bool _isSubmitting = false;

  /// ✅ Fonction optimisée avec Provider et vérifications
  Future<void> _demanderLogement() async {
    // 1. Vérification de l'ID avant tout
    if (widget.logement.id == null) {
      _showSnackBar(
        message: "❌ Logement invalide",
        isError: true,
      );
      return;
    }

    // 2. Lance le chargement
    setState(() => _isSubmitting = true);

    try {
      // 3. Appel via Provider (listen: false pour éviter les rebuilds)
      final demandeProvider = Provider.of<DemandeProvider>(context, listen: false);
      final success = await demandeProvider.createDemande(widget.logement.id!);

      if (!mounted) return;

      if (success) {
        // Succès
        _showSnackBar(
          message: "✅ Demande envoyée au propriétaire !",
          isError: false,
        );

        // Retour après 1 seconde
        await Future.delayed(const Duration(seconds: 1));
        if (mounted) Navigator.pop(context);
      } else {
        _showSnackBar(
          message: "❌ Erreur: ${demandeProvider.error ?? 'Inconnue'}",
          isError: true,
        );
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(
          message: e.toString().replaceAll('Exception: ', ''),
          isError: true,
        );
      }
    } finally {
      // 4. Arrête le chargement
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  /// Helper pour afficher les SnackBars
  void _showSnackBar({required String message, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red : Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logement = widget.logement;
    final photoUrl = logement.photoPrincipale?.url ?? "https://via.placeholder.com/400x300";

    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 1. Image en haut avec gestion d'erreur
            _buildHeaderImage(photoUrl),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 2. Titre et Infos
                  _buildTitle(logement),
                  const SizedBox(height: 8),
                  _buildLocationInfo(logement),
                  const SizedBox(height: 5),
                  _buildTypeInfo(logement),
                  const SizedBox(height: 5),
                  _buildRoomsInfo(logement),
                  const SizedBox(height: 15),
                  _buildPrice(logement),
                  const SizedBox(height: 25),
                  _buildDescription(logement),
                  const SizedBox(height: 40),

                  // 3. Bouton d'action avec chargement
                  _buildActionButton(),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Image avec bouton retour et gestion d'erreur
  Widget _buildHeaderImage(String photoUrl) {
    return Stack(
      children: [
        SizedBox(
          height: 300,
          width: double.infinity,
          child: Image.network(
            photoUrl,
            fit: BoxFit.cover,
            loadingBuilder: (context, child, loadingProgress) {
              if (loadingProgress == null) return child;
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFF1E3E8A),
                  ),
                ),
              );
            },
            errorBuilder: (context, error, stackTrace) {
              return Container(
                color: Colors.grey[300],
                child: const Center(
                  child: Icon(
                    Icons.broken_image,
                    size: 80,
                    color: Colors.grey,
                  ),
                ),
              );
            },
          ),
        ),
        Positioned(
          top: 50,
          left: 20,
          child: Semantics(
            label: 'Retour',
            button: true,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTitle(Logement logement) {
    return Text(
      "${logement.type} - ${logement.nombrePiecesFormat}",
      style: const TextStyle(
        fontSize: 22,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _buildLocationInfo(Logement logement) {
    // ✅ Gestion sécurisée des propriétés
    final commune = logement.propriete?['commune']?.toString() ?? 'Dakar';
    final ville = logement.propriete?['ville']?.toString() ?? '';

    return Row(
      children: [
        const Icon(Icons.location_on_outlined, size: 20, color: Colors.grey),
        const SizedBox(width: 5),
        Expanded(
          child: Text(
            "Lieu : $commune${ville.isNotEmpty ? ', $ville' : ''}",
            style: const TextStyle(fontSize: 16, color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Widget _buildTypeInfo(Logement logement) {
    return Text(
      "Type : ${logement.type}",
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    );
  }

  Widget _buildRoomsInfo(Logement logement) {
    return Text(
      "Nombre de pièces : ${logement.nombrePiecesFormat}",
      style: const TextStyle(fontSize: 16, color: Colors.black87),
    );
  }

  Widget _buildPrice(Logement logement) {
    return Text(
      logement.loyerFormat,
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Color(0xFF1E3E8A),
      ),
    );
  }

  Widget _buildDescription(Logement logement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Description",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          logement.description ?? "Aucune description disponible.",
          style: const TextStyle(
            fontSize: 15,
            color: Colors.black87,
            height: 1.5,
          ),
        ),
      ],
    );
  }

  /// Bouton avec chargement et désactivation
  Widget _buildActionButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3E8A),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          disabledBackgroundColor: const Color(0xFF1E3E8A).withOpacity(0.5),
        ),
        onPressed: _isSubmitting ? null : _demanderLogement,
        child: _isSubmitting
            ? const SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            color: Colors.white,
            strokeWidth: 2,
          ),
        )
            : const Text(
          "Demander ce logement",
          style: TextStyle(
            fontSize: 16,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}