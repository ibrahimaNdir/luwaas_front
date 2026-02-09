// lib/screens/AddLogementScreen.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import '../../presentation/provider/LogementProvider.dart';
import 'package:luwaas/data/model/logements.dart';

class AddLogementScreen extends StatefulWidget {
  final int proprieteId;
  final String typePropriete;

  const AddLogementScreen({
    Key? key,
    required this.proprieteId,
    required this.typePropriete,
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
  String _typeLogement = 'appartement ';
  final _superficieController = TextEditingController();

// Page 2 - Détails et stats
  final _nombreChambresController = TextEditingController();
  final _nombreSdbController = TextEditingController();
  bool _meuble = false;
  String _etat = 'bon';

// Page 3 - Prix et Finance
  final _prixController = TextEditingController();
  final _descriptionController = TextEditingController();

  double _totalEstime = 0.0;

  // Page 4 - Photos
  List<File> _photos = [];
  static const int _maxPhotos = 10;

  // ============================================
  // 🔧 MÉTHODES DE PARSING SÉCURISÉES
  // ============================================

  double? _parseDouble(String text) {
    try {
      return double.parse(text.replaceAll(',', '.').trim());
    } catch (e) {
      return null;
    }
  }

  int? _parseInt(String text) {
    try {
      return int.parse(text.trim());
    } catch (e) {
      return null;
    }
  }

  // ============================================
  // 🎯 INITIALISATION
  // ============================================

  List<String> _getTypesAutorises() {
    final type = widget.typePropriete.toLowerCase();
    switch (type) {
      case 'immeuble':
        return ['studio', 'appartement'];
      case 'maison':
        return ['studio', 'appartement', 'maison'];
      case 'villa':
        return ['villa'];
      default:
        return ['studio', 'appartement', 'maison', 'villa'];
    }
  }

  @override
  void initState() {
    super.initState();
    final typesAutorises = _getTypesAutorises();
    if (typesAutorises.isNotEmpty) {
      _typeLogement = typesAutorises.first;
    }
  }

  @override
  void dispose() {
    _numeroController.dispose();
    _pageController.dispose();
    _superficieController.dispose();
    _nombreChambresController.dispose();
    _nombreSdbController.dispose();
    _prixController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ============================================
  // 🔄 NAVIGATION ENTRE PAGES
  // ============================================

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

  // ============================================
  // ✅ VALIDATIONS AMÉLIORÉES ET SÉCURISÉES
  // ============================================

  bool _validatePage1() {
    if (_numeroController.text.trim().isEmpty) {
      _showError('Veuillez entrer le numéro du logement');
      return false;
    }

    final superficie = _parseDouble(_superficieController.text);
    if (superficie == null) {
      _showError('Superficie invalide (format attendu: nombre décimal)');
      return false;
    }
    if (superficie <= 0) {
      _showError('La superficie doit être supérieure à 0 m²');
      return false;
    }
    if (superficie > 10000) {
      _showError('La superficie semble anormalement élevée (max 10 000 m²)');
      return false;
    }

    return true;
  }

  bool _validatePage2() {
    final chambre = _parseInt(_nombreChambresController.text);
    if (chambre == null) {
      _showError('Nombre de pièces invalide (entrez un nombre entier)');
      return false;
    }
    if (chambre <= 0) {
      _showError('Le logement doit avoir au moins 1 pièce');
      return false;
    }
    if (chambre > 50) {
      _showError('Nombre de pièces anormalement élevé (max 50)');
      return false;
    }

    final sdb = _parseInt(_nombreSdbController.text);
    if (sdb == null) {
      _showError('Nombre de salles de bain invalide (entrez un nombre entier)');
      return false;
    }
    if (sdb < 0) {
      _showError('Le nombre de salles de bain ne peut pas être négatif');
      return false;
    }
    if (sdb > 20) {
      _showError('Nombre de SDB anormalement élevé (max 20)');
      return false;
    }

    return true;
  }

  bool _validatePage3() {
    final loyer = _parseDouble(_prixController.text);
    if (loyer == null) {
      _showError('Loyer invalide (format attendu: nombre décimal)');
      return false;
    }
    if (loyer <= 0) {
      _showError('Le loyer doit être supérieur à 0 FCFA');
      return false;
    }
    if (loyer < 10000) {
      _showError('Le loyer semble anormalement bas (min recommandé: 10 000 FCFA)');
      return false;
    }

    return true;
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
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
  // 📸 GESTION DES PHOTOS - SÉLECTION MULTIPLE AMÉLIORÉE
  // ============================================

  /// ✅ Sélectionner plusieurs photos en une seule fois depuis la galerie
  Future<void> _pickMultipleImages() async {
    // Vérifier combien d'emplacements restent
    int remainingSlots = _maxPhotos - _photos.length;

    if (remainingSlots <= 0) {
      _showError('Vous avez déjà atteint le maximum de $_maxPhotos photos');
      return;
    }

    try {
      // ✅ Sélection multiple avec pickMultipleMedia
      final List<XFile> selectedImages = await _picker.pickMultipleMedia(
        imageQuality: 85, // Compression pour optimiser la taille
        limit: remainingSlots, // Limiter au nombre d'emplacements disponibles (Android 13+)
      );

      if (selectedImages.isEmpty) {
        // L'utilisateur a annulé
        return;
      }

      // Limiter manuellement si nécessaire (pour les anciennes versions Android)
      final photosToAdd = selectedImages.take(remainingSlots).toList();

      setState(() {
        _photos.addAll(photosToAdd.map((img) => File(img.path)).toList());
      });

      // Message de confirmation
      final count = photosToAdd.length;
      _showSuccess('✅ $count photo${count > 1 ? 's' : ''} ajoutée${count > 1 ? 's' : ''}');

      // Avertissement si limitation
      if (selectedImages.length > remainingSlots) {
        _showError('Seulement $remainingSlots photo(s) ont été ajoutées (limite atteinte)');
      }

    } catch (e) {
      _showError('Erreur lors de la sélection: ${e.toString()}');
      debugPrint('❌ Erreur pickMultipleImages: $e');
    }
  }

  /// 📷 Prendre UNE photo avec la caméra
  Future<void> _takePhoto() async {
    if (_photos.length >= _maxPhotos) {
      _showError('Maximum $_maxPhotos photos autorisées');
      return;
    }

    try {
      final XFile? photo = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
      );

      if (photo != null) {
        setState(() {
          _photos.add(File(photo.path));
        });
        _showSuccess('📸 Photo ajoutée');
      }
    } catch (e) {
      _showError('Erreur lors de la prise de photo: ${e.toString()}');
      debugPrint('❌ Erreur takePhoto: $e');
    }
  }

  /// 🗑️ Supprimer une photo
  void _removePhoto(int index) {
    setState(() {
      _photos.removeAt(index);
    });
    _showSuccess('Photo supprimée');
  }

  /// 🔄 Réorganiser les photos (optionnel - pour version future)
  void _reorderPhotos(int oldIndex, int newIndex) {
    setState(() {
      if (newIndex > oldIndex) {
        newIndex -= 1;
      }
      final photo = _photos.removeAt(oldIndex);
      _photos.insert(newIndex, photo);
    });
  }

  // ============================================
  // 💾 SAUVEGARDE SÉCURISÉE
  // ============================================

  Future<void> _saveLogement() async {
    // Validation photos
    if (_photos.isEmpty) {
      _showError('Veuillez ajouter au moins une photo');
      return;
    }

    // Validation finale avec parsing sécurisé
    final superficie = _parseDouble(_superficieController.text);
    final chambre = _parseInt(_nombreChambresController.text);
    final sdb = _parseInt(_nombreSdbController.text);
    final loyer = _parseDouble(_prixController.text);

    // Vérification de tous les champs
    if (superficie == null || chambre == null || sdb == null || loyer == null) {
      _showError('Données invalides, veuillez vérifier tous les champs');
      return;
    }

    // Création de l'objet Logement
    final logement = Logement(
      numero: _numeroController.text.trim(),
      type: _typeLogement,
      superficie: superficie,
      nbrChambres: chambre,
      sdb: sdb,
      estMeuble: _meuble,
      etat: _etat,
      loyerMensuel: loyer,
      description: _descriptionController.text.trim().isEmpty
          ? null
          : _descriptionController.text.trim(),
      proprieteId: widget.proprieteId,
    );

    final provider = context.read<LogementProvider>();

    try {
      // Appel API
      await provider.createLogementWithPhotos(
        logement: logement,
        photosFiles: _photos,
      );

      if (!mounted) return;

      // Gestion des résultats
      if (provider.hasError) {
        _showError(provider.errorMessage ?? 'Erreur lors de la création du logement');
      } else if (provider.isSuccess) {
        _showSuccess('✅ Logement créé avec succès !');
        Navigator.pop(context, provider.createdLogement);
      }
    } catch (e) {
      if (!mounted) return;
      _showError('Erreur inattendue: ${e.toString()}');
      debugPrint('Erreur création logement: $e');
    }
  }

  // ============================================
  // 🎨 CONSTRUCTION DE L'UI
  // ============================================

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
                    const SizedBox(height: 16),
                    Text(
                      'Création en cours...',
                      style: TextStyle(color: Colors.grey[600]),
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

  // ============================================
  // 📋 HEADER & INDICATEUR D'ÉTAPE
  // ============================================

  Widget _buildHeader() {
    final titles = [
      'Information Principale',
      'Configuration des Pièces',
      'Conditions Financières',
      'Photos du Logement',
    ];

    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
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
                const Text(
                  'Ajouter un Logement',
                  style: TextStyle(fontSize: 14, color: Colors.grey),
                ),
                Text(
                  titles[_currentPage],
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1E3A8A),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${_currentPage + 1}/4',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStepIndicator() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(4, (index) {
          final isActive = index == _currentPage;
          final isPassed = index < _currentPage;

          return Row(
            children: [
              Container(
                width: isActive ? 60 : 40,
                height: isActive ? 60 : 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPassed || isActive
                      ? const Color(0xFF1E3A8A)
                      : Colors.grey[300],
                ),
                child: Center(
                  child: Icon(
                    isPassed ? Icons.check : _getStepIcon(index),
                    color: isPassed || isActive ? Colors.white : Colors.grey,
                    size: isActive ? 30 : 20,
                  ),
                ),
              ),
              if (index < 3)
                Container(
                  width: 40,
                  height: 2,
                  color: isPassed ? const Color(0xFF1E3A8A) : Colors.grey[300],
                ),
            ],
          );
        }),
      ),
    );
  }

  IconData _getStepIcon(int index) {
    switch (index) {
      case 0:
        return Icons.home_outlined;
      case 1:
        return Icons.meeting_room_outlined;
      case 2:
        return Icons.account_balance_wallet_outlined;
      case 3:
        return Icons.camera_alt_outlined;
      default:
        return Icons.home_outlined;
    }
  }

  // ============================================
  // 📄 PAGE 1 - INFORMATION PRINCIPALE
  // ============================================

  Widget _buildPage1() {
    final typesAutorises = _getTypesAutorises();

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            'Identifiant (Porte N°)',
            _numeroController,
            hint: 'Ex: A1, 2e Gauche, Studio 3',
            icon: Icons.door_front_door_outlined,
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            'Type de bien',
            _typeLogement,
            typesAutorises
                .map((t) => DropdownMenuItem(
              value: t,
              child: Text(t[0].toUpperCase() + t.substring(1)),
            ))
                .toList(),
                (val) => setState(() => _typeLogement = val!),
            icon: Icons.apartment_outlined,
          ),
          const SizedBox(height: 20),
          _buildTextField(
            'Superficie (m²)',
            _superficieController,
            keyboardType: TextInputType.numberWithOptions(decimal: true),
            hint: 'Ex: 85',
            icon: Icons.square_foot_outlined,
          ),
          const SizedBox(height: 40),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ============================================
  // 📄 PAGE 2 - CONFIGURATION DES PIÈCES
  // ============================================

  Widget _buildPage2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: _buildTextField(
                  'Chambres/Pièces',
                  _nombreChambresController,
                  keyboardType: TextInputType.number,
                  hint: 'Ex: 3',
                  icon: Icons.bed_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildTextField(
                  'Salles de bain',
                  _nombreSdbController,
                  keyboardType: TextInputType.number,
                  hint: 'Ex: 2',
                  icon: Icons.bathroom_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          _buildSwitchField(
            'Meublé ?',
            _meuble,
                (val) => setState(() => _meuble = val),
          ),
          const SizedBox(height: 20),
          _buildDropdownField(
            'État général',
            _etat,
            const [
              DropdownMenuItem(value: 'excellent', child: Text('Neuf / Excellent')),
              DropdownMenuItem(value: 'bon', child: Text('Bon état')),
              DropdownMenuItem(value: 'moyen', child: Text('Moyen')),
              DropdownMenuItem(value: 'renovation_requise', child: Text('À rénover')),
            ],
                (val) => setState(() => _etat = val!),
            icon: Icons.verified_outlined,
          ),
          const SizedBox(height: 40),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ============================================
  // 📄 PAGE 3 - CONDITIONS FINANCIÈRES
  // ============================================

  Widget _buildPage3() {
    final formatter = NumberFormat('#,###', 'fr_FR');

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTextField(
            'Loyer Mensuel (FCFA)',
            _prixController,
            keyboardType: TextInputType.number,
            hint: 'Ex: 250000',
            icon: Icons.payments_outlined,
          ),
          const SizedBox(height: 20),

          if (_totalEstime > 0) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFFF0F9FF),
                    const Color(0xFFE0F2FE),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: const Color(0xFF1E3A8A).withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total à payer (entrée) :',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                      Text(
                        '${formatter.format(_totalEstime)} FCFA',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1E3A8A),
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Caution + 1 mois d\'avance',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 20),
          _buildTextField(
            'Description (optionnelle)',
            _descriptionController,
            maxLines: 4,
            hint: 'Atouts, commodités, environnement...',
            icon: Icons.description_outlined,
          ),
          const SizedBox(height: 40),
          _buildActionButtons(),
        ],
      ),
    );
  }

  // ============================================
  // 📄 PAGE 4 - PHOTOS DU LOGEMENT (AMÉLIORÉE)
  // ============================================

  Widget _buildPage4() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          // ✅ Zone vide - Invitation à ajouter des photos
          if (_photos.isEmpty)
            Column(
              children: [
                // Grande zone de sélection multiple
                GestureDetector(
                  onTap: _pickMultipleImages,
                  child: Container(
                    width: double.infinity,
                    height: 220,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: const Color(0xFF1E3A8A),
                        width: 2,
                        style: BorderStyle.solid,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_photo_alternate,
                          size: 64,
                          color: const Color(0xFF1E3A8A).withOpacity(0.7),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          '📸 Sélectionner plusieurs photos',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Vous pouvez choisir jusqu\'à $_maxPhotos photos en une seule fois',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 16),
                const Text(
                  'ou',
                  style: TextStyle(
                    color: Colors.grey,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 16),

                // Bouton caméra
                OutlinedButton.icon(
                  onPressed: _takePhoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text('Prendre une photo'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 32,
                      vertical: 16,
                    ),
                  ),
                ),
              ],
            )

          // ✅ Photos déjà ajoutées - Grille avec options
          else
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // En-tête avec compteur et bouton d'ajout
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.photo_library,
                          size: 20,
                          color: const Color(0xFF1E3A8A),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_photos.length}/$_maxPhotos photos',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 16,
                            color: Color(0xFF1E3A8A),
                          ),
                        ),
                      ],
                    ),

                    // Bouton ajouter plus (si pas au maximum)
                    if (_photos.length < _maxPhotos)
                      ElevatedButton.icon(
                        onPressed: _pickMultipleImages,
                        icon: const Icon(Icons.add_photo_alternate, size: 18),
                        label: const Text('Ajouter'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF1E3A8A),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                  ],
                ),

                const SizedBox(height: 16),

                // Grille de photos
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 12,
                    mainAxisSpacing: 12,
                  ),
                  itemCount: _photos.length,
                  itemBuilder: (ctx, idx) {
                    return Stack(
                      children: [
                        // Image
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.file(
                            _photos[idx],
                            fit: BoxFit.cover,
                            width: double.infinity,
                            height: double.infinity,
                          ),
                        ),

                        // Bouton supprimer
                        Positioned(
                          top: 6,
                          right: 6,
                          child: GestureDetector(
                            onTap: () => _removePhoto(idx),
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.3),
                                    blurRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 16,
                              ),
                            ),
                          ),
                        ),

                        // Numéro de la photo
                        Positioned(
                          bottom: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.7),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${idx + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                ),

                const SizedBox(height: 20),

                // Option caméra supplémentaire
                if (_photos.length < _maxPhotos)
                  Center(
                    child: OutlinedButton.icon(
                      onPressed: _takePhoto,
                      icon: const Icon(Icons.camera_alt, size: 18),
                      label: const Text('Prendre une photo'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF1E3A8A),
                        side: const BorderSide(color: Color(0xFF1E3A8A)),
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),

          const SizedBox(height: 40),
          _buildActionButtons(isLastPage: true),
        ],
      ),
    );
  }

  // ============================================
  // 🧩 WIDGETS RÉUTILISABLES
  // ============================================

  Widget _buildTextField(
      String label,
      TextEditingController controller, {
        int maxLines = 1,
        TextInputType? keyboardType,
        String? hint,
        IconData? icon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1E3A8A),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDropdownField(
      String label,
      String value,
      List<DropdownMenuItem<String>> items,
      Function(String?) onChanged, {
        IconData? icon,
      }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
          items: items,
          onChanged: onChanged,
          decoration: InputDecoration(
            prefixIcon: icon != null ? Icon(icon, size: 20) : null,
            filled: true,
            fillColor: Colors.white,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: Color(0xFF1E3A8A),
                width: 2,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSwitchField(
      String label,
      bool value,
      Function(bool) onChanged,
      ) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
      ),
      child: SwitchListTile(
        title: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        value: value,
        onChanged: onChanged,
        activeColor: const Color(0xFF1E3A8A),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16),
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
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            child: Text(
              isLastPage ? '✓ Valider et Créer' : 'Suivant →',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Annuler',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      ],
    );
  }
}