import 'package:flutter/material.dart';
import '../../data/repositories/PropertyRepository.dart';
import '../../data/model/property.dart';
import '../../data/model/region.dart';
import '../../data/model/departement.dart';
import '../../data/model/commune.dart';
import '../../data/source/PropertyRemoteSource.dart';

class PropertyProvider extends ChangeNotifier {
  final PropertyRepository _repository;

  PropertyProvider({PropertyRepository? repository})
      : _repository = repository ?? PropertyRepository();



  // États généraux
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

  // Listes de propriétés
  List<Property> _properties = [];
  int _propertyCount = 0;
  Map<String, dynamic>? _dashboardData;

  // Données géographiques
  List<Region> _regions = [];
  List<Departement> _departements = [];
  List<Commune> _communes = [];

  // Sélections en cascade
  int? _selectedRegionId;
  int? _selectedDepartementId;
  int? _selectedCommuneId;

  // États de chargement séparés
  bool _isLoadingRegions = false;
  bool _isLoadingDepartements = false;
  bool _isLoadingCommunes = false;


  //  GETTERS


  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  String? get successMessage => _successMessage;

  List<Property> get properties => _properties;
  int get propertyCount => _propertyCount;
  Map<String, dynamic>? get dashboardData => _dashboardData;

  List<Region> get regions => _regions;
  List<Departement> get departements => _departements;
  List<Commune> get communes => _communes;

  int? get selectedRegionId => _selectedRegionId;
  int? get selectedDepartementId => _selectedDepartementId;
  int? get selectedCommuneId => _selectedCommuneId;

  bool get isLoadingRegions => _isLoadingRegions;
  bool get isLoadingDepartements => _isLoadingDepartements;
  bool get isLoadingCommunes => _isLoadingCommunes;


  //  GESTION DES PROPRIÉTÉS


  // ✅ Ajouter une propriété
  Future<bool> addProperty(Property property) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final newProperty = await _repository.addProperty(property);
      _properties.insert(0, newProperty);
      _propertyCount++;
      _successMessage = 'Propriété ajoutée avec succès!';
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Une erreur est survenue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Charger les propriétés du propriétaire
  Future<void> loadOwnerProperties() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _properties = await _repository.getOwnerProperties();
      _propertyCount = _properties.length;
    } on ApiException catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _properties = [];
    } catch (e) {
      _errorMessage = 'Impossible de charger les propriétés';
      _properties = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Mettre à jour une propriété
  Future<bool> updateProperty(int propertyId, Property property) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      final updatedProperty = await _repository.updateProperty(propertyId, property);

      final index = _properties.indexWhere((p) => p.id == propertyId);
      if (index != -1) {
        _properties[index] = updatedProperty;
      }

      _successMessage = 'Propriété mise à jour avec succès!';
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Une erreur est survenue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Supprimer une propriété
  Future<bool> deleteProperty(int propertyId) async {
    _isLoading = true;
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();

    try {
      await _repository.deleteProperty(propertyId);

      _properties.removeWhere((p) => p.id == propertyId);
      _propertyCount--;

      _successMessage = 'Propriété supprimée avec succès!';
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = 'Une erreur est survenue';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ✅ Charger le dashboard
  Future<void> loadDashboard() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _dashboardData = await _repository.getDashboard();
    } on ApiException catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _dashboardData = null;
    } catch (e) {
      _errorMessage = 'Impossible de charger le dashboard';
      _dashboardData = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // ✅ Rechercher des propriétés
  Future<void> searchProperties({
    int? regionId,
    int? departementId,
    int? communeId,
    String? type,
    double? prixMin,
    double? prixMax,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _properties = await _repository.searchProperties(
        regionId: regionId,
        departementId: departementId,
        communeId: communeId,
        type: type,
        prixMin: prixMin,
        prixMax: prixMax,
      );
    } on ApiException catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _properties = [];
    } catch (e) {
      _errorMessage = 'Erreur lors de la recherche';
      _properties = [];
    }

    _isLoading = false;
    notifyListeners();
  }

  // ========================================
  // 🌍 DROPDOWNS EN CASCADE
  // ========================================

  // ✅ Charger les régions
  Future<void> loadRegions() async {
    _isLoadingRegions = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _regions = await _repository.getRegions();
    } on ApiException catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _regions = [];
    } catch (e) {
      _errorMessage = 'Impossible de charger les régions';
      _regions = [];
    }

    _isLoadingRegions = false;
    notifyListeners();
  }

  // ✅ Charger les départements d'une région
  Future<void> loadDepartementsByRegion(int regionId) async {
    _isLoadingDepartements = true;
    _errorMessage = null;

    // Reset cascade
    _selectedRegionId = regionId;
    _selectedDepartementId = null;
    _selectedCommuneId = null;
    _departements = [];
    _communes = [];
    notifyListeners();

    try {
      _departements = await _repository.getDepartementsByRegion(regionId);
    } on ApiException catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _departements = [];
    } catch (e) {
      _errorMessage = 'Impossible de charger les départements';
      _departements = [];
    }

    _isLoadingDepartements = false;
    notifyListeners();
  }

  // ✅ Charger les communes d'un département
  Future<void> loadCommunesByDepartement(int departementId) async {
    _isLoadingCommunes = true;
    _errorMessage = null;

    // Reset cascade
    _selectedDepartementId = departementId;
    _selectedCommuneId = null;
    _communes = [];
    notifyListeners();

    try {
      _communes = await _repository.getCommunesByDepartement(departementId);
    } on ApiException catch (e) {
      _errorMessage = _formatErrorMessage(e);
      _communes = [];
    } catch (e) {
      _errorMessage = 'Impossible de charger les communes';
      _communes = [];
    }

    _isLoadingCommunes = false;
    notifyListeners();
  }

  // ✅ Sélectionner une commune
  void selectCommune(int communeId) {
    _selectedCommuneId = communeId;
    notifyListeners();
  }

  // ✅ Réinitialiser la cascade à partir d'un niveau
  void resetFromRegion() {
    _selectedRegionId = null;
    _selectedDepartementId = null;
    _selectedCommuneId = null;
    _departements = [];
    _communes = [];
    notifyListeners();
  }

  void resetFromDepartement() {
    _selectedDepartementId = null;
    _selectedCommuneId = null;
    _communes = [];
    notifyListeners();
  }

  void resetFromCommune() {
    _selectedCommuneId = null;
    notifyListeners();
  }


  //  UTILITAIRES


  // Formater les erreurs
  String _formatErrorMessage(ApiException e) {
    if (e.statusCode == 401) {
      return 'Session expirée. Veuillez vous reconnecter.';
    } else if (e.statusCode == 403) {
      return 'Accès non autorisé';
    } else if (e.statusCode == 404) {
      return 'Ressource introuvable';
    } else if (e.statusCode == 422) {
      return 'Données invalides';
    } else if (e.message.contains('internet')) {
      return 'Pas de connexion internet';
    } else if (e.message.contains('timeout') || e.message.contains('délai')) {
      return 'La connexion a expiré';
    }
    return e.message;
  }

  // Effacer les messages
  void clearMessages() {
    _errorMessage = null;
    _successMessage = null;
    notifyListeners();
  }

  // Réinitialiser tout
  void reset() {
    _properties = [];
    _propertyCount = 0;
    _dashboardData = null;
    _regions = [];
    _departements = [];
    _communes = [];
    _selectedRegionId = null;
    _selectedDepartementId = null;
    _selectedCommuneId = null;
    _errorMessage = null;
    _successMessage = null;
    _isLoading = false;
    _isLoadingRegions = false;
    _isLoadingDepartements = false;
    _isLoadingCommunes = false;
    notifyListeners();
  }

  // 🧹 Nettoyer les ressources
  @override
  void dispose() {
    _repository.dispose();
    super.dispose();
  }
}