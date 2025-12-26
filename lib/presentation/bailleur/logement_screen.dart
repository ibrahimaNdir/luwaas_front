// lib/screens/LogementScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luwaas/data/model/property.dart';
import '../../presentation/provider/LogementProvider.dart';
import 'package:luwaas/data/model/logements.dart';
import '../../presentation/bailleur/add_logement_screen.dart';
import 'detailslogement_screen.dart';

class LogementScreen extends StatefulWidget {
  final Property property;

  const LogementScreen({
    Key? key,
    required this.property,
  }) : super(key: key);

  @override
  State<LogementScreen> createState() => _LogementScreenState();
}

class _LogementScreenState extends State<LogementScreen> {
  String _selectedFilter = 'Tous';
  final TextEditingController _searchController = TextEditingController();
  List<Logement> _filteredLogements = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogements();
    });
  }

  Future<void> _loadLogements() async {
    final int proprieteId = widget.property.id ?? 0;
    if (proprieteId == 0) return;

    await context.read<LogementProvider>().loadLogementsByPropriete(
      proprieteId,
    );
    _applyFilters();
  }

  void _applyFilters() {
    final provider = context.read<LogementProvider>();
    List<Logement> logements = provider.logements;

    if (_selectedFilter != 'Tous') {
      logements = logements.where((log) {
        return log.type.toLowerCase() == _selectedFilter.toLowerCase();
      }).toList();
    }

    if (_searchController.text.isNotEmpty) {
      final query = _searchController.text.toLowerCase();
      logements = logements.where((log) {
        return (log.numero?.toLowerCase().contains(query) ?? false) || // ✅ Recherche par numéro aussi
            log.type.toLowerCase().contains(query);
      }).toList();
    }

    setState(() {
      _filteredLogements = logements;
    });
  }

  Future<void> _navigateToAddLogement() async {
    final int safeId = widget.property.id ?? 0;
    if (safeId == 0) return;

    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AddLogementScreen(proprieteId: safeId),
      ),
    );
    _loadLogements();
  }

  Future<void> _navigateToDetails(Logement logement) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LogementDetailScreen(logement: logement),
      ),
    );
    if (result == true) {
      _loadLogements();
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        children: [
          _buildHeader(),
          _buildFilters(),
          _buildFixedTopBar(),
          Expanded(child: _buildLogementListBody()),
        ],
      ),
    );
  }

  Widget _buildFixedTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Consumer<LogementProvider>(
            builder: (context, provider, child) {
              return Text(
                provider.isLoading
                    ? 'Chargement...'
                    : 'Logements (${_filteredLogements.length})',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          TextButton.icon(
            onPressed: _navigateToAddLogement,
            icon: const Icon(Icons.add, size: 20),
            label: const Text('Ajouter'),
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1E3A8A),
              backgroundColor: const Color(0xFF1E3A8A).withOpacity(0.1),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLogementListBody() {
    return Consumer<LogementProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: Color(0xFF1E3A8A)));
        }
        if (provider.hasError) {
          return _buildErrorState(provider.errorMessage);
        }
        if (_filteredLogements.isEmpty) {
          return _buildEmptyState();
        }
        return RefreshIndicator(
          onRefresh: _loadLogements,
          color: const Color(0xFF1E3A8A),
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _filteredLogements.length,
            itemBuilder: (context, index) {
              return _buildLogementCard(_filteredLogements[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF1E3A8A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.property.titre,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          '${widget.property.localisation?.commune ?? ''}, ${widget.property.localisation?.region ?? ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _buildSearchBar(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _searchController,
              onChanged: (_) => _applyFilters(),
              decoration: const InputDecoration(
                hintText: 'Rechercher N° ou Type',
                border: InputBorder.none,
                isDense: true,
              ),
            ),
          ),
          const Icon(Icons.search, color: Color(0xFF1E3A8A)),
        ],
      ),
    );
  }

  Widget _buildFilters() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('Tous', Icons.home),
            _buildFilterChip('appartement', Icons.business), // Valeurs minuscules pour matcher le backend
            _buildFilterChip('maison', Icons.home_work),
            _buildFilterChip('studio', Icons.apartment),
            _buildFilterChip('villa', Icons.villa),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, IconData icon) {
    // Petit hack pour l'affichage : Majuscule première lettre
    String displayLabel = label == 'Tous' ? 'Tous' : label[0].toUpperCase() + label.substring(1);

    final isSelected = _selectedFilter.toLowerCase() == label.toLowerCase();

    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedFilter = label;
          });
          _applyFilters();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isSelected ? const Color(0xFF1E3A8A) : Colors.grey[200],
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            children: [
              Icon(
                icon,
                size: 18,
                color: isSelected ? Colors.white : Colors.grey[700],
              ),
              const SizedBox(width: 6),
              Text(
                displayLabel,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.grey[700],
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildErrorState(String? errorMessage) {
    return Center(
      child: Text(errorMessage ?? 'Erreur'),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.home_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('Aucun logement trouvé', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
        ],
      ),
    );
  }

  // --- PARTIE MODIFIÉE ---

  Widget _buildLogementCard(Logement logement) {
    final bool isDisponible = logement.disponible ?? true;
    final String statut = isDisponible ? 'Disponible' : 'Occupé';
    final Color statutColor = isDisponible ? Colors.green : Colors.orange;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: () => _navigateToDetails(logement),
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              _buildLogementImage(logement),
              const SizedBox(width: 12),
              Expanded(child: _buildLogementInfo(logement)),
              const SizedBox(width: 8),
              _buildStatutBadge(statut, statutColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLogementImage(Logement logement) {
    const String serverUrl = 'http://10.0.18.42:8000';

    String? imagePath;

    // 1. Photo principale
    if (logement.photoPrincipale != null) {
      imagePath = logement.photoPrincipale!.url;
    }
    // 2. Première photo de la liste
    else if (logement.photos != null && logement.photos!.isNotEmpty) {
      imagePath = logement.photos![0].url;
    }

    String? fullUrl;
    if (imagePath != null) {
      fullUrl = imagePath.startsWith('http')
          ? imagePath
          : '$serverUrl$imagePath'; // on préfixe si c'est un chemin relatif
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: fullUrl != null
          ? Image.network(
        fullUrl,
        width: 80,
        height: 80,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => _buildImagePlaceholder(),
        loadingBuilder: (_, child, progress) {
          if (progress == null) return child;
          return Container(
            width: 80,
            height: 80,
            color: Colors.grey[200],
            child:
            const Center(child: Icon(Icons.image, color: Colors.grey)),
          );
        },
      )
          : _buildImagePlaceholder(),
    );
  }


  Widget _buildImagePlaceholder() {
    return Container(
      width: 80,
      height: 80,
      color: Colors.grey[200],
      child: Icon(Icons.home, color: Colors.grey[400], size: 40),
    );
  }

  Widget _buildLogementInfo(Logement logement) {
    // Formatage propre du type (maison -> Maison)
    String typeAffiche = logement.type;
    if (typeAffiche.isNotEmpty) {
      typeAffiche = typeAffiche[0].toUpperCase() + typeAffiche.substring(1);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A).withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                typeAffiche,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),

        // ✅ CORRECTION ICI : On affiche le Numéro ET le nombre de pièces
        Text(
          'N° ${logement.numero ?? '-'} • ${logement.nombrePiecesFormat}',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: Text(
                logement.loyerFormat,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
            ),
            Text(
              logement.superficieFormat,
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStatutBadge(String statut, Color statutColor) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), // Réduit un peu
      decoration: BoxDecoration(
        color: statutColor.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        statut,
        style: TextStyle(
          color: statutColor,
          fontSize: 10, // Réduit un peu
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
