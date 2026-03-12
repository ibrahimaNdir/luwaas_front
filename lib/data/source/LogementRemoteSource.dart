// lib/data/source/logement_remote_source.dart
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:luwaas/data/model/photos.dart';
import '../model/logements.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LogementRemoteDataSource {
  late final Dio dio;

  // Base URL de ton API Laravel
  static const String _baseUrl = 'http://192.168.1.8:8000/api';

  LogementRemoteDataSource() {
    dio = Dio(
      BaseOptions(
        baseUrl: _baseUrl,
        headers: {
          'Accept': 'application/json',
        },
        connectTimeout: const Duration(seconds: 60),
        receiveTimeout: const Duration(seconds: 60),
      ),
    );

    // ✅ ON A ACTIVÉ L'INTERCEPTEUR ICI
    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        // 1. On récupère l'instance des préférences
        final prefs = await SharedPreferences.getInstance();

        // 2. On récupère le token (Vérifie que tu l'as bien enregistré sous le nom 'token' au login)
        final token = prefs.getString('auth_token'); // ou 'access_token' selon ton code de login

        // 3. Si le token existe, on l'injecte dans la requête
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
          print("🔑 Token ajouté : Bearer ${token.substring(0, 5)}..."); // Petit log pour vérifier
        } else {
          print("⚠️ Attention : Aucun token trouvé dans le téléphone !");
        }

        return handler.next(options);
      },
      // Optionnel : Pour voir les erreurs API dans la console
      onError: (DioException e, handler) {
        if (e.response?.statusCode == 401) {
          print(" Erreur 401 : Non autorisé. Le token est peut-être expiré.");
        }
        return handler.next(e);
      },
    ));
  }

  /// ==========================
  ///  PROPRIÉTAIRE
  /// ==========================

  /// Créer un logement pour une propriété donnée
  /// POST /api/proprietaire/proprietes/{proprieteId}/logements
  Future<Logement> createLogement(Logement logement) async {
    try {
      final response = await dio.post(
        '/proprietaire/proprietes/${logement.proprieteId}/logements',
        data: logement.toJson(),
      );

      return Logement.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de la création du logement');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Ajouter des photos à un logement
  /// POST /api/proprietaire/proprietes/{proprieteId}/logements/{logementId}/photos
  Future<List<Photo>> addPhotos({
    required int proprieteId,
    required int logementId,
    required List<File> files,
  }) async {
    try {
      final formData = FormData();

      for (final file in files) {
        formData.files.add(
          MapEntry(
            'photos[]',
            await MultipartFile.fromFile(
              file.path,
              filename: file.path.split('/').last,
            ),
          ),
        );
      }

      final response = await dio.post(
        '/proprietaire/proprietes/$proprieteId/logements/$logementId/photos',
        data: formData,
        options: Options(
          contentType: 'multipart/form-data',
        ),
      );

      final List photosData = response.data['photos'] ?? [];
      return photosData.map((e) => Photo.fromJson(e)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de l\'ajout des photos');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupérer tous les logements d'une propriété
  /// GET /api/proprietaire/proprietes/{proprieteId}/logements
  Future<List<Logement>> getLogementsByPropriete(int proprieteId) async {
    try {
      final response = await dio.get(
        '/proprietaire/proprietes/$proprieteId/logements',
      );

      final dynamic body = response.data;

      List<dynamic> data;
      if (body is List) {
        data = body;
      } else if (body is Map && body.containsKey('data')) {
        data = body['data'];
      } else {
        data = []; // Cas de secours si format inconnu
      }

      return data.map((json) => Logement.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de la récupération');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Récupérer tous les logements publiés du propriétaire
  /// GET /api/proprietaire/mes-logements/publies
  Future<List<Logement>> getMesLogementsPublies() async {
    try {
      final response = await dio.get(
        '/proprietaire/mes-logements/publies',
      );

      // ✅ Gère les deux cas : List directe OU Map avec 'data'
      final dynamic body = response.data;

      List<dynamic> data;
      if (body is List) {
        data = body;
      } else if (body is Map && body.containsKey('data')) {
        data = body['data'];
      } else {
        data = [];
      }

      return data.map((json) => Logement.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de la récupération');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }


  /// Mettre à jour le statut de publication d'un logement
  /// PATCH /api/proprietaire/proprietes/{proprieteId}/logements/{id}/status
  Future<Logement> updateStatusPublication({
    required int proprieteId,
    required int logementId,
    required String statut, // 'brouillon' ou 'publie'
  }) async {
    try {
      final response = await dio.patch(
        '/proprietaire/proprietes/$proprieteId/logements/$logementId/status',
        data: {'statut_publication': statut},
      );

      return Logement.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de la mise à jour');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Mettre à jour un logement
  /// PUT /api/proprietaire/proprietes/{proprieteId}/logements/{id}
  Future<Logement> updateLogement({
    required int proprieteId,
    required int logementId,
    required Logement logement,
  }) async {
    try {
      final response = await dio.put(
        '/proprietaire/proprietes/$proprieteId/logements/$logementId',
        data: logement.toJson(),
      );

      return Logement.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de la mise à jour');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Supprimer un logement
  /// DELETE /api/proprietaire/proprietes/{proprieteId}/logements/{id}
  Future<void> deleteLogement({
    required int proprieteId,
    required int logementId,
  }) async {
    try {
      await dio.delete(
        '/proprietaire/proprietes/$proprieteId/logements/$logementId',
      );
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de la suppression');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// ==========================
  ///  LOCATAIRE
  /// ==========================

  /// Récupérer tous les logements liés au locataire connecté
  /// GET /api/locataire/logements
  Future<List<Logement>> getLogementsLocataire() async {
    try {
      final response = await dio.get(
        '/locataire/logements',
      );

      final body = response.data;
      final List data =
      body is Map<String, dynamic> ? (body['data'] ?? []) : body as List;

      return data.map((json) => Logement.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(e.response?.data['message'] ??
            'Erreur lors de la récupération des logements locataire');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Rechercher des logements à proximité (pour locataire)
  /// GET /api/logements/nearby (route publique)
  Future<List<Logement>> searchNearby({
    required double lat,
    required double lng,
    double radius = 10,
  }) async {
    try {
      print("═════════════════════════════════════");
      print("📍 RECHERCHE PROXIMITÉ");
      print("🌐 URL: $_baseUrl/logements/nearby");
      print("📊 Lat: $lat, Lng: $lng, Rayon: $radius km");
      print("═════════════════════════════════════");

      final response = await dio.get(
        '/logements/nearby',
        queryParameters: {
          'lat': lat,
          'lng': lng,
          'radius': radius,
        },
      );

      print("✅ Réponse reçue !");
      print("📦 Status: ${response.statusCode}");
      print("📦 Type: ${response.data.runtimeType}");

      // ✅ CORRECTION : Gérer le format {data: [...]}
      final dynamic body = response.data;

      List<dynamic> data;
      if (body is List) {
        // Format direct: [...]
        data = body;
      } else if (body is Map && body.containsKey('data')) {
        // Format enveloppe: {data: [...]}
        data = body['data'] as List;
      } else {
        print("❌ Format inconnu: $body");
        return [];
      }

      print("📊 ${data.length} logements trouvés");

      if (data.isEmpty) {
        print("⚠️ Aucun logement dans ce rayon");
        return [];
      }

      final logements = data.map((json) {
        try {
          return Logement.fromJson(json);
        } catch (e) {
          print("❌ Erreur parsing: $e");
          print("📄 JSON: $json");
          rethrow;
        }
      }).toList();

      print("✅ ${logements.length} logements parsés");
      print("═════════════════════════════════════");

      return logements;
    } on DioException catch (e) {
      print("═════════════════════════════════════");
      print("❌ ERREUR DIO (searchNearby)");
      print("Status: ${e.response?.statusCode}");
      print("Message: ${e.response?.data}");
      print("═════════════════════════════════════");

      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de la recherche');
      }
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      print("❌ ERREUR INATTENDUE (searchNearby): $e");
      rethrow;
    }
  }

  /// Rechercher des logements par zone (pour locataire)
  /// GET /api/logements/search (route publique)
  Future<List<Logement>> searchByZone({
    int? regionId,
    int? departementId,
    int? communeId,
    String? typelogement,
    bool? meuble,
    int? nombrePieces,
    double? prixMax,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (regionId != null) queryParams['region_id'] = regionId;
      if (departementId != null) queryParams['departement_id'] = departementId;
      if (communeId != null) queryParams['commune_id'] = communeId;
      if (typelogement != null) queryParams['typelogement'] = typelogement;
      if (meuble != null) queryParams['meuble'] = meuble ? 1 : 0;
      if (nombrePieces != null) queryParams['nombre_pieces'] = nombrePieces;
      if (prixMax != null) queryParams['prix_max'] = prixMax;

      print("═════════════════════════════════════");
      print("🔍 RECHERCHE LOGEMENTS PAR ZONE");
      print("🌐 URL: $_baseUrl/logements/search");
      print("📊 Params: $queryParams");
      print("═════════════════════════════════════");

      final response = await dio.get(
        '/logements/search',
        queryParameters: queryParams,
      );

      print("✅ Réponse reçue !");
      print("📦 Status: ${response.statusCode}");
      print("📦 Type: ${response.data.runtimeType}");

      // ✅ CORRECTION : Gérer le format {data: [...]}
      final dynamic body = response.data;

      List<dynamic> data;
      if (body is List) {
        // Format direct: [...]
        data = body;
      } else if (body is Map && body.containsKey('data')) {
        // Format enveloppe: {data: [...]}
        data = body['data'] as List;
        print("📦 Extraction depuis la clé 'data'");
      } else {
        print("❌ Format inconnu: $body");
        return [];
      }

      print("📊 ${data.length} logements trouvés");

      if (data.isEmpty) {
        print("⚠️ Liste vide retournée par l'API");
        print("💡 Vérifiez si des logements existent pour ces critères");
        return [];
      }

      final logements = data.map((json) {
        try {
          return Logement.fromJson(json);
        } catch (e) {
          print("❌ Erreur parsing logement: $e");
          print("📄 JSON problématique: $json");
          rethrow;
        }
      }).toList();

      print("✅ ${logements.length} logements parsés avec succès");
      print("═════════════════════════════════════");

      return logements;
    } on DioException catch (e) {
      print("═════════════════════════════════════");
      print("❌ ERREUR DIO (searchByZone)");
      print("Status: ${e.response?.statusCode}");
      print("Message: ${e.response?.data}");
      print("Type: ${e.type}");
      print("═════════════════════════════════════");

      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de la recherche');
      }
      throw Exception('Erreur réseau: ${e.message}');
    } catch (e) {
      print("═════════════════════════════════════");
      print("❌ ERREUR INATTENDUE (searchByZone)");
      print("Type: ${e.runtimeType}");
      print("Message: $e");
      print("═════════════════════════════════════");
      rethrow;
    }
  }

  /// ==========================
  ///  OUTILS PROPRIÉTAIRE
  /// ==========================

  /// Rechercher des logements (pour propriétaire)
  /// GET /api/proprietaire/logements/search
  Future<List<Logement>> searchLogements({
    int? proprieteId,
    String? statutOccupe,
    String? typelogement,
  }) async {
    try {
      final queryParams = <String, dynamic>{};
      if (proprieteId != null) queryParams['propriete_id'] = proprieteId;
      if (statutOccupe != null) queryParams['statut_occupe'] = statutOccupe;
      if (typelogement != null) queryParams['typelogement'] = typelogement;

      final response = await dio.get(
        '/proprietaire/logements/search',
        queryParameters: queryParams,
      );

      final List data = response.data;
      return data.map((json) => Logement.fromJson(json)).toList();
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors de la recherche');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }

  /// Compter les logements d'une propriété
  /// GET /api/proprietaire/proprietes/{proprieteId}/logements/count
  Future<int> countByPropriete(int proprieteId) async {
    try {
      final response = await dio.get(
        '/proprietaire/proprietes/$proprieteId/logements/count',
      );

      return response.data['total'] ?? 0;
    } on DioException catch (e) {
      if (e.response != null) {
        throw Exception(
            e.response?.data['message'] ?? 'Erreur lors du comptage');
      }
      throw Exception('Erreur réseau: ${e.message}');
    }
  }
}
