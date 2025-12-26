import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'dart:async';

import '../model/property.dart';
import '../model/region.dart';
import '../model/departement.dart';
import '../model/commune.dart';

// 🔥 Exception personnalisée
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  ApiException(this.message, [this.statusCode]);

  @override
  String toString() => 'ApiException: $message${statusCode != null ? ' (Code: $statusCode)' : ''}';
}

class PropertyRemoteSource {
  final http.Client client;
  final String baseUrl;
  static const Duration _timeout = Duration(seconds: 15);

  PropertyRemoteSource({
    http.Client? client,
    String? baseUrl,
  })  : client = client ?? http.Client(),
        baseUrl = baseUrl ?? 'http://192.168.1.33:8000/api/proprietaire';

  // 🔧 Méthode utilitaire pour les headers
  Map<String, String> _headers([String? token]) => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (token != null) 'Authorization': 'Bearer $token',
  };

  // 🔧 Gestion centralisée des erreurs HTTP
  Future<T> _handleRequest<T>(
      Future<http.Response> Function() request,
      T Function(dynamic) parser,
      ) async {
    try {
      final response = await request().timeout(_timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) {
          throw ApiException('Réponse vide du serveur', response.statusCode);
        }
        final data = jsonDecode(response.body);
        return parser(data);
      } else {
        final errorMsg = _extractErrorMessage(response);
        throw ApiException(errorMsg, response.statusCode);
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } on TimeoutException {
      throw ApiException('Délai d\'attente dépassé');
    } on FormatException {
      throw ApiException('Format de réponse invalide');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur inattendue: $e');
    }
  }

  // 🔧 Extraire le message d'erreur de la réponse
  String _extractErrorMessage(http.Response response) {
    try {
      final body = jsonDecode(response.body);
      return body['message'] ?? body['error'] ?? 'Erreur ${response.statusCode}';
    } catch (_) {
      return 'Erreur ${response.statusCode}';
    }
  }

  // ========================================
  // 🏠 GESTION DES PROPRIÉTÉS
  // ========================================

  // ✅ Dashboard du propriétaire
  Future<Map<String, dynamic>> getDashboard(String token) async {
    return _handleRequest(
          () => client.get(
        Uri.parse('$baseUrl/dashboard'),
        headers: _headers(token),
      ),
          (data) => data as Map<String, dynamic>,
    );
  }

  // ✅ Récupérer toutes les propriétés du propriétaire (allProperty)
  Future<List<Property>> getOwnerProperties(String token) async {
    return _handleRequest(
          () => client.get(
        Uri.parse('$baseUrl/proprietes'),
        headers: _headers(token),
      ),
          (data) {
        final List<dynamic> list = data is List ? data : data['data'] ?? data['proprietes'] ?? [];
        return list.map((json) => Property.fromJson(json)).toList();
      },
    );
  }

  // ✅ Ajouter une propriété (store)
  Future<Property> addProperty({
    required Property property,
    required String token,
  }) async {
    return _handleRequest(
          () => client.post(
        Uri.parse('$baseUrl/proprietes'),
        headers: _headers(token),
        body: jsonEncode(property.toJson()),
      ),
          (data) => Property.fromJson(data['propriete'] ?? data),
    );
  }

  // ✅ Mettre à jour une propriété (update)
  Future<Property> updateProperty({
    required int propertyId,
    required Property property,
    required String token,
  }) async {
    return _handleRequest(
          () => client.put(
        Uri.parse('$baseUrl/proprietes/$propertyId'),
        headers: _headers(token),
        body: jsonEncode(property.toJson()),
      ),
          (data) => Property.fromJson(data['propriete'] ?? data),
    );
  }

  // ✅ Supprimer une propriété (destroy)
  Future<void> deleteProperty({
    required int propertyId,
    required String token,
  }) async {
    try {
      final response = await client
          .delete(
        Uri.parse('$baseUrl/proprietes/$propertyId'),
        headers: _headers(token),
      )
          .timeout(_timeout);

      if (response.statusCode != 204 && response.statusCode != 200) {
        final errorMsg = _extractErrorMessage(response);
        throw ApiException(errorMsg, response.statusCode);
      }
    } on SocketException {
      throw ApiException('Pas de connexion internet');
    } on TimeoutException {
      throw ApiException('Délai d\'attente dépassé');
    } on ApiException {
      rethrow;
    } catch (e) {
      throw ApiException('Erreur lors de la suppression: $e');
    }
  }

  // ✅ Compter les propriétés du propriétaire (countProperty)
  Future<int> countProperties(String token) async {
    return _handleRequest(
          () => client.get(
        Uri.parse('$baseUrl/proprietes/count'),
        headers: _headers(token),
      ),
          (data) => (data['total_proprietes'] ?? data['count'] ?? data['total'] ?? 0) as int,
    );
  }

  // ✅ Rechercher/Filtrer les propriétés (search)
  Future<List<Property>> searchProperties({
    required String token,
    int? regionId,
    int? departementId,
    int? communeId,
    String? type,
    double? prixMin,
    double? prixMax,
  }) async {
    final queryParams = <String, String>{};

    if (regionId != null) queryParams['region_id'] = regionId.toString();
    if (departementId != null) queryParams['departement_id'] = departementId.toString();
    if (communeId != null) queryParams['commune_id'] = communeId.toString();
    if (type != null && type.isNotEmpty) queryParams['type'] = type;
    if (prixMin != null) queryParams['prix_min'] = prixMin.toString();
    if (prixMax != null) queryParams['prix_max'] = prixMax.toString();

    final uri = Uri.parse('$baseUrl/proprietes/search')
        .replace(queryParameters: queryParams.isNotEmpty ? queryParams : null);

    return _handleRequest(
          () => client.get(uri, headers: _headers(token)),
          (data) {
        final List<dynamic> list = data is List ? data : data['data'] ?? data['proprietes'] ?? [];
        return list.map((json) => Property.fromJson(json)).toList();
      },
    );
  }

  // ========================================
  // 🌍 DONNÉES GÉOGRAPHIQUES
  // ========================================

  // ✅ Récupérer toutes les régions
  Future<List<Region>> getRegions([String? token]) async {
    return _handleRequest(
          () => client.get(
        Uri.parse('$baseUrl/regions'),
        headers: _headers(token),
      ),
          (data) {
        final List<dynamic> list = data is List ? data : data['data'] ?? data['regions'] ?? [];
        return list.map((json) => Region.fromJson(json)).toList();
      },
    );
  }

  // ✅ Récupérer les départements d'une région spécifique
  Future<List<Departement>> getDepartementsByRegion(
      int regionId,
      [String? token]
      ) async {
    return _handleRequest(
          () => client.get(
        Uri.parse('$baseUrl/regions/$regionId/departements'),
        headers: _headers(token),
      ),
          (data) {
        final List<dynamic> list = data is List ? data : data['data'] ?? data['departements'] ?? [];
        return list.map((json) => Departement.fromJson(json)).toList();
      },
    );
  }

  // ✅ Récupérer les communes d'un département spécifique
  Future<List<Commune>> getCommunesByDepartement(
      int departementId,
      [String? token]
      ) async {
    return _handleRequest(
          () => client.get(
        Uri.parse('$baseUrl/departements/$departementId/communes'),
        headers: _headers(token),
      ),
          (data) {
        final List<dynamic> list = data is List ? data : data['data'] ?? data['communes'] ?? [];
        return list.map((json) => Commune.fromJson(json)).toList();
      },
    );
  }

  // 🧹 Nettoyer les ressources
  void dispose() {
    client.close();
  }
}