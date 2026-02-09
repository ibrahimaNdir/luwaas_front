import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:luwaas/data/model/logements.dart';
import '../../presentation/provider/LogementProvider.dart';
import '../locataire/details_screen.dart';
import 'detailslogement_screen.dart';

class LogementPublieScreen extends StatefulWidget {
  const LogementPublieScreen({super.key});

  @override
  State<LogementPublieScreen> createState() => _LogementPublieScreenState();
}

class _LogementPublieScreenState extends State<LogementPublieScreen> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _debounce;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogements();
    });
  }

  Future<void> _loadLogements() async {
    if (!mounted) return;
    await context.read<LogementProvider>().loadMesLogementsPublies();
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();

    _debounce = Timer(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() {
        _searchQuery = query.toLowerCase().trim();
      });
    });
  }

  List<Logement> _getFilteredLogements(List<Logement> logements) {
    if (_searchQuery.isEmpty) return logements;

    return logements.where((logement) {
      final nom = logement.titreAffiche?.toLowerCase() ?? '';
      final type = logement.type.toLowerCase();
      final ville = logement.propriete?['ville']?.toString().toLowerCase() ?? '';
      final commune = logement.propriete?['commune']?.toString().toLowerCase() ?? '';

      return nom.contains(_searchQuery) ||
          type.contains(_searchQuery) ||
          ville.contains(_searchQuery) ||
          commune.contains(_searchQuery);
    }).toList();
  }

  int _getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width > 1200) return 4;      // 4 colonnes (réduit de 5)
    if (width > 900) return 3;       // 3 colonnes (réduit de 4)
    if (width > 600) return 2;       // 2 colonnes
    return 1;                        // 1 colonne sur mobile
  }

  @override
  void dispose() {
    _searchController.dispose();
    _debounce?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: _buildAppBar(),
      body: Consumer<LogementProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          if (provider.hasError) {
            return _buildErrorState(provider.errorMessage);
          }

          if (provider.logements.isEmpty) {
            return _buildEmptyState();
          }

          final filteredLogements = _getFilteredLogements(provider.logements);

          return _buildMainContent(provider, filteredLogements);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      shadowColor: Colors.black.withOpacity(0.05),
      title: Row(
        children: [
          const Text(
            'LUWAAS',
            style: TextStyle(
              color: Color(0xFF1E3A8A),
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 6),
          SvgPicture.asset(
            'assets/icons/house_welcome.svg',
            width: 25,
            height: 25,
            colorFilter: const ColorFilter.mode(
              Color(0xFF1E3A8A),
              BlendMode.srcIn,
            ),
          ),

        ],
      ),
      actions: [
        Container(
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            color: const Color(0xFF1E3A8A).withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Color(0xFF1E3A8A)),
            onPressed: _loadLogements,
            tooltip: 'Rafraîchir',
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.1),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const CircularProgressIndicator(
              color: Color(0xFF1E3A8A),
              strokeWidth: 3,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Chargement des logements...',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 48,
                  color: Colors.red[400],
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Erreur de chargement',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                ),
              ),
              const SizedBox(height: 8),
              Text(
                errorMessage ?? 'Une erreur est survenue',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadLogements,
                icon: const Icon(Icons.refresh_rounded, size: 20),
                label: const Text('Réessayer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 14,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.home_outlined,
                size: 64,
                color: const Color(0xFF1E3A8A).withOpacity(0.3),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Aucun logement publié',
              style: TextStyle(
                fontSize: 20,
                color: Color(0xFF1E293B),
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Vos logements publiés apparaîtront ici',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent(LogementProvider provider, List<Logement> filteredLogements) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        _buildHeader(provider.logements.length),
        const SizedBox(height: 16),
        _buildSearchBar(),
        const SizedBox(height: 20),
        Expanded(
          child: filteredLogements.isEmpty
              ? _buildNoResultsState()
              : _buildLogementGrid(filteredLogements),
        ),
      ],
    );
  }

  Widget _buildHeader(int totalCount) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Mes Logements',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E293B),
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                '$totalCount Logement${totalCount > 1 ? 's' : ''} Publié${totalCount > 1 ? 's' : ''}',
                style: const TextStyle(
                  fontSize: 14,
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              '$totalCount',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20.0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: _searchController.text.isNotEmpty
                ? const Color(0xFF1E3A8A)
                : Colors.grey[200]!,
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.search_rounded,
              color: _searchController.text.isNotEmpty
                  ? const Color(0xFF1E3A8A)
                  : Colors.grey[400],
              size: 22,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: TextField(
                controller: _searchController,
                onChanged: _onSearchChanged,
                style: const TextStyle(
                  fontSize: 15,
                  color: Color(0xFF1E293B),
                ),
                decoration: InputDecoration(
                  hintText: 'Rechercher par nom, type ou ville...',
                  hintStyle: TextStyle(
                    color: Colors.grey[400],
                    fontSize: 15,
                  ),
                  border: InputBorder.none,
                  isDense: true,
                  contentPadding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            if (_searchController.text.isNotEmpty)
              GestureDetector(
                onTap: () {
                  _searchController.clear();
                  _onSearchChanged('');
                },
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.close_rounded,
                    color: Colors.grey[600],
                    size: 16,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildNoResultsState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 48,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Aucun résultat trouvé',
            style: TextStyle(
              fontSize: 18,
              color: Color(0xFF1E293B),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Essayez avec d\'autres mots-clés',
            style: TextStyle(
              fontSize: 14,
              color: Color(0xFF64748B),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogementGrid(List<Logement> logements) {
    return RefreshIndicator(
      onRefresh: _loadLogements,
      color: const Color(0xFF1E3A8A),
      child: GridView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        physics: const AlwaysScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: _getCrossAxisCount(context),
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85, // Ratio ajusté pour plus d'élégance
        ),
        itemCount: logements.length,
        itemBuilder: (context, index) {
          return _LogementCard(logement: logements[index]);
        },
      ),
    );
  }
}

// Widget séparé pour la carte de logement (meilleure performance)
class _LogementCard extends StatelessWidget {
  final Logement logement;

  const _LogementCard({required this.logement});

  @override
  Widget build(BuildContext context) {
    final bool isDisponible = logement.disponible ?? true;
    final String statut = isDisponible ? 'Dispo' : 'Loué';
    final Color statutColor = isDisponible
        ? const Color(0xFF10B981) // Vert moderne
        : const Color(0xFFEF4444); // Rouge moderne

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => LogementDetailScreen(logement: logement),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image avec badges
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    _buildImage(),
                    _buildGradientOverlay(),
                    _buildStatusBadge(statut, statutColor),
                    _buildTypeBadge(),
                  ],
                ),
              ),
              // Informations
              Expanded(
                flex: 2,
                child: _buildLogementInfo(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    print('📸 Photo URL: ${logement.photoPrincipaleUrl}');

    return Positioned.fill(
      child: logement.photoPrincipaleUrl != null && logement.photoPrincipaleUrl!.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: logement.photoPrincipaleUrl!,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Colors.grey[200]!,
                Colors.grey[100]!,
              ],
            ),
          ),
          child: const Center(
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              color: Color(0xFF1E3A8A),
            ),
          ),
        ),
        errorWidget: (context, url, error) {
          print('❌ Erreur image: $error');
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Colors.grey[200]!,
                  Colors.grey[100]!,
                ],
              ),
            ),
            child: Center(
              child: Icon(
                Icons.home_rounded,
                size: 48,
                color: Colors.grey[400],
              ),
            ),
          );
        },
      )
          : Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.grey[200]!,
              Colors.grey[100]!,
            ],
          ),
        ),
        child: Center(
          child: Icon(
            Icons.home_rounded,
            size: 48,
            color: Colors.grey[400],
          ),
        ),
      ),
    );
  }

  Widget _buildGradientOverlay() {
    return Positioned.fill(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.15),
            ],
            stops: const [0.6, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(String statut, Color color) {
    return Positioned(
      top: 12,
      left: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              statut,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeBadge() {
    if (logement.type.isEmpty) return const SizedBox.shrink();

    return Positioned(
      top: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              _getTypeIcon(logement.type),
              size: 14,
              color: const Color(0xFF1E3A8A),
            ),
            const SizedBox(width: 5),
            Text(
              logement.type,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLogementInfo() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: const BoxDecoration(
        color: Colors.white,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                logement.titreAffiche ?? '',
                style: const TextStyle(
                  color: Color(0xFF1E293B),
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 6),
              if (logement.propriete != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on_rounded,
                      size: 14,
                      color: Colors.grey[500],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        '${logement.propriete!['commune'] ?? ''} ${logement.propriete!['departements'] ?? ''}'.trim(),
                        style: TextStyle(
                          color: Colors.grey[600],
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E3A8A),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              logement.loyerFormat,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'villa':
        return Icons.villa_rounded;
      case 'appt':
        return Icons.apartment_rounded;
      case 'studio':
        return Icons.home_work_rounded;
      case 'maison':
        return Icons.home_rounded;
      default:
        return Icons.home_outlined;
    }
  }
}