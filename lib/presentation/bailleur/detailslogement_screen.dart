// lib/screens/LogementDetailScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luwaas/data/model/logements.dart';
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
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _publierLogement() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Publier le logement'),
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
      await context.read<LogementProvider>().publierLogement(
        proprieteId: widget.logement.proprieteId,
        logementId: widget.logement.id!,
      );

      if (!mounted) return;

      final provider = context.read<LogementProvider>();
      if (provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Erreur'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Logement publié avec succès'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context, true); // Retourner avec succès
      }
    }
  }

  Future<void> _supprimerLogement() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Supprimer le logement'),
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
      await context.read<LogementProvider>().deleteLogement(
        proprieteId: widget.logement.proprieteId,
        logementId: widget.logement.id!,
      );

      if (!mounted) return;

      final provider = context.read<LogementProvider>();
      if (provider.hasError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(provider.errorMessage ?? 'Erreur'),
            backgroundColor: Colors.red,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Logement supprimé'),
            backgroundColor: Colors.orange,
          ),
        );
        Navigator.pop(context, true); // Retourner avec succès
      }
    }
  }

  void _modifierLogement() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Fonctionnalité à venir')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final photos = widget.logement.photos ?? [];
    final hasPhotos = photos.isNotEmpty;

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
              // AppBar avec image
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
                    ),
                    child: const Icon(Icons.arrow_back, color: Colors.black),
                  ),
                  onPressed: () => Navigator.pop(context),
                ),
                flexibleSpace: FlexibleSpaceBar(
                  background: hasPhotos
                      ? Stack(
                    children: [
                      PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() {
                            _currentPhotoIndex = index;
                          });
                        },
                        itemCount: photos.length,
                        itemBuilder: (context, index) {
                          return Image.network(
                            photos[index].url,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                color: Colors.grey[300],
                                child: Icon(
                                  Icons.home,
                                  size: 100,
                                  color: Colors.grey[400],
                                ),
                              );
                            },
                          );
                        },
                      ),
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.3),
                              ],
                            ),
                          ),
                        ),
                      ),
                      if (photos.length > 1)
                        Positioned(
                          bottom: 16,
                          right: 16,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              '${_currentPhotoIndex + 1}/${photos.length}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                    ],
                  )
                      : Container(
                    color: Colors.grey[300],
                    child: Icon(
                      Icons.home,
                      size: 100,
                      color: Colors.grey[400],
                    ),
                  ),
                ),
              ),

              // Contenu
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
                              // Affiche le numéro s'il existe, sinon le nombre de pièces
                              widget.logement.numero!= null
                                  ? 'Logement ${widget.logement.numero}'
                                  : widget.logement.nombrePiecesFormat,
                              style: const TextStyle(
                                fontSize: 24, // Réduit un peu pour éviter débordement
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
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
                              widget.logement.type,
                              style: const TextStyle(
                                color: Color(0xFF1E3A8A),
                                fontWeight: FontWeight.bold,
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

  Widget _buildStatusBadge() {
    // ✅ CORRECTION : Utilisation du vrai statut
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
    final isDisponible = widget.logement.disponible ?? true;

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
      ),
      child: Column(
        children: [
          // ✅ Ligne 1 : Numéro (si dispo) et Superficie
          Row(
            children: [
              if (widget.logement.numero != null && widget.logement.numero!.isNotEmpty) ...[
                Expanded(
                  child: _buildCaracteristiqueItem(
                    Icons.door_front_door_outlined,
                    'Porte N°',
                    widget.logement.numero!,
                  ),
                ),
                Container(width: 1, height: 40, color: Colors.grey[300]),
              ],

              Expanded(
                child: _buildCaracteristiqueItem(
                  Icons.square_foot,
                  'Superficie',
                  widget.logement.superficieFormat,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 16),

          // ✅ Ligne 2 : Pièces et Meublé
          Row(
            children: [
              Expanded(
                child: _buildCaracteristiqueItem(
                  Icons.meeting_room,
                  'Pièces',
                  '${widget.logement.nombrePieces}',
                ),
              ),
              Container(width: 1, height: 40, color: Colors.grey[300]),
              Expanded(
                child: _buildCaracteristiqueItem(
                  widget.logement.estMeuble
                      ? Icons.weekend
                      : Icons.bed_outlined,
                  'Meublé',
                  widget.logement.estMeuble ? 'Oui' : 'Non',
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          Divider(color: Colors.grey[300], height: 1),
          const SizedBox(height: 16),

          // ✅ Ligne 3 : État
          Row(
            children: [
              Expanded(
                child: _buildCaracteristiqueItem(
                  Icons.star_outline,
                  'État',
                  widget.logement.etat,
                ),
              ),
            ],
          )
        ],
      ),
    );
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
    // ✅ CORRECTION : Utilisation du vrai statut
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
