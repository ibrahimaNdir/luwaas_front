import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luwaas/data/model/logements.dart';
import 'package:luwaas/data/model/photos.dart';
import '../../presentation/provider/LogementProvider.dart';

class LogementDetailScreen extends StatefulWidget {
  final Logement logement;

  const LogementDetailScreen({
    Key? key,
    required this.logement,
  }) : super(key: key);

  @override
  State<LogementDetailScreen> createState() => _LogementDetailScreenState();
}

class _LogementDetailScreenState extends State<LogementDetailScreen> {
  int _currentPhotoIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(
      initialPage: 0,
      viewportFraction: 1.0,
      keepPage: true,
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  // ============================================
  // 🔄 MÉTHODES DE GESTION
  // ============================================

  Future<void> _publierLogement() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.publish, color: Colors.green),
            SizedBox(width: 8),
            Text('Publier le logement'),
          ],
        ),
        content: const Text(
          'Ce logement sera visible par tous les locataires. Voulez-vous continuer ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('Publier'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.logement.id != null) {
      try {
        await context.read<LogementProvider>().publierLogement(
          proprieteId: widget.logement.proprieteId,
          logementId: widget.logement.id!,
        );

        if (!mounted) return;

        final provider = context.read<LogementProvider>();
        if (provider.hasError) {
          _showErrorSnackBar(
              provider.errorMessage ?? 'Erreur lors de la publication');
        } else {
          _showSuccessSnackBar('✅ Logement publié avec succès');
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('Erreur inattendue: ${e.toString()}');
      }
    }
  }

  Future<void> _supprimerLogement() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: const [
            Icon(Icons.warning, color: Colors.red),
            SizedBox(width: 8),
            Text('Supprimer le logement'),
          ],
        ),
        content: const Text(
          'Cette action est irréversible. Voulez-vous vraiment supprimer ce logement ?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Supprimer'),
          ),
        ],
      ),
    );

    if (confirm == true && widget.logement.id != null) {
      try {
        await context.read<LogementProvider>().deleteLogement(
          proprieteId: widget.logement.proprieteId,
          logementId: widget.logement.id!,
        );

        if (!mounted) return;

        final provider = context.read<LogementProvider>();
        if (provider.hasError) {
          _showErrorSnackBar(
              provider.errorMessage ?? 'Erreur lors de la suppression');
        } else {
          _showSuccessSnackBar('Logement supprimé');
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (!mounted) return;
        _showErrorSnackBar('Erreur inattendue: ${e.toString()}');
      }
    }
  }

  void _modifierLogement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Fonctionnalité à venir'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ============================================
  // 🎨 BUILD UI
  // ============================================

  @override
  Widget build(BuildContext context) {
    final photos = widget.logement.photos;
    final hasPhotos = photos != null && photos.isNotEmpty;

    return Scaffold(
      backgroundColor: Colors.white,
      body: Consumer<LogementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: Color(0xFF1E3A8A),
              ),
            );
          }

          return CustomScrollView(
            slivers: [

              // 📸 GALERIE PHOTOS - HAUTEUR FIXE POUR PERMETTRE LE SWIPE
              SliverAppBar(
                expandedHeight: 300,
                pinned: true,
                backgroundColor: const Color(0xFF1E3A8A),
                leading: IconButton(
                  icon: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.2),
                          blurRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                // ✅ SOLUTION: Wrapper le PageView dans un Container avec une hauteur fixe
                flexibleSpace: FlexibleSpaceBar(
                  background: hasPhotos
                      ? _buildPhotoGallery(photos)
                      : _buildPlaceholderImage(),
                ),
              ),

              // 📄 CONTENU DU LOGEMENT
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Badges
                      Row(
                        children: [
                          _buildStatusBadge(),
                          const SizedBox(width: 8),
                          _buildDisponibiliteBadge(),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Titre principal
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              widget.logement.numero != null &&
                                  widget.logement.numero!.isNotEmpty
                                  ? widget.logement.titreAffiche ?? ''
                                  : widget.logement.loyerFormat,
                              style: const TextStyle(
                                fontSize: 22,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF1E3A8A).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.logement.type.toUpperCase(),
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),

                      // Prix
                      Text(
                        widget.logement.loyerFormat,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Caractéristiques principales
                      _buildCaracteristiquesGrid(),
                      const SizedBox(height: 24),

                      // Localisation
                      if (widget.logement.propriete != null)
                        _buildSection(
                          icon: Icons.location_on,
                          title: 'Localisation',
                          content:
                          '${widget.logement.propriete!['adresse'] ?? ''}\n'
                              '${widget.logement.propriete!['commune'] ?? ''}, '
                              '${widget.logement.propriete!['ville'] ?? ''}',
                        ),

                      const SizedBox(height: 24),

                      // Description
                      if (widget.logement.description != null &&
                          widget.logement.description!.isNotEmpty)
                        _buildSection(
                          icon: Icons.description,
                          title: 'Description',
                          content: widget.logement.description!,
                        ),

                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),

      bottomNavigationBar: _buildActionButtons(),
    );
  }

  // ============================================
  // 📸 GALERIE PHOTOS OPTIMISÉE POUR LE SWIPE
  // ============================================

  Widget _buildPhotoGallery(List<Photo> photos) {
    return Stack(
      children: [
        // ✅ SOLUTION 1: Utiliser un SizedBox pour donner une hauteur fixe
        SizedBox(
          height: 300, // Hauteur fixe pour éviter les conflits
          child: PageView.builder(
            controller: _pageController,
            // ✅ SOLUTION 2: Ajouter NeverScrollableScrollPhysics si conflit persiste
            // Sinon, utiliser BouncingScrollPhysics pour un effet naturel
            physics: const ClampingScrollPhysics(), // ou BouncingScrollPhysics()
            onPageChanged: (index) {
              setState(() {
                _currentPhotoIndex = index;
              });
            },
            itemCount: photos.length,
            itemBuilder: (context, index) {
              final Photo photo = photos[index];
              final String imageUrl = photo.url;

              return CachedNetworkImage(
                imageUrl: imageUrl,
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,

                // Pendant le chargement
                placeholder: (context, url) => Container(
                  color: Colors.grey[300],
                  child: const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFF1E3A8A),
                    ),
                  ),
                ),

                // En cas d'erreur
                errorWidget: (context, url, error) {
                  print('❌ Erreur chargement image: $url');
                  print('   Erreur: $error');
                  return Container(
                    color: Colors.grey[300],
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.broken_image,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Image non disponible',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),

        // Dégradé léger pour lisibilité
        Positioned.fill(
          child: IgnorePointer( // ✅ SOLUTION 3: Ignorer les touches pour ne pas bloquer le swipe
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.transparent,
                    Colors.black.withOpacity(0.3),
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
          ),
        ),

        // Indicateur numérique (1/5)
        if (photos.length > 1)
          Positioned(
            bottom: 20,
            right: 20,
            child: IgnorePointer( // ✅ Ne pas bloquer le swipe
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.image,
                      color: Colors.white,
                      size: 14,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${_currentPhotoIndex + 1} / ${photos.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        // Indicateurs de points (dots)
        if (photos.length > 1 && photos.length <= 6)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: IgnorePointer( // ✅ Ne pas bloquer le swipe
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  photos.length,
                      (index) => AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
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
          ),
      ],
    );
  }

  // ============================================
  // 🖼️ IMAGE PLACEHOLDER
  // ============================================

  Widget _buildPlaceholderImage() {
    return Container(
      color: Colors.grey[300],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.home_outlined,
            size: 100,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Aucune photo disponible',
            style: TextStyle(
              color: Colors.grey[600],
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================
  // 🏷️ BADGES & CARACTÉRISTIQUES
  // ============================================

  Widget _buildStatusBadge() {
    final isPublie = widget.logement.statutPublication == 'publie';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isPublie
            ? Colors.green.withOpacity(0.2)
            : Colors.orange.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isPublie ? Colors.green : Colors.orange,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isPublie ? Icons.check_circle : Icons.edit_note,
            size: 16,
            color: isPublie ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 4),
          Text(
            isPublie ? 'Publié' : 'Brouillon',
            style: TextStyle(
              color: isPublie ? Colors.green : Colors.orange,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisponibiliteBadge() {
    final isDisponible = true;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDisponible
            ? const Color(0xFF1E3A8A).withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDisponible ? const Color(0xFF1E3A8A) : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isDisponible ? Icons.key : Icons.lock,
            size: 16,
            color: isDisponible ? const Color(0xFF1E3A8A) : Colors.grey,
          ),
          const SizedBox(width: 4),
          Text(
            isDisponible ? 'Disponible' : 'Occupé',
            style: TextStyle(
              color: isDisponible ? const Color(0xFF1E3A8A) : Colors.grey,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCaracteristiquesGrid() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[200]!),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: _buildCaracteristiqueItem(
                  Icons.bed_outlined,
                  'Chambres',
                  '${widget.logement.nbrChambres}',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _buildCaracteristiqueItem(
                  Icons.bathroom_outlined,
                  'Toilettes',
                  '${widget.logement.sdb}',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCaracteristiqueItem(
                  Icons.square_foot,
                  'Superficie',
                  widget.logement.superficieFormat,
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _buildCaracteristiqueItem(
                  widget.logement.estMeuble
                      ? Icons.weekend
                      : Icons.weekend_outlined,
                  'Meublé',
                  widget.logement.estMeuble ? 'Oui' : 'Non',
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[200], height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildCaracteristiqueItem(
                  Icons.check_circle_outline,
                  'État',
                  _formatEtat(widget.logement.etat),
                ),
              ),
              if (widget.logement.numero != null &&
                  widget.logement.numero!.isNotEmpty) ...[
                Container(width: 1, height: 40, color: Colors.grey[300]),
                Expanded(
                  child: _buildCaracteristiqueItem(
                    Icons.door_front_door_outlined,
                    'Porte',
                    widget.logement.numero!,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  String _formatEtat(String etat) {
    switch (etat.toLowerCase()) {
      case 'excellent':
        return 'Excellent';
      case 'bon':
        return 'Bon';
      case 'moyen':
        return 'Moyen';
      case 'renovation_requise':
        return 'À rénover';
      default:
        return etat;
    }
  }

  Widget _buildCaracteristiqueItem(IconData icon, String label, String value) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF1E3A8A), size: 28),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
          textAlign: TextAlign.center,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildSection({
    required IconData icon,
    required String title,
    required String content,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFF1E3A8A), size: 24),
            const SizedBox(width: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Text(
          content,
          style: TextStyle(
            fontSize: 15,
            color: Colors.grey[700],
            height: 1.5,
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    final isPublie = widget.logement.statutPublication == 'publie';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _supprimerLogement,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Supprimer'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _modifierLogement,
                    icon: const Icon(Icons.edit_outlined),
                    label: const Text('Modifier'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFF1E3A8A),
                      side: const BorderSide(color: Color(0xFF1E3A8A)),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            if (!isPublie) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _publierLogement,
                  icon: const Icon(Icons.publish),
                  label: const Text('Publier ce logement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}