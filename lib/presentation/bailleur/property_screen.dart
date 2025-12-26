import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../presentation/provider/PropertyProvider.dart';
import '../../data/model/property.dart';
import 'logement_screen.dart';

class PropertyScreen extends StatefulWidget {
  const PropertyScreen({super.key});

  @override
  State<PropertyScreen> createState() => _PropertyScreenState();
}

class _PropertyScreenState extends State<PropertyScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  String? _selectedTypeFilter;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadOwnerProperties();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<Property> _filterProperties(List<Property> properties) {
    var filtered = properties;

    if (_selectedTypeFilter != null) {
      filtered = filtered.where((p) =>
      p.type.toLowerCase() == _selectedTypeFilter!.toLowerCase()
      ).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((property) {
        return property.titre.toLowerCase().contains(_searchQuery.toLowerCase()) ||
            property.adresse.toLowerCase().contains(_searchQuery.toLowerCase());
      }).toList();
    }

    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          // Header bleu avec recherche
          SliverToBoxAdapter(
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E3A8A),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Mes Proprietes",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),
                  TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    style: TextStyle(fontSize: 14),
                    decoration: InputDecoration(
                      hintText: "Rechercher Propriete",
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      suffixIcon: Container(
                        margin: EdgeInsets.all(4),
                        decoration: BoxDecoration(
                          color: Color(0xFF1E3A8A),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(
                          Icons.tune,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Boutons de filtre par type
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 16,
              ),
              child: Row(
                children: [
                  _FilterChip(
                    label: 'Immeu',
                    icon: Icons.apartment,
                    isSelected: _selectedTypeFilter == 'immeuble',
                    onTap: () {
                      setState(() {
                        _selectedTypeFilter =
                        _selectedTypeFilter == 'immeuble' ? null : 'immeuble';
                      });
                    },
                  ),
                  SizedBox(width: 12),
                  _FilterChip(
                    label: 'Villa',
                    icon: Icons.villa,
                    isSelected: _selectedTypeFilter == 'villa',
                    onTap: () {
                      setState(() {
                        _selectedTypeFilter =
                        _selectedTypeFilter == 'villa' ? null : 'villa';
                      });
                    },
                  ),
                  SizedBox(width: 12),
                  _FilterChip(
                    label: 'Maison',
                    icon: Icons.home,
                    isSelected: _selectedTypeFilter == 'maison',
                    onTap: () {
                      setState(() {
                        _selectedTypeFilter =
                        _selectedTypeFilter == 'maison' ? null : 'maison';
                      });
                    },
                  ),
                ],
              ),
            ),
          ),

          // Consumer uniquement pour les données dynamiques
          Consumer<PropertyProvider>(
            builder: (context, provider, child) {
              final filteredProperties = _filterProperties(provider.properties);

              return SliverList(
                delegate: SliverChildListDelegate([
                  // Titre avec compteur
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      "Propriete (${filteredProperties.length})",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  SizedBox(height: 16),

                  // Gestion du chargement et liste vide
                  if (provider.isLoading)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: CircularProgressIndicator(
                          color: Color(0xFF1E3A8A),
                        ),
                      ),
                    )
                  else if (filteredProperties.isEmpty)
                    Container(
                      height: MediaQuery.of(context).size.height * 0.5,
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.home_work_outlined,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            SizedBox(height: 16),
                            Text(
                              'Aucune propriété',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                  // Liste des propriétés
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                      child: Column(
                        children: filteredProperties.map((property) {
                          return _PropertyCard(
                            property: property,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LogementScreen(
                                    property: property,
                                  ),
                                ),
                              );
                            },
                          );
                        }).toList(),
                      ),
                    ),
                ]),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _FilterChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? Color(0xFF1E3A8A) : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? Color(0xFF1E3A8A) : Colors.grey.shade300,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              size: 18,
              color: isSelected ? Colors.white : Color(0xFF1E3A8A),
            ),
            SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Color(0xFF1E3A8A),
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PropertyCard extends StatelessWidget {
  final Property property;
  final VoidCallback onTap;

  const _PropertyCard({
    required this.property,
    required this.onTap,
  });

  Color _getTypeBadgeColor(String type) {
    switch (type.toLowerCase()) {
      case 'immeuble':
        return Color(0xFF3B82F6);
      case 'villa':
        return Color(0xFF8B5CF6);
      case 'maison':
        return Color(0xFF10B981);
      default:
        return Colors.grey;
    }
  }

  String _formatTypeName(String type) {
    if (type.toLowerCase() == 'immeuble') return 'Immeub.';
    return type.substring(0, 1).toUpperCase() +
        type.substring(1).toLowerCase();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        child: Row(
          children: [
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Color(0xFF1E3A8A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                Icons.home,
                color: Colors.white,
                size: 24,
              ),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    property.titre,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.location_on,
                        size: 14,
                        color: Colors.grey.shade500,
                      ),
                      SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          property.localisation != null
                              ? '${property.localisation!.region},${property.localisation!.departement}'
                              : property.adresse,
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey.shade500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getTypeBadgeColor(property.type),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                _formatTypeName(property.type),
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}