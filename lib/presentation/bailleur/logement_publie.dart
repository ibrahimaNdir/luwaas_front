// lib/screens/LogementPublieScreen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:luwaas/data/model/logements.dart';
import '../../presentation/provider/LogementProvider.dart';

class LogementPublieScreen extends StatefulWidget {
  const LogementPublieScreen({super.key});

  @override
  State<LogementPublieScreen> createState() => _LogementPublieScreenState();
}

class _LogementPublieScreenState extends State<LogementPublieScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<Logement> _filteredLogements = [];

  @override
  void initState() {
    super.initState();
    // Charger les logements publiés au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadLogements();
    });
  }

  Future<void> _loadLogements() async {
    await context.read<LogementProvider>().loadMesLogementsPublies();
    _updateFilteredList();
  }

  void _updateFilteredList() {
    final provider = context.read<LogementProvider>();
    setState(() {
      if (_searchController.text.isEmpty) {
        _filteredLogements = provider.logements;
      } else {
        final query = _searchController.text.toLowerCase();
        _filteredLogements = provider.logements.where((logement) {
          final nom = logement.nombrePiecesFormat.toLowerCase();
          final type = logement.type.toLowerCase();
          final ville = logement.propriete?['ville']?.toLowerCase() ?? '';
          return nom.contains(query) ||
              type.contains(query) ||
              ville.contains(query);
        }).toList();
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
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
            Icon(
              Icons.home_outlined,
              color: Colors.grey[700],
              size: 20,
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh, color: Color(0xFF1E3A8A)),
            onPressed: _loadLogements,
          ),
        ],
      ),
      body: Consumer<LogementProvider>(
        builder: (context, provider, child) {
          // État de chargement
          if (provider.isLoading) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                  SizedBox(height: 16),
                  Text('Chargement des logements...'),
                ],
              ),
            );
          }

          // Gestion des erreurs
          if (provider.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: Colors.red[300],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Erreur de chargement',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[800],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.errorMessage ?? 'Erreur inconnue',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: _loadLogements,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Réessayer'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF1E3A8A),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Liste vide
          if (provider.logements.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home_outlined,
                    size: 80,
                    color: Colors.grey[300],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Aucun logement publié',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Vos logements publiés apparaîtront ici',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[400],
                    ),
                  ),
                ],
              ),
            );
          }

          // Interface principale avec logements
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Mes Logements',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${provider.logements.length} Logement${provider.logements.length > 1 ? 's' : ''} Publié${provider.logements.length > 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),

              // Barre de recherche
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                    border: Border.all(color: Colors.grey[300]!),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, color: Colors.grey[400]),
                      const SizedBox(width: 8),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          onChanged: (_) => _updateFilteredList(),
                          decoration: InputDecoration(
                            hintText: 'Rechercher...',
                            hintStyle: TextStyle(color: Colors.grey[400]),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                      if (_searchController.text.isNotEmpty)
                        GestureDetector(
                          onTap: () {
                            _searchController.clear();
                            _updateFilteredList();
                          },
                          child: Icon(Icons.clear, color: Colors.grey[400], size: 20),
                        ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Liste des logements
              Expanded(
                child: _filteredLogements.isEmpty
                    ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.search_off, size: 64, color: Colors.grey[300]),
                      const SizedBox(height: 16),
                      Text(
                        'Aucun résultat',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                )
                    : RefreshIndicator(
                  onRefresh: _loadLogements,
                  color: const Color(0xFF1E3A8A),
                  child: GridView.builder(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 0.75,
                    ),
                    itemCount: _filteredLogements.length,
                    itemBuilder: (context, index) {
                      final logement = _filteredLogements[index];
                      return _buildLogementCard(logement);
                    },
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildLogementCard(Logement logement) {
    // Déterminer le statut
    final bool isDisponible = logement.disponible ?? true;
    final String statut = isDisponible ? 'Dispo' : 'A Loue';
    final Color statutColor = isDisponible
        ? const Color(0xFF1E3A8A)
        : Colors.grey[700]!;

    return GestureDetector(
      onTap: () {
        //Navigation vers les détails du logement
        // Navigator.push(context, MaterialPageRoute(
        //   builder: (context) => LogementDetailScreen(logement: logement),
        // ));
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Image de fond
              Positioned.fill(
                child: logement.photoPrincipale != null
                    ? Image.network(
                  logement.photoPrincipale!.url,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Container(
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.home,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    );
                  },
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: CircularProgressIndicator(
                          value: loadingProgress.expectedTotalBytes != null
                              ? loadingProgress.cumulativeBytesLoaded /
                              loadingProgress.expectedTotalBytes!
                              : null,
                          strokeWidth: 2,
                        ),
                      ),
                    );
                  },
                )
                    : Container(
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.home,
                    size: 60,
                    color: Colors.grey[400],
                  ),
                ),
              ),

              // Gradient overlay
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.5, 1.0],
                    ),
                  ),
                ),
              ),

              // Badge statut (Dispo / A Loue)
              Positioned(
                top: 12,
                left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: statutColor,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    statut,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

              // Badge type (Studio, Villa, etc.)
              if (logement.type.isNotEmpty)
                Positioned(
                  top: 12,
                  right: 12,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(logement.type),
                          size: 14,
                          color: const Color(0xFF1E3A8A),
                        ),
                        const SizedBox(width: 4),
                        Text(
                          logement.type,
                          style: const TextStyle(
                            color: Color(0xFF1E3A8A),
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

              // Informations du logement
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        logement.nombrePiecesFormat,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        logement.loyerFormat,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      if (logement.propriete != null)
                        Text(
                          '${logement.propriete!['commune'] ?? ''}, ${logement.propriete!['ville'] ?? ''}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'villa':
        return Icons.villa;
      case 'appartement':
        return Icons.apartment;
      case 'studio':
        return Icons.home_work;
      case 'maison':
        return Icons.home;
      default:
        return Icons.home_outlined;
    }
  }
}