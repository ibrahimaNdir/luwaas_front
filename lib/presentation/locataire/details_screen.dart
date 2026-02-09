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
  int _currentPhotoIndex = 0;

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
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 15),
              ),
            ),
          ],
        ),
        backgroundColor: isError ? Colors.red.shade600 : Colors.green.shade600,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final logement = widget.logement;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 1. Slider de photos en haut
                _buildHeaderImageSlider(),

                Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // 2. Titre et Infos
                      _buildTitle(logement),
                      const SizedBox(height: 12),
                      _buildLocationInfo(logement),
                      const SizedBox(height: 16),
                      _buildTypeInfo(logement),
                      const SizedBox(height: 8),
                      _buildRoomsInfo(logement),
                      const SizedBox(height: 20),
                      _buildPrice(logement),
                      const SizedBox(height: 25),

                      // ✨ Caractéristiques détaillées
                      _buildCaracteristiques(logement),
                      const SizedBox(height: 25),

                      _buildDescription(logement),
                      const SizedBox(height: 100), // Espace pour bouton fixe
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Bouton fixe en bas
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildActionButton(),
          ),
        ],
      ),
    );
  }

  /// 📸 Slider de photos avec gestion multi-images
  Widget _buildHeaderImageSlider() {
    final photos = widget.logement.photos;
    final hasMultiplePhotos = photos != null && photos.isNotEmpty;

    // Fallback si aucune photo
    final defaultPhotoUrl = widget.logement.photoPrincipaleUrl ??
        "https://via.placeholder.com/400x300";

    return Stack(
      children: [
        // Slider de photos ou image unique
        SizedBox(
          height: 320,
          width: double.infinity,
          child: hasMultiplePhotos
              ? PageView.builder(
            itemCount: photos.length,
            onPageChanged: (index) {
              setState(() {
                _currentPhotoIndex = index;
              });
            },
            itemBuilder: (context, index) {
              return _buildPhotoItem(photos[index].url);
            },
          )
              : _buildPhotoItem(defaultPhotoUrl),
        ),

        // Gradient overlay en bas
        Positioned(
          bottom: 0,
          left: 0,
          right: 0,
          child: Container(
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  Colors.black.withOpacity(0.4),
                  Colors.transparent,
                ],
              ),
            ),
          ),
        ),

        // Indicateurs de pagination (dots)
        if (hasMultiplePhotos && photos.length > 1)
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                photos.length,
                    (index) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _currentPhotoIndex == index ? 24 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _currentPhotoIndex == index
                        ? Colors.white
                        : Colors.white.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ),
          ),

        // Compteur de photos en haut à droite
        if (hasMultiplePhotos && photos.length > 1)
          Positioned(
            top: 50,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.6),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.image_outlined,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    '${_currentPhotoIndex + 1}/${photos.length}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),

        // Bouton retour
        Positioned(
          top: 50,
          left: 20,
          child: Semantics(
            label: 'Retour',
            button: true,
            child: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.15),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.arrow_back,
                  color: Colors.black,
                  size: 22,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  /// Widget pour afficher une photo individuelle
  Widget _buildPhotoItem(String photoUrl) {
    final displayUrl = photoUrl.isEmpty
        ? "https://via.placeholder.com/400x300"
        : photoUrl;

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Image.network(
        displayUrl,
        fit: BoxFit.cover,
        width: double.infinity,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            color: Colors.grey[300],
            child: const Center(
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: Color(0xFF1E3E8A),
              ),
            ),
          );
        },
        errorBuilder: (context, error, stackTrace) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[300]!,
                  Colors.grey[200]!,
                ],
              ),
            ),
            child: const Center(
              child: Icon(
                Icons.broken_image_outlined,
                size: 80,
                color: Colors.grey,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTitle(Logement logement) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        "${logement.titreAffiche}",
        style: const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: Colors.black,
          letterSpacing: -0.5,
        ),
      ),
    );
  }

  Widget _buildLocationInfo(Logement logement) {
    final adresse = logement.propriete?['adresse']?.toString() ?? '';
    final commune = logement.propriete?['commune']?.toString() ?? '';

    // Construction intelligente de la localisation
    String location = '';

    if (adresse.isNotEmpty && commune.isNotEmpty) {
      location = '$adresse, $commune';
    } else if (adresse.isNotEmpty) {
      location = adresse;
    } else if (commune.isNotEmpty) {
      location = commune;
    } else {
      location = 'Localisation non renseignée';
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3E8A).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              size: 22,
              color: Color(0xFF1E3E8A),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              location,
              style: const TextStyle(
                fontSize: 15,
                color: Colors.black87,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeInfo(Logement logement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.home_outlined,
            size: 20,
            color: Color(0xFF1E3E8A),
          ),
          const SizedBox(width: 12),
          Text(
            "Type : ${logement.type}",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRoomsInfo(Logement logement) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.meeting_room_outlined,
            size: 20,
            color: Color(0xFF1E3E8A),
          ),
          const SizedBox(width: 12),
          Text(
            "Nombre de pièces : ${logement.nombrePieces}",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrice(Logement logement) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF1E3E8A),
            Color(0xFF2952B8),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF1E3E8A).withOpacity(0.3),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.payments_outlined,
            color: Colors.white,
            size: 28,
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Loyer mensuel",
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.white70,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                logement.loyerFormat,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: -1,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// ✨ Section Caractéristiques détaillées
  Widget _buildCaracteristiques(Logement logement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Caractéristiques",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Nombre de chambres
              _buildCaracteristiqueRow(
                icon: Icons.bed_outlined,
                label: 'Chambres',
                value: '${logement.nbrChambres}',
              ),
              const Divider(height: 24),

              // Salles de bain
              _buildCaracteristiqueRow(
                icon: Icons.bathtub_outlined,
                label: 'Salles de bain',
                value: '${logement.sdb}',
              ),
              const Divider(height: 24),

              // État du logement
              _buildCaracteristiqueRow(
                icon: Icons.verified_outlined,
                label: 'État',
                value: logement.etat,
              ),
              const Divider(height: 24),

              // Meublé ou non
              _buildCaracteristiqueRow(
                icon: Icons.chair_outlined,
                label: 'Ameublement',
                value: logement.estMeuble ? 'Meublé' : 'Non meublé',
                valueColor: logement.estMeuble
                    ? Colors.green.shade700
                    : Colors.orange.shade700,
              ),

              // Superficie
              const Divider(height: 24),
              _buildCaracteristiqueRow(
                icon: Icons.square_foot_outlined,
                label: 'Superficie',
                value: '${logement.superficie.toStringAsFixed(0)} m²',
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Helper pour une ligne de caractéristique
  Widget _buildCaracteristiqueRow({
    required IconData icon,
    required String label,
    required String value,
    Color? valueColor,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3E8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 22,
            color: const Color(0xFF1E3E8A),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              fontSize: 15,
              color: Colors.grey.shade700,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.bold,
            color: valueColor ?? Colors.black,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription(Logement logement) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(left: 4, bottom: 12),
          child: Text(
            "Description",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            logement.description ?? "Aucune description disponible.",
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.6,
            ),
          ),
        ),
      ],
    );
  }

  /// Bouton avec chargement et désactivation
  Widget _buildActionButton() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3E8A),
              padding: const EdgeInsets.symmetric(vertical: 18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
              disabledBackgroundColor: const Color(0xFF1E3E8A).withOpacity(0.5),
              shadowColor: const Color(0xFF1E3E8A).withOpacity(0.3),
            ),
            onPressed: _isSubmitting ? null : _demanderLogement,
            child: _isSubmitting
                ? const SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2.5,
              ),
            )
                : const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.send_outlined, color: Colors.white, size: 20),
                SizedBox(width: 10),
                Text(
                  "Demander ce logement",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}