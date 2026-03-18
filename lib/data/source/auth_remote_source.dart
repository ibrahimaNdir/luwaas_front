import 'package:http/http.dart' as http;
import 'dart:convert';

class AuthRemoteSource {
  final String baseUrl = 'http://192.168.1.5:8000/api';



  // Register - MODIFIÉ pour inclure TOUS les paramètres
  Future<Map<String, dynamic>> register({
    required String nom,
    required String email,
    required String password,
    required String prenom,
    required String telephone,
    required String cni,
    String? userType,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'prenom': prenom,
        'nom': nom,
        'email': email,
        'telephone': telephone,
        'password': password,
        'user_type': userType,
        'cni': cni,
      }),
    );

    if (response.statusCode == 200 || response.statusCode == 201) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Erreur lors de l\'inscription: ${response.body}');
    }
  }

  // Login - CORRECTION du paramètre 'login' → 'email'
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'login': login,  // ✅ Changé de 'login' → 'email'
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Email ou mot de passe incorrect: ${response.body}');
    }
  }

  // Logout - INCHANGÉ
  Future<void> logout(String token) async {
    final response = await http.post(
      Uri.parse('$baseUrl/logout'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Erreur lors de la déconnexion');
    }
  }
}
