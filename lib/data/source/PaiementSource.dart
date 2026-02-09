import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/paiements.dart';

class PaiementDataSource {
  // ⚠️ Remplace par ton IP réelle si tu testes sur téléphone physique (ex: 192.168.x.x)
  final String baseUrl = "http://192.168.1.15:8000/api";

  /// Récupère le token stocké
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// Récupère l'historique des paiements pour un bail spécifique
  /// Route Laravel : GET /api/bail/{bailId}/paiements
  Future<List<Paiement>> fetchPaiementsByBail(int bailId) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/bail/$bailId/paiements'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Laravel Resource ::collection renvoie souvent { "data": [...] }
      // On gère les deux cas (avec ou sans "data")
      final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;

      return data.map((json) => Paiement.fromJson(json)).toList();
    } else if (response.statusCode == 403) {
      throw Exception('Accès refusé : Ce bail ne vous appartient pas.');
    } else {
      throw Exception('Erreur chargement paiements: ${response.statusCode}');
    }
  }


  /// Récupère le détail d'un paiement spécifique pour un bail donné
  /// Route Laravel : GET /api/bail/{bailId}/paiements/{id}
  Future<Paiement> fetchDetailPaiement(int bailId, int paiementId) async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/bail/$bailId/paiements/$paiementId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final jsonResponse = json.decode(response.body);

      // Si ta Resource renvoie { "data": {...} } ou directement {...}
      final data = jsonResponse['data'] ?? jsonResponse;

      return Paiement.fromJson(data);
    } else if (response.statusCode == 404) {
      throw Exception('Paiement non trouvé.');
    } else {
      throw Exception('Erreur chargement détail paiement: ${response.statusCode}');
    }
  }

}
