import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart'; // Pour récupérer le token
import '../model/demande.dart';

class DemandeDataSource {
  // Remplace par ton URL de base (ex: http://10.0.2.2:8000/api pour simulateur Android)
  final String baseUrl = "http://192.168.1.8:8000/api";

  // Méthode utilitaire pour récupérer le Token stocké (Sanctum)
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token'); // Assure-toi que tu stockes le token sous cette clé à la connexion
  }

  // 1. Récupérer les demandes du Bailleur connecté
  Future<List<Demande>> fetchDemandesBailleur() async {
    final token = await _getToken();

    final response = await http.get(
      Uri.parse('$baseUrl/proprietaire/demandes'), // La route qu'on a définie dans api.php
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      // Laravel renvoie souvent { "data": [...] } via les Resources
      final Map<String, dynamic> jsonResponse = json.decode(response.body);
      final List<dynamic> data = jsonResponse['data'] ?? jsonResponse; // Sécurité si pas de clé 'data'

      return data.map((json) => Demande.fromJson(json)).toList();
    } else {
      throw Exception('Erreur lors du chargement des demandes: ${response.statusCode}');
    }
  }

  // 2. Accepter une demande
  Future<bool> accepterDemande(int demandeId) async {
    final token = await _getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/demandes/$demandeId/accepter'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Erreur acceptation: ${response.body}");
      return false;
    }
  }

  // 3. Refuser une demande
  Future<bool> refuserDemande(int demandeId) async {
    final token = await _getToken();

    final response = await http.patch(
      Uri.parse('$baseUrl/demandes/$demandeId/refuser'),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      print("Erreur refus: ${response.body}");
      return false;
    }
  }

  // 4. Créer une nouvelle demande (Pour LOCATAIRE)
  Future<bool> createDemande(int logementId) async {
    final token = await _getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/locataire/demandes'), // Correspond à Route::post('/demandes', ...)
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json', // Important pour le POST
        'Accept': 'application/json',
      },
      body: json.encode({
        'logement_id': logementId, // On envoie UNIQUEMENT l'ID du logement
      }),
    );

    if (response.statusCode == 201) {
      // 201 = Created (Succès)
      print("Demande créée avec succès !");
      return true;
    } else if (response.statusCode == 409) {
      // 409 = Conflict (Déjà demandé)
      print("Erreur: Vous avez déjà une demande en cours pour ce logement.");
      throw Exception('Vous avez déjà demandé ce logement.');
    } else {
      print("Erreur création demande: ${response.body}");
      throw Exception('Impossible de créer la demande. Vérifiez votre connexion.');
    }
  }

}
