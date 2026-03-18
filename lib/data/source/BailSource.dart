import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/bails.dart';
import '../model/bailspaiement.dart';


class BailDataSource {
  final String baseUrl = "http://192.168.1.5:8000/api"; // Ton URL API

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Crée un nouveau bail
  /// Retourne l'objet Bail créé si succès, sinon lève une exception
  Future<Bail> createBail(Map<String, dynamic> bailData) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/proprietaire/bails'), // POST /api/baux
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: jsonEncode(bailData),
    );

    if (response.statusCode == 201) {
      final jsonResponse = json.decode(response.body);
      // Selon ton controlleur Laravel : return response()->json(['bail' => $bail], 201);
      return Bail.fromJson(jsonResponse['bail']);
    } else {
      // Gestion d'erreur (ex: validation Laravel échouée)
      throw Exception('Erreur création bail: ${response.body}');
    }
  }

  // Dans BailDataSource


  Future<List<Bail>> fetchBauxBailleur() async {
    print("═════════════════════════════════");
    print("🔵 DÉBUT fetchBauxBailleur");
    print("═════════════════════════════════");

    final token = await _getToken();

    // ✅ VÉRIFIER LE TOKEN
    if (token == null) {
      print("❌ TOKEN EST NULL !");
      throw Exception('Token manquant - Utilisateur non connecté');
    }

    print("✅ Token présent: ${token.substring(0, 20)}...");

    final url = '$baseUrl/proprietaire/baux';
    print("🔵 URL: $url");

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/json',
        },
      );

      print("🔵 Status Code: ${response.statusCode}");

      if (response.statusCode == 200) {
        print("✅ Réponse OK");
        print("🔵 Body (premiers 500 chars): ${response.body.substring(0, response.body.length > 500 ? 500 : response.body.length)}");

        final jsonResponse = json.decode(response.body);
        print("🔵 Type de jsonResponse: ${jsonResponse.runtimeType}");

        // Laravel Resource renvoie souvent { "data": [...] }
        final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;
        print("🔵 Type de data: ${data.runtimeType}");
        print("✅ Nombre de baux trouvés: ${data.length}");

        if (data.isEmpty) {
          print("⚠️ La liste est vide !");
          return [];
        }

        final baux = data.map((json) {
          print("  → Parsing bail ID: ${json['id']}");
          return Bail.fromJson(json);
        }).toList();

        print("✅ Baux parsés avec succès: ${baux.length}");
        return baux;

      } else if (response.statusCode == 401) {
        print("❌ ERREUR 401: Non authentifié");
        print("❌ Body: ${response.body}");
        throw Exception('Non authentifié - Token invalide ou expiré');
      } else {
        print("❌ ERREUR ${response.statusCode}");
        print("❌ Body: ${response.body}");
        throw Exception('Erreur chargement baux: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print("❌ EXCEPTION: $e");
      print("❌ StackTrace: $stackTrace");
      rethrow;
    } finally {
      print("═════════════════════════════════");
      print("🔵 FIN fetchBauxBailleur");
      print("═════════════════════════════════");
    }
  }


  /// Récupère la liste des baux du LOCATAIRE connecté (pour le paiement)
  /// Appelle GET /api/bailpaie
  // ✅ MODIFICATION ICI : On renvoie des vrais 'Bail'
  Future<List<Bail>> fetchBauxLocataire() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/locataire/baux'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;

      // ✅ MODIFICATION ICI : On utilise Bail.fromJson
      return data.map((json) => Bail.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement baux locataire: ${response.statusCode}');
    }
  }




  Future<Bail> fetchBailDetail(int id) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/bail/$id'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);
      // Laravel Resource renvoie souvent { "data": {...} }
      final data = jsonResponse['data'] ?? jsonResponse;
      return Bail.fromJson(data);
    } else {
      throw Exception('Erreur chargement détail bail: ${response.statusCode}');
    }
  }





}
