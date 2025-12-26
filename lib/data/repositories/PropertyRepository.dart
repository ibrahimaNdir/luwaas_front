import 'package:shared_preferences/shared_preferences.dart';
import '../source/PropertyRemoteSource.dart';
import '../model/property.dart';
import '../model/region.dart';
import '../model/departement.dart';
import '../model/commune.dart';

class PropertyRepository {
  final PropertyRemoteSource _remoteSource;

  PropertyRepository({PropertyRemoteSource? remoteSource})
      : _remoteSource = remoteSource ?? PropertyRemoteSource();

  // ========================================
  // 🏠 GESTION DES PROPRIÉTÉS
  // ========================================

  // ✅ Ajouter une propriété
  Future<Property> addProperty(Property property) async {
    final token = await _getTokenOrThrow();

    try {
      return await _remoteSource.addProperty(
        property: property,
        token: token,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible d\'ajouter la propriété');
    }
  }

  // ✅ Récupérer les propriétés du propriétaire connecté
  Future<List<Property>> getOwnerProperties() async {
    final token = await _getTokenOrThrow();

    try {
      return await _remoteSource.getOwnerProperties(token);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible de récupérer les propriétés');
    }
  }

  // ✅ Mettre à jour une propriété
  Future<Property> updateProperty(int propertyId, Property property) async {
    final token = await _getTokenOrThrow();

    try {
      return await _remoteSource.updateProperty(
        propertyId: propertyId,
        property: property,
        token: token,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible de mettre à jour la propriété');
    }
  }

  // ✅ Supprimer une propriété
  Future<void> deleteProperty(int propertyId) async {
    final token = await _getTokenOrThrow();

    try {
      await _remoteSource.deleteProperty(
        propertyId: propertyId,
        token: token,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible de supprimer la propriété');
    }
  }

  // ✅ Compter les propriétés
  Future<int> countProperties() async {
    final token = await _getTokenOrThrow();

    try {
      return await _remoteSource.countProperties(token);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible de compter les propriétés');
    }
  }

  // ✅ Dashboard du propriétaire
  Future<Map<String, dynamic>> getDashboard() async {
    final token = await _getTokenOrThrow();

    try {
      return await _remoteSource.getDashboard(token);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible de charger le dashboard');
    }
  }

  // ✅ Rechercher des propriétés
  Future<List<Property>> searchProperties({
    int? regionId,
    int? departementId,
    int? communeId,
    String? type,
    double? prixMin,
    double? prixMax,
  }) async {
    final token = await _getTokenOrThrow();

    try {
      return await _remoteSource.searchProperties(
        token: token,
        regionId: regionId,
        departementId: departementId,
        communeId: communeId,
        type: type,
        prixMin: prixMin,
        prixMax: prixMax,
      );
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible de rechercher les propriétés');
    }
  }


  // ✅ Récupérer toutes les régions
  Future<List<Region>> getRegions() async {
    try {
      final token = await _getToken();
      return await _remoteSource.getRegions(token);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible de charger les régions');
    }
  }

  // ✅ Récupérer les départements d'une région
  Future<List<Departement>> getDepartementsByRegion(int regionId) async {
    try {
      final token = await _getToken();
      return await _remoteSource.getDepartementsByRegion(regionId, token);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible de charger les départements');
    }
  }

  // ✅ Récupérer les communes d'un département
  Future<List<Commune>> getCommunesByDepartement(int departementId) async {
    try {
      final token = await _getToken();
      return await _remoteSource.getCommunesByDepartement(departementId, token);
    } on ApiException {
      rethrow;
    } catch (e) {
      throw Exception('Impossible de charger les communes');
    }
  }

  // ========================================
  // 🔐 GESTION DU TOKEN
  // ========================================

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<String> _getTokenOrThrow() async {
    final token = await _getToken();
    if (token == null || token.isEmpty) {
      throw ApiException('Session expirée. Veuillez vous reconnecter.', 401);
    }
    return token;
  }

  // ========================================
  // 🔧 UTILITAIRES
  // ========================================

  // Vérifier si l'utilisateur est authentifié
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token != null && token.isNotEmpty;
  }

  // Sauvegarder le token (pour l'auth)
  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Supprimer le token (pour la déconnexion)
  Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // 🧹 Nettoyer les ressources
  void dispose() {
    _remoteSource.dispose();
  }
}