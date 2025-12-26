import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../data/model/property.dart';
import '../../presentation/provider/PropertyProvider.dart';

class AddPropertyScreen extends StatefulWidget {
  final String propertyType;

  const AddPropertyScreen({super.key, required this.propertyType});

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final PageController _pageController = PageController();
  int _pageIndex = 0;

  // Form keys pour chaque page
  final _formKeys = [
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
    GlobalKey<FormState>(),
  ];

  // Sélections en cascade (IDs)
  int? _selectedRegionId;
  int? _selectedDepartementId;
  int? _selectedCommuneId;

  // Controllers des champs
  final _nomController = TextEditingController();
  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Charger les régions au démarrage
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PropertyProvider>().loadRegions();
    });
  }

  // Obtention position GPS
  // ✅ GARDER CETTE FONCTION (C'est le cœur du système)
  Future<void> _obtenirPositionActuelle() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showSnackBar('Activez le service de localisation.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showSnackBar('Permission de localisation refusée.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showSnackBar('Permission de localisation définitivement refusée.');
        return;
      }

      // Ajoute un petit indicateur de chargement si tu veux être perfectionniste, 
      // mais sinon c'est très bien comme ça.
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
          
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(7);
        _longitudeController.text = position.longitude.toStringAsFixed(7);
      });
      _showSnackBar('Position GPS obtenue avec succès !');
    } catch (e) {
      _showSnackBar('Erreur lors de la récupération GPS.');
    }
  }


  // Enregistrement avec Provider
  Future<void> _enregistrer() async {
    if (_selectedRegionId == null ||
        _selectedDepartementId == null ||
        _selectedCommuneId == null) {
      _showSnackBar('Veuillez compléter tous les champs de localisation');
      return;
    }

    final property = Property(
      titre: _nomController.text,
      type: widget.propertyType.toLowerCase(),
      adresse: _adresseController.text,
      description: _descriptionController.text,
      latitude: double.parse(_latitudeController.text),
      longitude: double.parse(_longitudeController.text),
      regionId: _selectedRegionId!,
      departementId: _selectedDepartementId!,
      communeId: _selectedCommuneId!,
    );

    final provider = context.read<PropertyProvider>();
    final success = await provider.addProperty(property);

    if (success) {
      _showSnackBar(provider.successMessage ?? 'Propriété ajoutée avec succès!');
      Navigator.pop(context);
    } else {
      _showSnackBar(provider.errorMessage ?? 'Une erreur est survenue');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  void dispose() {
    _nomController.dispose();
    _adresseController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _pageController.dispose();
    super.dispose();
  }

  // AlertDialog confirmation
  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Annuler'),
        content: Text('Voulez-vous vraiment annuler l\'ajout ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text('Non'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pop();
            },
            child: Text('Oui'),
          ),
        ],
      ),
    );
  }

  // Header Widget
  Widget _header({
    required String title,
    required IconData icon,
    Color iconColor = const Color(0xFF2E4B8C),
  }) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (_pageIndex > 0) {
                  _pageController.previousPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                } else {
                  Navigator.of(context).pop();
                }
              },
            ),
            Expanded(
              child: Center(
                child: Text(
                  title,
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
            ),
            Opacity(opacity: 0, child: Icon(Icons.arrow_back)),
          ],
        ),
        SizedBox(height: 8),
        CircleAvatar(
          radius: 28,
          backgroundColor: iconColor,
          child: Icon(icon, color: Colors.white, size: 32),
        ),
        SizedBox(height: 8),
      ],
    );
  }

  // Page 1 - Informations générales
  Widget _page1() {
    return Container(
      color: Colors.white,
      child: Form(
        key: _formKeys[0],
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(title: widget.propertyType.toUpperCase(), icon: Icons.home),
            Center(
              child: Text(
                "Information Générale",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
            ),
            Center(
              child: Text(
                "Informations de base",
                style: TextStyle(color: Color(0xFF979797)),
              ),
            ),
            SizedBox(height: 16),
            Text(
              "Nom propriété",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            TextFormField(
              controller: _nomController,
              cursorColor: Color(0xFF1E3A8A),
              style: TextStyle(color: Color(0xFF1E3A8A)),
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFECECF3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFECECF3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? "Ce champ est requis" : null,
            ),
            SizedBox(height: 12),
            Text(
              "Adresse",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            TextFormField(
              controller: _adresseController,
              maxLines: 3,
              cursorColor: Color(0xFF1E3A8A),
              style: TextStyle(color: Color(0xFF1E3A8A)),
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFECECF3)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFFECECF3)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? "Ce champ est requis" : null,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF1E3A8A),
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                if (_formKeys[0].currentState?.validate() ?? false) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
              child: Text("Continuer", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                backgroundColor: Colors.white,
              ),
              onPressed: _showCancelDialog,
              child: Text("Annuler"),
            ),
          ],
        ),
      ),
    );
  }

  // Page 2 - Description et coordonnées GPS
   // Page 2 - Description et coordonnées GPS
  Widget _page2() {
    return Container(
      color: Colors.white,
      child: Form(
        key: _formKeys[1],
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(
              title: widget.propertyType.toUpperCase(),
              icon: Icons.description,
            ),
            Center(
              child: Text(
                "Description et Localisation",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                  color: Colors.black,
                ),
              ),
            ),
            SizedBox(height: 16),
            
            // --- CHAMP DESCRIPTION ---
            Text(
              "Description",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            TextFormField(
              controller: _descriptionController,
              maxLines: 4,
              cursorColor: Color(0xFF1E3A8A),
              style: TextStyle(color: Color(0xFF1E3A8A)),
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                hintText: "Décrivez le bien (ex: Appartement lumineux, proche école...)",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide.none,
                ),
              ),
              validator: (v) => v == null || v.isEmpty ? "Ce champ est requis" : null,
            ),
            
            SizedBox(height: 24),
            
            // --- SECTION GPS (DESIGN AMÉLIORÉ) ---
            Text(
              "Position GPS Exacte",
              style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
            ),
            SizedBox(height: 8),
            
            // Container visuel pour le statut GPS
            Container(
              padding: EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: _latitudeController.text.isNotEmpty 
                    ? Colors.green.withOpacity(0.1) 
                    : Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: _latitudeController.text.isNotEmpty ? Colors.green : Colors.orange.shade300
                ),
              ),
              child: Column(
                children: [
                  if (_latitudeController.text.isNotEmpty)
                    Column(
                      children: [
                        Icon(Icons.check_circle, color: Colors.green, size: 40),
                        SizedBox(height: 8),
                        Text(
                          "Position enregistrée !",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green[800]),
                        ),
                        Text(
                          "Lat: ${_latitudeController.text}\nLng: ${_longitudeController.text}",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[700]),
                        ),
                      ],
                    )
                  else
                    Column(
                      children: [
                        Icon(Icons.location_off, color: Colors.orange, size: 40),
                        SizedBox(height: 8),
                        Text(
                          "Aucune position définie",
                          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.orange[800]),
                        ),
                        Text(
                          "Nécessaire pour la recherche 'Autour de moi'",
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                        ),
                      ],
                    ),
                    
                  SizedBox(height: 16),
                  
                  // BOUTON D'ACTION
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[800],
                        padding: EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                      ),
                      onPressed: _obtenirPositionActuelle,
                      icon: Icon(Icons.my_location, color: Colors.white),
                      label: Text(
                        "Je suis sur place (Capturer GPS)", 
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Champs cachés mais présents pour la validation du formulaire
            // On les garde en "display: none" (height: 0) pour que le validator fonctionne
            SizedBox(height: 0, child: TextFormField(controller: _latitudeController, validator: (v) => v!.isEmpty ? "Position requise" : null)),
            SizedBox(height: 0, child: TextFormField(controller: _longitudeController)),

            SizedBox(height: 24),
            
            // --- BOUTONS NAVIGATION ---
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF2E4B8C),
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                // On vérifie manuellement si le GPS est pris
                if (_latitudeController.text.isEmpty) {
                   ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Veuillez cliquer sur "Je suis sur place" pour localiser le bien.'))
                   );
                   return;
                }
                
                if (_formKeys[1].currentState?.validate() ?? false) {
                  _pageController.nextPage(
                    duration: Duration(milliseconds: 300),
                    curve: Curves.ease,
                  );
                }
              },
              child: Text("Continuer", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide(color: Colors.grey),
                backgroundColor: Colors.white,
              ),
              onPressed: _showCancelDialog,
              child: Text("Annuler"),
            ),
          ],
        ),
      ),
    );
  }

  // Page 3 - Localisation avec dropdowns en cascade
  Widget _page3() {
    return Container(
      color: Colors.white,
      child: Form(
        key: _formKeys[2],
        child: Consumer<PropertyProvider>(
          builder: (context, provider, child) {
            return ListView(
              padding: const EdgeInsets.all(20),
              children: [
                _header(
                  title: "Localisation",
                  icon: Icons.pin_drop,
                  iconColor: Colors.green,
                ),
                Center(
                  child: Text(
                    "Localisation administrative",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 17,
                      color: Colors.black,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    "Où se trouve votre propriété ?",
                    style: TextStyle(color: Color(0xFF979797)),
                  ),
                ),
                SizedBox(height: 16),

                // Dropdown Région
                Text(
                  "Région",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: _selectedRegionId,
                  decoration: InputDecoration(
                    fillColor: Color(0xFFECECF3),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFECECF3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFECECF3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Color(0xFF1E3A8A)),
                  hint: Text('Sélectionner une région'),
                  items: provider.regions.map((region) {
                    return DropdownMenuItem<int>(
                      value: region.id,
                      child: Text(region.nom),
                    );
                  }).toList(),
                  onChanged: provider.isLoadingRegions
                      ? null
                      : (int? newValue) {
                    setState(() {
                      _selectedRegionId = newValue;
                      _selectedDepartementId = null;
                      _selectedCommuneId = null;
                    });
                    if (newValue != null) {
                      provider.loadDepartementsByRegion(newValue);
                    }
                  },
                  validator: (value) =>
                  value == null ? 'Veuillez sélectionner une région' : null,
                ),
                if (provider.isLoadingRegions)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
                SizedBox(height: 12),

                // Dropdown Département
                Text(
                  "Département",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: _selectedDepartementId,
                  decoration: InputDecoration(
                    fillColor: Color(0xFFECECF3),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFECECF3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFECECF3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Color(0xFF1E3A8A)),
                  hint: Text('Sélectionner un département'),
                  items: provider.departements.map((dept) {
                    return DropdownMenuItem<int>(
                      value: dept.id,
                      child: Text(dept.nom),
                    );
                  }).toList(),
                  onChanged: provider.isLoadingDepartements ||
                      _selectedRegionId == null
                      ? null
                      : (int? newValue) {
                    setState(() {
                      _selectedDepartementId = newValue;
                      _selectedCommuneId = null;
                    });
                    if (newValue != null) {
                      provider.loadCommunesByDepartement(newValue);
                    }
                  },
                  validator: (value) => value == null
                      ? 'Veuillez sélectionner un département'
                      : null,
                ),
                if (provider.isLoadingDepartements)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
                SizedBox(height: 12),

                // Dropdown Commune
                Text(
                  "Commune",
                  style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                DropdownButtonFormField<int>(
                  value: _selectedCommuneId,
                  decoration: InputDecoration(
                    fillColor: Color(0xFFECECF3),
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFECECF3)),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFFECECF3)),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide(color: Color(0xFF1E3A8A)),
                    ),
                  ),
                  dropdownColor: Colors.white,
                  style: TextStyle(color: Color(0xFF1E3A8A)),
                  hint: Text('Sélectionner une commune'),
                  items: provider.communes.map((commune) {
                    return DropdownMenuItem<int>(
                      value: commune.id,
                      child: Text(commune.nom),
                    );
                  }).toList(),
                  onChanged: provider.isLoadingCommunes ||
                      _selectedDepartementId == null
                      ? null
                      : (int? newValue) {
                    setState(() {
                      _selectedCommuneId = newValue;
                    });
                    if (newValue != null) {
                      provider.selectCommune(newValue);
                    }
                  },
                  validator: (value) =>
                  value == null ? 'Veuillez sélectionner une commune' : null,
                ),
                if (provider.isLoadingCommunes)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: LinearProgressIndicator(),
                  ),
                SizedBox(height: 24),

                // Bouton Enregistrer
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF2E4B8C),
                    minimumSize: Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: provider.isLoading
                      ? null
                      : () {
                    if (_formKeys[2].currentState?.validate() ?? false) {
                      _enregistrer();
                    }
                  },
                  child: provider.isLoading
                      ? SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : Text(
                    "Enregistrer",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
                SizedBox(height: 12),

                OutlinedButton(
                  style: OutlinedButton.styleFrom(
                    minimumSize: Size.fromHeight(50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    side: BorderSide(color: Colors.grey),
                    backgroundColor: Colors.white,
                  ),
                  onPressed: provider.isLoading ? null : _showCancelDialog,
                  child: Text(
                    "Annuler",
                    style: TextStyle(color: Colors.black),
                  ),
                ),

                // Affichage des erreurs
                if (provider.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.red.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.red.shade200),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.error_outline, color: Colors.red),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              provider.errorMessage!,
                              style: TextStyle(color: Colors.red.shade900),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: NeverScrollableScrollPhysics(),
        onPageChanged: (i) => setState(() => _pageIndex = i),
        children: [_page1(), _page2(), _page3()],
      ),
    );
  }
}
