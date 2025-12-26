import 'package:shared_preferences/shared_preferences.dart';
import '../source/auth_remote_source.dart';
import '../model/users.dart';

class AuthRepository {
  final AuthRemoteSource _remoteSource = AuthRemoteSource();

  // REGISTER
  Future<User> register({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String cni,
    String? userType,
  }) async {
    try {
      // 1. Appel à l'API via la source distante
      final response = await _remoteSource.register(
        prenom: prenom,
        nom: nom,
        email: email,
        password: password,
        telephone: telephone,
        cni: cni,
        userType: userType,
      );

      // 2. Extraction des données utilisateur
      // On utilise Map<String, dynamic>.from pour s'assurer qu'on peut modifier l'objet
      final userData = response['user'] ?? response['data'] ?? response['userData'];

      if (userData == null) {
        throw Exception("Le champ user est manquant dans la réponse API");
      }

      Map<String, dynamic> userMap = Map<String, dynamic>.from(userData);

      // 3. Extraction du token
      final token = response['token'] ?? response['access_token'];

      if (token == null) {
        throw Exception("Token manquant dans la réponse API");
      }

      // 4. Injection du token DANS les données de l'utilisateur
      // C'est ça qui permet à ton User.fromJson de fonctionner correctement
      userMap['token'] = token;

      // 5. Création de l'objet User complet
      final user = User.fromJson(userMap);

      // 6. Sauvegarde locale du token (SharedPreferences ou SecureStorage)
      await _saveToken(token);

      return user;
    } catch (e) {
      rethrow; // On renvoie l'erreur pour que le Provider l'affiche
    }
  }


  // LOGIN
  // LOGIN SÉCURISÉ
  Future<User> login({
    required String login,
    required String password,
  }) async {
    final responseData = await _remoteSource.login(
      login: login,
      password: password,
    );

    // Petite sécurité : vérifie que 'user' existe bien
    if (responseData['user'] == null) {
      throw Exception("Erreur de connexion : Aucun utilisateur renvoyé.");
    }

    Map<String, dynamic> userMap = Map<String, dynamic>.from(responseData['user']);

    if (responseData.containsKey('token')) {
      final token = responseData['token'];
      userMap['token'] = token;
      await _saveToken(token);
    }

    return User.fromJson(userMap);
  }


  // LOGOUT
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

  // TOKEN STORAGE
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('auth_token');
  }

  Future<void> _deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }
}
