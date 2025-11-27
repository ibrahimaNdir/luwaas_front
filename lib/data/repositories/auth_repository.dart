import 'package:shared_preferences/shared_preferences.dart';
import '../source/auth_remote_source.dart';
import '../model/users.dart';

class AuthRepository {
  final AuthRemoteSource _remoteSource = AuthRemoteSource();

  // Register
  Future<User> register({
    required String prenom,
    required String email,
    required String nom ,
    required String password,
    required String telephone ,
    required String cni, String? userType

  }) async {
    try {
      final response = await _remoteSource.register(
        prenom: prenom,
        nom: nom,
        email: email,
        password: password,
        telephone: telephone,   // ajouté
        cni: cni,
        userType: userType
      );

      final user = User.fromJson(response['user']);
      final token = response['token'];

      // Sauvegarder le token
      await _saveToken(token);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _remoteSource.login(
        email : email,
        password: password,
      );

      final user = User.fromJson(response['user']);
      final token = response['token'];

      // Sauvegarder le token
      await _saveToken(token);

      return user;
    } catch (e) {
      rethrow;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      final token = await _getToken();
      if (token != null) {
        await _remoteSource.logout(token);
      }
      await _deleteToken();
    } catch (e) {
      rethrow;
    }
  }

  // Sauvegarder le token localement
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  // Récupérer le token
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  // Supprimer le token
  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  // Vérifier si l'utilisateur est connecté
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }
}