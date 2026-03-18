import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../model/demande.dart';

class DemandeDataSource {
  final String baseUrl = "http://192.168.1.5:8000/api";

  /// Récupérer le token d'authentification
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  /// ✅ 1. RÉCUPÉRER LES DEMANDES DU PROPRIÉTAIRE (demandes reçues)
  Future<List<Demande>> fetchDemandesProprietaire() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/proprietaire/demandes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;

      return data.map((json) => Demande.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement demandes propriétaire: ${response.statusCode}');
    }
  }

  /// ✅ 2. RÉCUPÉRER LES DEMANDES DU LOCATAIRE (demandes envoyées)
  Future<List<Demande>> fetchDemandesLocataire() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/locataire/demandes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? jsonResponse;

      return data.map((json) => Demande.fromJson(json)).toList();
    } else {
      throw Exception('Erreur chargement demandes locataire: ${response.statusCode}');
    }
  }

  /// ✅ 3. CRÉER UNE DEMANDE (Locataire)
  Future<bool> createDemande(int logementId) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/locataire/demandes'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'logement_id': logementId,
      }),
    );

    if (response.statusCode == 201) {
      print("✅ Demande créée avec succès !");
      return true;
    } else if (response.statusCode == 409) {
      print("⚠️ Demande déjà existante");
      throw Exception('Vous avez déjà une demande en cours pour ce logement.');
    } else {
      print("❌ Erreur création demande: ${response.body}");
      throw Exception('Impossible de créer la demande.');
    }
  }

  /// ✅ 4. ACCEPTER UNE DEMANDE (Propriétaire)
  Future<bool> accepterDemande(int demandeId) async {
    final token = await _getToken();

    final response = await http.post(  // ✅ POST, pas PATCH
      Uri.parse('$baseUrl/proprietaire/demandes/$demandeId/accepter'),  // ✅ Route complète
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("✅ Demande $demandeId acceptée");
      return true;
    } else {
      print("❌ Erreur acceptation: ${response.body}");
      return false;
    }
  }

  /// ✅ 5. REFUSER UNE DEMANDE (Propriétaire)
  Future<bool> refuserDemande(int demandeId) async {
    final token = await _getToken();

    final response = await http.post(  // ✅ POST, pas PATCH
      Uri.parse('$baseUrl/proprietaire/demandes/$demandeId/refuser'),  // ✅ Route complète
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      body: json.encode({
        'raison': 'Demande refusée',  // ✅ Raison par défaut
      }),
    );

    if (response.statusCode == 200) {
      print("✅ Demande $demandeId refusée");
      return true;
    } else {
      print("❌ Erreur refus: ${response.body}");
      return false;
    }
  }

  /// ✅ 6. ANNULER UNE DEMANDE (Locataire)
  Future<bool> annulerDemande(int demandeId) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/locataire/demandes/$demandeId/annuler'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      print("✅ Demande $demandeId annulée");
      return true;
    } else {
      print("❌ Erreur annulation: ${response.body}");
      return false;
    }
  }
}