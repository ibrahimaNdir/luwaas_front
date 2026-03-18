import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/paiements.dart';

class PaiementDataSource {
  final String baseUrl = "http://192.168.1.5:8000/api";

  /// Récupère le token stocké
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Récupère l'historique des paiements pour un bail spécifique
  /// Route Laravel : GET /api/baux/{bailId}/paiements
  Future<List<Paiement>> fetchPaiementsByBail(int bailId) async {
    print("═════════════════════════════════");
    print("🔵 fetchPaiementsByBail DÉBUT");
    print("🔵 Bail ID: $bailId");
    print("═════════════════════════════════");

    final token = await _getToken();

    if (token == null) {
      print("❌ Token manquant");
      throw Exception('Token manquant - Utilisateur non connecté');
    }

    print("✅ Token présent");

    final url = '$baseUrl/baux/$bailId/paiements';
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
      print("🔵 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Laravel Resource ::collection renvoie { "data": [...] }
        final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;

        print("✅ Nombre de paiements trouvés: ${data.length}");

        // ✅ CORRECTION : Aplatir la structure
        // Le backend retourne [[{...}], [{...}]] au lieu de [{...}, {...}]
        final paiements = data.map((item) {
          // Si item est un tableau, prendre le premier élément
          if (item is List && item.isNotEmpty) {
            return Paiement.fromJson(item[0] as Map<String, dynamic>);
          }
          // Sinon, traiter comme objet direct
          return Paiement.fromJson(item as Map<String, dynamic>);
        }).toList();

        print("✅ Paiements parsés avec succès");
        print("═════════════════════════════════");
        print("🔵 fetchPaiementsByBail FIN");
        print("═════════════════════════════════");

        return paiements;
      } else if (response.statusCode == 403) {
        print("❌ Erreur 403: Accès refusé");
        throw Exception('Accès refusé : Ce bail ne vous appartient pas.');
      } else {
        print("❌ Erreur ${response.statusCode}");
        throw Exception('Erreur chargement paiements: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print("❌ Exception fetchPaiementsByBail: $e");
      print("❌ StackTrace: $stackTrace");
      rethrow;
    }
  }

  /// Récupère le détail d'un paiement spécifique pour un bail donné
  /// Route Laravel : GET /api/baux/{bailId}/paiements/{id}
  Future<Paiement> fetchDetailPaiement(int bailId, int paiementId) async {
    print("═════════════════════════════════");
    print("🔵 fetchDetailPaiement DÉBUT");
    print("🔵 Bail ID: $bailId");
    print("🔵 Paiement ID: $paiementId");
    print("═════════════════════════════════");

    final token = await _getToken();

    if (token == null) {
      print("❌ Token manquant");
      throw Exception('Token manquant - Utilisateur non connecté');
    }

    final url = '$baseUrl/baux/$bailId/paiements/$paiementId';
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
      print("🔵 Response Body: ${response.body}");

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);

        // Si ta Resource renvoie { "data": {...} } ou directement {...}
        final data = jsonResponse['data'] ?? jsonResponse;

        final paiement = Paiement.fromJson(data);

        print("✅ Paiement parsé avec succès");
        print("═════════════════════════════════");
        print("🔵 fetchDetailPaiement FIN");
        print("═════════════════════════════════");

        return paiement;
      } else if (response.statusCode == 404) {
        print("❌ Erreur 404: Paiement non trouvé");
        throw Exception('Paiement non trouvé.');
      } else {
        print("❌ Erreur ${response.statusCode}");
        throw Exception('Erreur chargement détail paiement: ${response.statusCode}');
      }
    } catch (e, stackTrace) {
      print("❌ Exception fetchDetailPaiement: $e");
      print("❌ StackTrace: $stackTrace");
      rethrow;
    }
  }
}