import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({super.key});

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

  String? _selectedRegion;
  String? _selectedDepartement;
  String? _selectedCommune;

  List<String> _regions = ['Dakar'];
  List<String> _departements = ['Pikine'];
  List<String> _communes = ['Golf SUD '];
  // FIN DES VARIABLES AJOUTÉES ⬆️


  // Controllers des champs
  final _nomController = TextEditingController();
  final _typeController = TextEditingController();
  final _adresseController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _latitudeController = TextEditingController();
  final _longitudeController = TextEditingController();
  final _regionController = TextEditingController();
  final _departementController = TextEditingController();
  final _communeController = TextEditingController();


  // Obtention position GPS
  Future<void> _obtenirPositionActuelle() async {
    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Activez le service de localisation.')),
        );
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Permission de localisation refusée.')),
          );
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Permission de localisation définitivement refusée.')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      setState(() {
        _latitudeController.text = position.latitude.toStringAsFixed(7);
        _longitudeController.text = position.longitude.toStringAsFixed(7);
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Position GPS obtenue avec succès !')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors de la récupération GPS.')),
      );
    }
  }

  // Validators
  String? _validateLatitude(String? val) {
    final v = double.tryParse(val ?? '');
    if (v == null) return 'Latitude invalide';
    if (v < -90 || v > 90) return 'Latitude doit être entre -90 et 90';
    return null;
  }

  String? _validateLongitude(String? val) {
    final v = double.tryParse(val ?? '');
    if (v == null) return 'Longitude invalide';
    if (v < -180 || v > 180) return 'Longitude doit être entre -180 et 180';
    return null;
  }

  // Enregistrement (préparation JSON)
  void _enregistrer() {
    final data = {
      "nom": _nomController.text,
      "type": _typeController.text,
      "adresse": _adresseController.text,
      "description": _descriptionController.text,
      "latitude": double.tryParse(_latitudeController.text),
      "longitude": double.tryParse(_longitudeController.text),
      "region": _regionController.text,
      "departement": _departementController.text,
      "commune": _communeController.text,
    };
    // TODO: POST request vers l'API backend avec 'data'
  }

  @override
  void dispose() {
    _nomController.dispose();
    _typeController.dispose();
    _adresseController.dispose();
    _descriptionController.dispose();
    _latitudeController.dispose();
    _longitudeController.dispose();
    _regionController.dispose();
    _departementController.dispose();
    _communeController.dispose();
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
              Navigator.of(context).maybePop();
            },
            child: Text('Oui'),
          ),
        ],
      ),
    );
  }

  // Header Widget
  Widget _header({required String title, required IconData icon, Color iconColor = const Color(0xFF2E4B8C)}) {
    return Column(
      children: [
        Row(
          children: [
            IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                if (_pageIndex > 0) {
                  _pageController.previousPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                } else {
                  Navigator.of(context).maybePop();
                }
              },
            ),
            Expanded(child: Center(child: Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)))),
            Opacity(opacity: 0, child: Icon(Icons.arrow_back)), // For spacing
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



  // Page 1
  // Page 1
  Widget _page1() {
    return Container(
      color: Colors.white,
      child:  Form(
        key: _formKeys[0],
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(title: "Maison", icon: Icons.home),
            Center(child: Text("Information General", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black))),
            Center(child: Text("Où se trouve votre propriété ?", style: TextStyle(color: Color(0xFF979797)))),
            SizedBox(height: 16),
            Text("Nom propriété", style: TextStyle(color: Colors.black , fontWeight: FontWeight.w600)),
            TextFormField(
              controller: _nomController,
              cursorColor: Color(0xFF1E3A8A),
              style: TextStyle(color: Color(0xFF1E3A8A)),
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
              ),
              validator: (v) => v == null || v.isEmpty ? "Ce champ est requis" : null,
            ),
            SizedBox(height: 12),
            Text("Type",style:TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            TextFormField(
              controller: _typeController,
              cursorColor: Color(0xFF1E3A8A),
              style: TextStyle(color: Color(0xFF1E3A8A)),
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
              ),
            ),
            // <-- LA VIRGULE MANQUANTE EST ICI
            SizedBox(height: 12),
            Text("Adresse", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),

            TextFormField(
              controller: _adresseController,
              maxLines: 3,
              cursorColor: Color(0xFF1E3A8A),
              style: TextStyle(color: Color(0xFF1E3A8A)),
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
              ),
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF1E3A8A),
                  minimumSize: Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () {
                if (_formKeys[0].currentState?.validate() ?? false) {
                  _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                }
              },
              child: Text("Continuer"),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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


  Widget _page2() {
    return Container(
      color: Colors.white,
      child:Form(
        key: _formKeys[1],
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(title: "Maison", icon: Icons.home),
            Center(child: Text("Information General", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black))),
            Center(child: Text("Où se trouve votre propriété ?", style: TextStyle(color: Color(0xFF979797)))),
            SizedBox(height: 16),
            Text("Description", style: TextStyle(color: Colors.black ,fontWeight: FontWeight.w600)),
            TextFormField(
              controller: _descriptionController,
              cursorColor: Color(0xFF1E3A8A),
              style: TextStyle(color: Color(0xFF1E3A8A)),
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
              ),
            ),
            SizedBox(height: 12),
            Text("Latitude", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _latitudeController,
                    cursorColor: Color(0xFF1E3A8A),
                    style: TextStyle(color: Color(0xFF1E3A8A)),
                    decoration: InputDecoration(
                      fillColor: Color(0xFFECECF3),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
                    ),
                    validator: _validateLatitude,
                    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.my_location, color: Color(0xFF2E4B8C)),
                  onPressed: _obtenirPositionActuelle,
                )
              ],
            ),
            SizedBox(height: 12),
            Text("Longitude", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _longitudeController,
                    cursorColor: Color(0xFF1E3A8A),
                    style: TextStyle(color: Color(0xFF1E3A8A)),
                    decoration: InputDecoration(
                      fillColor: Color(0xFFECECF3),
                      filled: true,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                      focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
                    ),

                    validator: _validateLongitude,
                    keyboardType: TextInputType.numberWithOptions(decimal: true, signed: true),
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.my_location, color: Color(0xFF2E4B8C)),
                  onPressed: _obtenirPositionActuelle,
                )
              ],
            ),
            SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E4B8C),
                  minimumSize: Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () {
                if (_formKeys[1].currentState?.validate() ?? false) {
                  _pageController.nextPage(duration: Duration(milliseconds: 300), curve: Curves.ease);
                }
              },
              child: Text("Continuer"),
            ),
            SizedBox(height: 12),
            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey),
                backgroundColor: Colors.white,
              ),
              onPressed: _showCancelDialog,
              child: Text("Annuler"),
            ),
          ],
        ),
      ) ,
    );

  }

  // Page 3
  Widget _page3() {
    return Container(
      color: Colors.white,
      child: Form(
        key: _formKeys[2],
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            _header(title: "Localisation", icon: Icons.pin_drop, iconColor: Colors.green),
            Center(child: Text("Information General", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: Colors.black))),
            Center(child: Text("Où se trouve votre propriété ?", style: TextStyle(color: Color(0xFF979797)))),
            SizedBox(height: 16),

            Text("Region", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            DropdownButtonFormField<String>(
              value: _selectedRegion,
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
              ),
              dropdownColor: Colors.white,
              style: TextStyle(color: Color(0xFF1E3A8A)),
              items: _regions.map((String region) {
                return DropdownMenuItem<String>(
                  value: region,
                  child: Text(region),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedRegion = newValue;
                  _regionController.text = newValue ?? '';
                });
              },
              validator: (value) => value == null ? 'Veuillez sélectionner une région' : null,
            ),
            SizedBox(height: 12),

            Text("Departement", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            DropdownButtonFormField<String>(
              value: _selectedDepartement,
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
              ),
              dropdownColor: Colors.white,
              style: TextStyle(color: Color(0xFF1E3A8A)),
              items: _departements.map((String dept) {
                return DropdownMenuItem<String>(
                  value: dept,
                  child: Text(dept),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDepartement = newValue;
                  _departementController.text = newValue ?? '';
                });
              },
              validator: (value) => value == null ? 'Veuillez sélectionner un département' : null,
            ),
            SizedBox(height: 12),

            Text("Commune", style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600)),
            DropdownButtonFormField<String>(
              value: _selectedCommune,
              decoration: InputDecoration(
                fillColor: Color(0xFFECECF3),
                filled: true,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFFECECF3))),
                focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide(color: Color(0xFF1E3A8A))),
              ),
              dropdownColor: Colors.white,
              style: TextStyle(color: Color(0xFF1E3A8A)),
              items: _communes.map((String commune) {
                return DropdownMenuItem<String>(
                  value: commune,
                  child: Text(commune),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCommune = newValue;
                  _communeController.text = newValue ?? '';
                });
              },
              validator: (value) => value == null ? 'Veuillez sélectionner une commune' : null,
            ),
            SizedBox(height: 24),

            ElevatedButton(
              style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF2E4B8C),
                  minimumSize: Size.fromHeight(50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
              ),
              onPressed: () {
                if (_formKeys[2].currentState?.validate() ?? false) {
                  _enregistrer();
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Propriété enregistrée !')));
                }
              },
              child: Text("Enregistrer", style: TextStyle(color: Colors.white)),
            ),
            SizedBox(height: 12),

            OutlinedButton(
              style: OutlinedButton.styleFrom(
                minimumSize: Size.fromHeight(50),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                side: BorderSide(color: Colors.grey),
                backgroundColor: Colors.white,
              ),
              onPressed: _showCancelDialog,
              child: Text("Annuler", style: TextStyle(color: Colors.black)),
            ),
          ],
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
