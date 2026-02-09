import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart'; // ✅ pour le GPS
import '../../data/model/logements.dart';
import '../../presentation/provider/LogementProvider.dart';
import 'details_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  // 1. ZONES : À terme, charger depuis une API
  final Map<String, int?> _zones = {
    "Tout": null,
    "Dakar": 1,
    "Plateau": 4,
    "Almadies": 8,
    "Mermoz": 12,
    "Ouakam": 15,
  };

  String _selectedZoneKey = "Tout";
  late final TextEditingController _searchController;

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();

    // 2. Chargement initial des données (par zone, sans texte)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _lancerRecherche();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  /// Fonction centrale pour appeler l'API via le Provider (par zone uniquement)
  void _lancerRecherche({int? communeId}) {
    final provider = Provider.of<LogementProvider>(context, listen: false);

    provider.searchByZone(
      communeId: communeId,
    );
  }

  /// Gestion de la sélection d'une zone
  void _onZoneSelected(String zoneName, int? zoneId) {
    setState(() {
      _selectedZoneKey = zoneName;
    });
    _lancerRecherche(
      communeId: zoneId,
    );
  }

  @override
  Widget build(BuildContext context) {
    // 3. Écoute du Provider
    final provider = context.watch<LogementProvider>();
    final logements = provider.logements;
    final isLoading = provider.isLoading;

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              _buildHeader(),
              const SizedBox(height: 25),
              _buildSearchField(),
              const SizedBox(height: 20),
              _buildZoneChips(),
              const SizedBox(height: 15),
              // ✅ Bloc "Autour de moi"
              const _NearbySearchBlock(),
              const SizedBox(height: 15),
              _buildLogementsList(logements, isLoading),
            ],
          ),
        ),
      ),
    );
  }

  /// En-tête avec logo
  Widget _buildHeader() {
    return  Row(
      children: [
        Text(
          "LUWAAS",
          style: TextStyle(
            color: Color(0xFF1E3E8A),
            fontSize: 22,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        SizedBox(width: 5),
        SvgPicture.asset(
          'assets/icons/house_welcome.svg',
          width: 30,
          height: 30,
          colorFilter: const ColorFilter.mode(
            Color(0xFF1E3A8A),
            BlendMode.srcIn,
          ),
        ),


      ],
    );
  }

  /// Champ de recherche (pour l’instant, ne fait que relancer la recherche par zone sélectionnée)
  Widget _buildSearchField() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFF1E3E8A), width: 1.5),
      ),
      child: TextField(
        controller: _searchController,
        decoration: const InputDecoration(
          hintText: "Rechercher",
          hintStyle: TextStyle(
            color: Color(0xFF1E3E8A),
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          suffixIcon: Icon(Icons.search, color: Color(0xFF1E3E8A)),
        ),
        onSubmitted: (val) {
          // Pour le moment, on relance juste par zone.
          _lancerRecherche(
            communeId: _zones[_selectedZoneKey],
          );
        },
      ),
    );
  }

  /// Filtres par zone (chips)
  Widget _buildZoneChips() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: _zones.entries.map((entry) {
          final zoneName = entry.key;
          final zoneId = entry.value;
          final isSelected = _selectedZoneKey == zoneName;

          return Padding(
            padding: const EdgeInsets.only(right: 10),
            child: _ZoneChip(
              zoneName: zoneName,
              isSelected: isSelected,
              onTap: () => _onZoneSelected(zoneName, zoneId),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// Liste des logements
  Widget _buildLogementsList(List<Logement> logements, bool isLoading) {
    return Expanded(
      child: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1E3E8A),
        ),
      )
          : logements.isEmpty
          ? _buildEmptyState()
          : ListView.separated(
        itemCount: logements.length,
        separatorBuilder: (ctx, i) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          return _LogementHorizontalCard(logement: logements[index]);
        },
      ),
    );
  }

  /// État vide
  Widget _buildEmptyState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 50, color: Colors.grey),
          SizedBox(height: 10),
          Text(
            "Aucun logement trouvé",
            style: TextStyle(color: Colors.grey, fontSize: 16),
          ),
        ],
      ),
    );
  }
}

/// Bloc "Autour de moi" avec slider + bouton
class _NearbySearchBlock extends StatefulWidget {
  const _NearbySearchBlock();

  @override
  State<_NearbySearchBlock> createState() => _NearbySearchBlockState();
}

class _NearbySearchBlockState extends State<_NearbySearchBlock> {
  double _radius = 5; // km
  bool _isLocating = false;

  Future<void> _searchNearby() async {
    setState(() => _isLocating = true);

    try {
      // Permissions
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Activez le GPS pour utiliser cette fonction.")),
        );
        return;
      }

      // Position actuelle
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Appel Provider
      final provider = Provider.of<LogementProvider>(context, listen: false);
      await provider.searchNearby(
        lat: position.latitude,
        lng: position.longitude,
        radius: _radius,
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur GPS : $e")),
      );
    } finally {
      if (mounted) setState(() => _isLocating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text(
              "Autour de moi",
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            Text("${_radius.toInt()} km"),
          ],
        ),
        Slider(
          value: _radius,
          min: 1,
          max: 30,
          divisions: 29,
          label: "${_radius.toInt()} km",
          activeColor: const Color(0xFF1E3E8A),
          onChanged: (val) => setState(() => _radius = val),
        ),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.my_location, color: Colors.white),
            label: _isLocating
                ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                color: Colors.white,
                strokeWidth: 2,
              ),
            )
                : const Text(
              "Rechercher autour de moi",
              style: TextStyle(color: Colors.white),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3E8A),
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: _isLocating ? null : _searchNearby,
          ),
        ),
      ],
    );
  }
}

/// Widget pour les chips de zone
class _ZoneChip extends StatelessWidget {
  final String zoneName;
  final bool isSelected;
  final VoidCallback onTap;

  const _ZoneChip({
    required this.zoneName,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF1E3E8A) : Colors.white,
          borderRadius: BorderRadius.circular(25),
          border: Border.all(
            color: isSelected ? const Color(0xFF1E3E8A) : Colors.grey.shade400,
          ),
        ),
        child: Text(
          zoneName,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

/// Card horizontale pour un logement
class _LogementHorizontalCard extends StatelessWidget {
  final Logement logement;

  const _LogementHorizontalCard({required this.logement});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => DetailsLogementScreen(logement: logement),
          ),
        );
      },
      child: Container(
        height: 110,
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildImage(),
            const SizedBox(width: 14),
            Expanded(child: _buildInfo()),
          ],
        ),
      ),
    );
  }

  /// Image du logement avec gestion d'erreur
  Widget _buildImage() {
    String? imageUrl;

    // 1. Photo principale depuis photoPrincipaleUrl
    if (logement.photoPrincipaleUrl != null && logement.photoPrincipaleUrl!.isNotEmpty) {
      imageUrl = logement.photoPrincipaleUrl;
    }
    // 2. Photo principale depuis la liste photos
    else if (logement.photos != null) {
      imageUrl = logement.photoPrincipaleUrl;
    }
    // 3. Première photo de la liste
    else if (logement.photos != null && logement.photos!.isNotEmpty) {
      imageUrl = logement.photos![0].url;
    }

    return Container(
      width: 100,
      height: 90,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: Colors.grey[300],
      ),
      child: imageUrl != null
          ? ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Image.network(
          imageUrl,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Icon(Icons.broken_image, color: Colors.grey[500]);
          },
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Center(
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.grey[400],
              ),
            );
          },
        ),
      )
          : Icon(Icons.image, color: Colors.grey[500]),
    );
  }

  /// Informations du logement
  Widget _buildInfo() {
    final commune = _getCommune();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "${logement.titreAffiche}",
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            fontSize: 15,
            color: Colors.black,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          "${logement.loyerFormat}",
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: Colors.black87,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 4),
        Text(
          commune,
          style: TextStyle(
            color: Colors.grey[500],
            fontSize: 13,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        if (logement.distance != null) _buildDistance(),
      ],
    );
  }

  String _getCommune() {
    try {
      if (logement.propriete is Map) {
        return logement.propriete?['commune']?.toString() ?? "Localisation inconnue";
      }
      return logement.propriete?.toString() ?? "Localisation inconnue";
    } catch (e) {
      return "Localisation inconnue";
    }
  }

  Widget _buildDistance() {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Row(
        children: [
          const Icon(Icons.location_on_outlined, size: 14, color: Colors.green),
          const SizedBox(width: 2),
          Text(
            "${logement.distance!.toStringAsFixed(1)} km",
            style: const TextStyle(
              color: Colors.green,
              fontSize: 13,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
