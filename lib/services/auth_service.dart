import 'dart:convert';
import 'package:http/http.dart' as http;

class AuthService {
  static const String baseUrl = "http://localhost:8000/api";

  Future<http.Response> register(Map<String, dynamic> signupData) async {
    final url = Uri.parse("$baseUrl/register/");
    return await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(signupData),
    );
  }
}
