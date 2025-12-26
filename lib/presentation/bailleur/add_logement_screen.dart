// lib/screens/AddLogementScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import '../../presentation/provider/LogementProvider.dart';
import 'package:luwaas/data/model/logements.dart';

class AddLogementScreen extends StatefulWidget {
  final int proprieteId;

  const AddLogementScreen({
    Key? key,
    required this.proprieteId,
  }) : super(key: key);

  @override
  State<AddLogementScreen> createState() => _AddLogementScreenState();
}

class _AddLogementScreenState extends State<AddLogementScreen> {
  final PageController _pageController = PageController();
  final ImagePicker _picker = ImagePicker();
  int _currentPage = 0;

  // Page 1 - Information Principale
  final _numeroController = TextEditingController();

  // ✅ INITIALISATION AVEC VALEUR BACKEND (minuscule)
  String _typeLogement = 'appartement';
  final _superficieController = TextEditingController();

  // Page 2 - Détails et stats
  final _nombrePiecesController = TextEditingController();
  bool _meuble = false;

  // ✅ INITIALISATION AVEC VALEUR BACKEND (minuscule)
  String _etat = 'bon';

  // Page 3 - Prix et présentation
  final _prixController = TextEditingController();
  final _descriptionController = TextEditingController();

  // Page 4 - Photos
  List<File> _photos = [];

  @override
  void dispose() {
    _numeroController.dispose();
    _pageController.dispose();
    _superficieController.dispose();
    _nombrePiecesController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage == 0 && !_validatePage1()) return;
    if (_currentPage == 1 && !_validatePage2()) return;
    if (_currentPage == 2 && !_validatePage3()) return;

    if (_currentPage < 3) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pop(context);
    }
  }

  bool _validatePage1() {
    if (_numeroController.text.isEmpty) {
      _showError('Veuillez entrer le numéro du logement');
      return false;
    }
    if (_superficieController.text.isEmpty) {
      _showError('Veuillez entrer la superficie');
      return false;
    }
    if (double.tryParse(_superficieController.text.replaceAll(',', '.')) == null) {
      _showError('Superficie invalide');
      return false;
    }
    return true;
  }

  bool _validatePage2() {
    if (_nombrePiecesController.text.isEmpty) {
      _showError('Veuillez entrer le nombre de pièces');
      return false;
    }
    if (int.tryParse(_nombrePiecesController.text) == null) {
      _showError('Nombre de pièces invalide');
      return false;
    }
    return true;
  }

  bool _validatePage3() {
    if (_prixController.text.isEmpty) {
      _showError('Veuillez entrer le prix');
      return false;
    }
    if (double.tryParse(_prixController.text.replaceAll(',', '.')) == null) {
      _showError('Prix invalide');
      return false;
    }
    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  Future<void> _pickImages() async {
    final List<XFile> pickedFiles = await _picker.pickMultiImage();
    if (pickedFiles.isNotEmpty) {
      setState(() {
        _photos = pickedFiles.map((xFile) => File(xFile.path)).toList();
      });
    }
  }

  Future<void> _takePhoto() async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setState(() {
        _photos.add(File(photo.path));
      });
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
  }

  Future<void> _saveLogement() async {
    if (_photos.isEmpty) {
      _showError('Veuillez ajouter au moins une photo');
      return;
    }

    final logement = Logement(
      numero: _numeroController.text,
      type: _typeLogement, // Déjà correct ('appartement')
      superficie: double.parse(_superficieController.text.replaceAll(',', '.')),
      nombrePieces: int.parse(_nombrePiecesController.text),
      estMeuble: _meuble,
      etat: _etat, // Déjà correct ('bon')
      description: _descriptionController.text.isEmpty ? null : _descriptionController.text,
      loyerMensuel: double.parse(_prixController.text.replaceAll(',', '.')),
      proprieteId: widget.proprieteId,
    );

    final provider = context.read<LogementProvider>();

    await provider.createLogementWithPhotos(
      logement: logement,
      photosFiles: _photos,
    );

    if (!mounted) return;

    if (provider.hasError) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.errorMessage ?? 'Erreur inconnue'),
          backgroundColor: Colors.red,
        ),
      );
    } else if (provider.isSuccess) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Logement créé avec succès !'),
          backgroundColor: Colors.green,
        ),
      );
      Navigator.pop(context, provider.createdLogement);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: Consumer<LogementProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const CircularProgressIndicator(color: Color(0xFF1E3A8A)),
                    const SizedBox(height: 24),
                    const Text('Création en cours...', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w500)),
                    const SizedBox(height: 16),
                    Text('Progression: ${(provider.uploadProgress * 100).toStringAsFixed(0)}%'),
                    const SizedBox(height: 16),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 60),
                      child: LinearProgressIndicator(
                        value: provider.uploadProgress,
                        color: const Color(0xFF1E3A8A),
                      ),
                    ),
                  ],
                ),
              );
            }

            return Column(
              children: [
                _buildHeader(),
                _buildStepIndicator(),
                Expanded(
                  child: PageView(
                    controller: _pageController,
                    physics: const NeverScrollableScrollPhysics(),
                    onPageChanged: (index) {
                      setState(() {
                        _currentPage = index;
                      });
                    },
                    children: [
                      _buildPage1(),
                      _buildPage2(),
                      _buildPage3(),
                      _buildPage4(),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildHeader() {
    final titles = [
      'Information Principal',
      'Détails et stats',
      'Prix et présentation',
      'Téléchargez une photo de\nvotre Logement',
    ];

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: _previousPage,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Ajouter un Logement', style: TextStyle(fontSize: 14, color: Colors.grey)),
                Text(
                  titles[_currentPage],
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF1E3A8A)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Center(
        child: Container(
          width: 80,
          height: 80,
          decoration: const BoxDecoration(shape: BoxShape.circle, color: Color(0xFF1E3A8A)),
          child: Center(
            child: Icon(_getStepIcon(), color: Colors.white, size: 40),
          ),
        ),
      ),
    );
  }

  IconData _getStepIcon() {
    switch (_currentPage) {
      case 0: return Icons.home_outlined;
      case 1: return Icons.bar_chart;
      case 2: return Icons.attach_money;
      case 3: return Icons.camera_alt;
      default: return Icons.home_outlined;
    }
  }

  // PAGE 1
  Widget _buildPage1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Numéro de Logement / Porte', _numeroController, hint: 'Ex: A1, 104, B2'),
          const SizedBox(height: 20),

          // ✅ MODIFICATION : On définit manuellement les items (Value = Back, Text = Front)
          _buildDropdownField(
            'Type Logement',
            _typeLogement,
            [
              const DropdownMenuItem(value: 'studio', child: Text('Studio')),
              const DropdownMenuItem(value: 'appartement', child: Text('Appartement')),
              const DropdownMenuItem(value: 'maison', child: Text('Maison')),
              const DropdownMenuItem(value: 'villa', child: Text('Villa')),
            ],
                (value) { setState(() { _typeLogement = value!; }); },
          ),

          const SizedBox(height: 20),
          _buildTextField('Superficie (m²)', _superficieController, keyboardType: TextInputType.number, hint: 'Ex: 85'),
          const SizedBox(height: 40),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // PAGE 2
  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Nombre de pièces', _nombrePiecesController, keyboardType: TextInputType.number, hint: 'Ex: 3'),
          const SizedBox(height: 20),
          _buildSwitchField('Meublé', _meuble, (value) { setState(() { _meuble = value; }); }),
          const SizedBox(height: 20),

          // ✅ MODIFICATION : On définit manuellement les items (Value = Back, Text = Front)
          _buildDropdownField(
            'État',
            _etat,
            [
              const DropdownMenuItem(value: 'excellent', child: Text('Neuf / Excellent')),
              const DropdownMenuItem(value: 'bon', child: Text('Bon état')),
              const DropdownMenuItem(value: 'moyen', child: Text('Moyen')),
              const DropdownMenuItem(value: 'renovation_requise', child: Text('À rénover')),
            ],
                (value) { setState(() { _etat = value!; }); },
          ),

          const SizedBox(height: 40),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // PAGE 3
  Widget _buildPage3() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField('Prix (FCFA)', _prixController, keyboardType: TextInputType.number, hint: 'Ex: 250000'),
          const SizedBox(height: 20),
          _buildTextField('Description (optionnel)', _descriptionController, maxLines: 4, hint: 'Décrivez votre logement...'),
          const SizedBox(height: 40),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // PAGE 4 (Pas de changements majeurs, juste pour être complet)
  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          const Text(
            'Ajoutez une ou plusieurs images de votre logement pour le rendre plus attractif',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey, fontSize: 14),
          ),
          const SizedBox(height: 32),
          if (_photos.isEmpty)
            GestureDetector(
              onTap: _pickImages,
              child: Container(
                width: double.infinity,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF1E3A8A), width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_photo_alternate_outlined, size: 48, color: Colors.grey[400]),
                    const SizedBox(height: 8),
                    Text('Select file', style: TextStyle(color: Colors.grey[600], fontSize: 14)),
                  ],
                ),
              ),
            )
          else
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: _photos.length + 1,
              itemBuilder: (context, index) {
                if (index == _photos.length) {
                  return GestureDetector(
                    onTap: _pickImages,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Icon(Icons.add, color: Colors.grey[400], size: 32),
                    ),
                  );
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(_photos[index], fit: BoxFit.cover, width: double.infinity, height: double.infinity),
                    ),
                    Positioned(
                      top: 4,
                      right: 4,
                      child: GestureDetector(
                        onTap: () => _removePhoto(index),
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(color: Colors.red, shape: BoxShape.circle),
                          child: const Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _takePhoto,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1E3A8A),
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              icon: const Icon(Icons.camera_alt, color: Colors.white),
              label: const Text('Open Camera & Take Photo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
            ),
          ),
          const SizedBox(height: 40),
          _buildActionButtons(isLastPage: true),
        ],
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, {int maxLines = 1, TextInputType? keyboardType, String? hint}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            keyboardType: keyboardType,
            decoration: InputDecoration(
              hintText: hint,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
          ),
        ),
      ],
    );
  }

  // ✅ MODIFICATION : Accepte directement une liste de DropdownMenuItem pour le texte custom
  Widget _buildDropdownField(
      String label,
      String value,
      List<DropdownMenuItem<String>> items, // Changé de List<String> à List<DropdownMenuItem>
      Function(String?) onChanged
      ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
              filled: true,
              fillColor: Colors.white,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            ),
            items: items, // Utilise directement les items personnalisés
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchField(String label, bool value, Function(bool) onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10, offset: const Offset(0, 2))],
      ),
      child: SwitchListTile(
        title: Text(label, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: Colors.black87)),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E3A8A),
      ),
    );
  }

  Widget _buildActionButtons({bool isLastPage = false}) {
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: isLastPage ? _saveLogement : _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1E3A8A),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: Text(isLastPage ? 'Enregistrer' : 'Continuer', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.white)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Annuler', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Colors.black54)),
          ),
        ),
      ],
    );
  }
}
