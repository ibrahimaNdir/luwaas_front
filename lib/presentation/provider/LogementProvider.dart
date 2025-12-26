
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:luwaas/data/model/photos.dart';
import '../../data/repositories/LogementRepository.dart';
import '../../data/model/logements.dart';

class LogementProvider extends ChangeNotifier {
  final LogementRepository repository;

  LogementProvider({required this.repository});

  // État de chargement
  bool _isLoading = false;
  String? _errorMessage;

  // Données
  Logement? _createdLogement;
  List<Photo> _uploadedPhotos = [];
  List<Logement> _logements = [];
  int _logementsCount = 0;

  // Progression de l'upload
  double _uploadProgress = 0.0;

  // Getters
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  Logement? get createdLogement => _createdLogement;
  List<Photo> get uploadedPhotos => _uploadedPhotos;
  List<Logement> get logements => _logements;
  int get logementsCount => _logementsCount;
  double get uploadProgress => _uploadProgress;

  bool get hasError => _errorMessage != null;
  bool get isSuccess => !_isLoading && _errorMessage == null && _createdLogement != null;

  /// Créer un logement avec photos (tout en une fois)
  /// C'est la méthode RECOMMANDÉE pour créer un logement avec photos
  Future<void> createLogementWithPhotos({
    required Logement logement,
    required List<File> photosFiles,
  }) async {
    _setLoading();

    try {
      final result = await repository.createLogementWithPhotos(
        logement: logement,
        photosFiles: photosFiles,
      );

      _createdLogement = result;
      _uploadedPhotos = result.photos ?? [];
      _uploadProgress = 1.0;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _uploadProgress = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un logement puis ajouter les photos (en 2 étapes avec progression)
  /// Utilisez cette méthode si vous voulez afficher la progression détaillée
  Future<void> createLogementThenAddPhotos({
    required Logement logement,
    required List<File> photosFiles,
  }) async {
    _setLoading();

    try {
      // Étape 1 : Créer le logement (30%)
      _uploadProgress = 0.3;
      notifyListeners();

      final created = await repository.createLogement(logement);

      if (created.id == null) {
        throw Exception('Le logement créé n\'a pas d\'ID');
      }

      // Étape 2 : Ajouter les photos (60%)
      _uploadProgress = 0.6;
      notifyListeners();

      if (photosFiles.isNotEmpty) {
        final photos = await repository.addPhotosToLogement(
          proprieteId: created.proprieteId,
          logementId: created.id!,
          files: photosFiles,
        );

        _uploadedPhotos = photos;

        // Créer un logement enrichi avec les photos
        _createdLogement = Logement(
          id: created.id,
          numero: created.numero,
          type: created.type,
          superficie: created.superficie,
          nombrePieces: created.nombrePieces,
          estMeuble: created.estMeuble,
          etat: created.etat,
          description: created.description,
          loyerMensuel: created.loyerMensuel,
          proprieteId: created.proprieteId,
          propriete: created.propriete,
          photos: photos,
          disponible: created.disponible,
        );
      } else {
        _createdLogement = created;
      }

      _uploadProgress = 1.0;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _uploadProgress = 0.0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Créer un logement sans photos
  Future<void> createLogement(Logement logement) async {
    _setLoading();

    try {
      _createdLogement = await repository.createLogement(logement);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Ajouter des photos à un logement existant
  Future<void> addPhotos({
    required int proprieteId,
    required int logementId,
    required List<File> files,
  }) async {
    _setLoading();

    try {
      _uploadedPhotos = await repository.addPhotosToLogement(
        proprieteId: proprieteId,
        logementId: logementId,
        files: files,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer tous les logements d'une propriété
  Future<void> loadLogementsByPropriete(int proprieteId) async {
    _setLoading();

    try {
      _logements = await repository.getLogementsByPropriete(proprieteId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _logements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Récupérer tous les logements publiés du propriétaire
  Future<void> loadMesLogementsPublies() async {
    _setLoading();

    try {
      _logements = await repository.getMesLogementsPublies();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _logements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Publier un logement (changer le statut en 'publie')
  Future<void> publierLogement({
    required int proprieteId,
    required int logementId,
  }) async {
    _setLoading();

    try {
      _createdLogement = await repository.publierLogement(
        proprieteId: proprieteId,
        logementId: logementId,
      );

      // Mettre à jour la liste locale
      _updateLogementInList(_createdLogement!);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre un logement en brouillon
  Future<void> mettreEnBrouillon({
    required int proprieteId,
    required int logementId,
  }) async {
    _setLoading();

    try {
      _createdLogement = await repository.mettreEnBrouillon(
        proprieteId: proprieteId,
        logementId: logementId,
      );

      // Mettre à jour la liste locale
      _updateLogementInList(_createdLogement!);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Mettre à jour un logement
  Future<void> updateLogement({
    required int proprieteId,
    required int logementId,
    required Logement logement,
  }) async {
    _setLoading();

    try {
      _createdLogement = await repository.updateLogement(
        proprieteId: proprieteId,
        logementId: logementId,
        logement: logement,
      );

      // Mettre à jour la liste locale
      _updateLogementInList(_createdLogement!);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Supprimer un logement
  Future<void> deleteLogement({
    required int proprieteId,
    required int logementId,
  }) async {
    _setLoading();

    try {
      await repository.deleteLogement(
        proprieteId: proprieteId,
        logementId: logementId,
      );

      // Retirer de la liste locale
      _logements.removeWhere((l) => l.id == logementId);

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rechercher des logements à proximité (pour locataire)
  Future<void> searchNearby({
    required double lat,
    required double lng,
    double radius = 10,
  }) async {
    _setLoading();

    try {
      _logements = await repository.searchNearby(
        lat: lat,
        lng: lng,
        radius: radius,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _logements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rechercher des logements par zone (pour locataire)
  Future<void> searchByZone({
    int? regionId,
    int? departementId,
    int? communeId,
    String? typelogement,
    bool? meuble,
    int? nombrePieces,
    double? prixMax,
  }) async {
    _setLoading();

    try {
      _logements = await repository.searchByZone(
        regionId: regionId,
        departementId: departementId,
        communeId: communeId,
        typelogement: typelogement,
        meuble: meuble,
        nombrePieces: nombrePieces,
        prixMax: prixMax,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _logements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Rechercher des logements (pour propriétaire)
  Future<void> searchLogements({
    int? proprieteId,
    String? statutOccupe,
    String? typelogement,
  }) async {
    _setLoading();

    try {
      _logements = await repository.searchLogements(
        proprieteId: proprieteId,
        statutOccupe: statutOccupe,
        typelogement: typelogement,
      );
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _logements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Compter les logements d'une propriété
  Future<void> countByPropriete(int proprieteId) async {
    _setLoading();

    try {
      _logementsCount = await repository.countByPropriete(proprieteId);
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _logementsCount = 0;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Méthodes utilitaires privées
  void _setLoading() {
    _isLoading = true;
    _errorMessage = null;
    _uploadProgress = 0.0;
    notifyListeners();
  }

  void _updateLogementInList(Logement updatedLogement) {
    final index = _logements.indexWhere((l) => l.id == updatedLogement.id);
    if (index != -1) {
      _logements[index] = updatedLogement;
    }
  }

  /// Réinitialiser l'état complet
  void reset() {
    _isLoading = false;
    _errorMessage = null;
    _createdLogement = null;
    _uploadedPhotos = [];
    _uploadProgress = 0.0;
    notifyListeners();
  }

  /// Réinitialiser uniquement l'erreur
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Récupérer tous les logements du locataire connecté
  Future<void> loadLogementsLocataire() async {
    _setLoading();

    try {
      _logements = await repository.getLogementsLocataire();
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _logements = [];
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}