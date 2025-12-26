// lib/data/repositories/LogementRepository.dart
import 'dart:io';
import 'package:luwaas/data/model/photos.dart';
import '../model/logements.dart';
import '../source/LogementRemoteSource.dart';

class LogementRepository {
  final LogementRemoteDataSource remoteSource;

  // Constructeur simple et propre
  LogementRepository({required this.remoteSource});

  /// Créer un logement simple (sans photos)
  Future<Logement> createLogement(Logement logement) {
    return remoteSource.createLogement(logement);
  }

  /// Ajouter des photos à un logement existant
  Future<List<Photo>> addPhotosToLogement({
    required int proprieteId,
    required int logementId,
    required List<File> files,
  }) {
    return remoteSource.addPhotos(
      proprieteId: proprieteId,
      logementId: logementId,
      files: files,
    );
  }

  /// Use case complet : création du logement + upload photos
  /// Cette méthode chaîne automatiquement :
  /// 1. Création du logement
  /// 2. Upload des photos
  /// 3. Récupération du logement avec photos
  Future<Logement> createLogementWithPhotos({
    required Logement logement,
    required List<File> photosFiles,
  }) async {
    // Étape 1 : Création du logement
    final created = await remoteSource.createLogement(logement);

    // Si pas d'ID, on ne peut pas ajouter de photos
    if (created.id == null) {
      throw Exception('Le logement créé n\'a pas d\'ID');
    }

    // Étape 2 : Upload des photos si présentes
    if (photosFiles.isNotEmpty) {
      final uploadedPhotos = await remoteSource.addPhotos(
        proprieteId: created.proprieteId,
        logementId: created.id!,
        files: photosFiles,
      );

      // Étape 3 : Retourner un logement enrichi avec les photos
      return Logement(
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
        photos: uploadedPhotos, // ✅ Photos ajoutées
        disponible: created.disponible,
      );
    }

    return created;
  }

  /// Récupérer tous les logements d'une propriété
  Future<List<Logement>> getLogementsByPropriete(int proprieteId) {
    return remoteSource.getLogementsByPropriete(proprieteId);
  }

  /// Récupérer tous les logements publiés du propriétaire
  Future<List<Logement>> getMesLogementsPublies() {
    return remoteSource.getMesLogementsPublies();
  }

  /// Publier un logement (changer le statut en 'publie')
  Future<Logement> publierLogement({
    required int proprieteId,
    required int logementId,
  }) {
    return remoteSource.updateStatusPublication(
      proprieteId: proprieteId,
      logementId: logementId,
      statut: 'publie',
    );
  }

  /// Mettre un logement en brouillon
  Future<Logement> mettreEnBrouillon({
    required int proprieteId,
    required int logementId,
  }) {
    return remoteSource.updateStatusPublication(
      proprieteId: proprieteId,
      logementId: logementId,
      statut: 'brouillon',
    );
  }

  /// Mettre à jour un logement
  Future<Logement> updateLogement({
    required int proprieteId,
    required int logementId,
    required Logement logement,
  }) {
    return remoteSource.updateLogement(
      proprieteId: proprieteId,
      logementId: logementId,
      logement: logement,
    );
  }

  /// Supprimer un logement
  Future<void> deleteLogement({
    required int proprieteId,
    required int logementId,
  }) {
    return remoteSource.deleteLogement(
      proprieteId: proprieteId,
      logementId: logementId,
    );
  }

  /// Rechercher des logements à proximité (pour locataire)
  Future<List<Logement>> searchNearby({
    required double lat,
    required double lng,
    double radius = 10,
  }) {
    return remoteSource.searchNearby(
      lat: lat,
      lng: lng,
      radius: radius,
    );
  }

  /// Rechercher des logements par zone (pour locataire)
  Future<List<Logement>> searchByZone({
    int? regionId,
    int? departementId,
    int? communeId,
    String? typelogement,
    bool? meuble,
    int? nombrePieces,
    double? prixMax,
  }) {
    return remoteSource.searchByZone(
      regionId: regionId,
      departementId: departementId,
      communeId: communeId,
      typelogement: typelogement,
      meuble: meuble,
      nombrePieces: nombrePieces,
      prixMax: prixMax,
    );
  }

  /// Rechercher des logements (pour propriétaire)
  Future<List<Logement>> searchLogements({
    int? proprieteId,
    String? statutOccupe,
    String? typelogement,
  }) {
    return remoteSource.searchLogements(
      proprieteId: proprieteId,
      statutOccupe: statutOccupe,
      typelogement: typelogement,
    );
  }

  /// Compter les logements d'une propriété
  Future<int> countByPropriete(int proprieteId) {
    return remoteSource.countByPropriete(proprieteId);
  }

  /// Récupérer tous les logements du LOCATAIRE connecté
  Future<List<Logement>> getLogementsLocataire() {
    return remoteSource.getLogementsLocataire();
  }
}