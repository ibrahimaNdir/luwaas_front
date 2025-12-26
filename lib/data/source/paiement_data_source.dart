

import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/model/paiementbailleurs.dart';


class PaiementDataSource {
  final http.Client client;
  final String baseUrl;

  PaiementDataSource({
    http.Client? client,
    String? baseUrl,
  })  : client = client ?? http.Client(),
        baseUrl = baseUrl ?? 'http://192.168.1.33:8000/api';

  Future<List<PaiementBailleur>> fetchPaiementsBailleur() async { // Retirer l'argument token ici
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('auth_token'); // Récupère le token stocké

    if (token == null) {
      throw Exception('Aucun token trouvé, utilisateur non connecté');
    }

    final url = Uri.parse('$baseUrl/proprietaire/paiements/');

    final response = await client.get(
      url,
      headers: {
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final decoded = jsonDecode(response.body);

      // Si tu utilises une Resource Laravel -> les données sont dans 'data'
      final List list = decoded is List ? decoded : (decoded['data'] as List);

      return list
          .map((e) => PaiementBailleur.fromJson(e as Map<String, dynamic>))
          .toList();
    } else {
      throw Exception('Erreur chargement paiements bailleur: ${response.statusCode}');
    }
  }

}
