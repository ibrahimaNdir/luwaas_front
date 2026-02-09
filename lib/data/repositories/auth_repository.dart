import 'package:shared_preferences/shared_preferences.dart';
import '../source/auth_remote_source.dart';
import '../model/users.dart';

class AuthRepository {
  final AuthRemoteSource _remoteSource = AuthRemoteSource();

  // REGISTER
  Future<Map<String, dynamic>> register({  // ✅ CHANGEMENT: retourne Map au lieu de User
    required String prenom,
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String cni,
    String? userType,
  }) async {
    try {
      final response = await _remoteSource.register(
        prenom: prenom,
        nom: nom,
        email: email,
        password: password,
        telephone: telephone,
        cni: cni,
        userType: userType,
      );

      final userData = response['user'] ?? response['data'] ?? response['userData'];

      if (userData == null) {
        throw Exception("Le champ user est manquant dans la réponse API");
      }

      Map<String, dynamic> userMap = Map<String, dynamic>.from(userData);

      // Token Laravel
      final token = response['token'] ?? response['access_token'];
      if (token == null) {
        throw Exception("Token manquant dans la réponse API");
      }

      // ✅ AJOUT: Firebase Token
      final firebaseToken = response['firebase_token'];
      if (firebaseToken == null) {
        throw Exception("Firebase token manquant dans la réponse API");
      }

      userMap['token'] = token;
      final user = User.fromJson(userMap);

      // Sauvegarde des tokens
      await _saveToken(token);
      await _saveFirebaseToken(firebaseToken);  // ✅ NOUVEAU

      // ✅ NOUVEAU: Retourne user + firebase_token
      return {
        'user': user,
        'firebase_token': firebaseToken,
      };
    } catch (e) {
      rethrow;
    }
  }

  // LOGIN
  Future<Map<String, dynamic>> login({  // ✅ CHANGEMENT: retourne Map au lieu de User
    required String login,
    required String password,
  }) async {
    final responseData = await _remoteSource.login(
      login: login,
      password: password,
    );

    if (responseData['user'] == null) {
      throw Exception("Erreur de connexion : Aucun utilisateur renvoyé.");
    }

    Map<String, dynamic> userMap = Map<String, dynamic>.from(responseData['user']);

    // Token Laravel
    if (responseData.containsKey('token')) {
      final token = responseData['token'];
      userMap['token'] = token;
      await _saveToken(token);
    }

    // ✅ AJOUT: Firebase Token
    final firebaseToken = responseData['firebase_token'];
    if (firebaseToken == null) {
      throw Exception("Firebase token manquant dans la réponse API");
    }

    await _saveFirebaseToken(firebaseToken);  // ✅ NOUVEAU

    final user = User.fromJson(userMap);

    // ✅ NOUVEAU: Retourne user + firebase_token
    return {
      'user': user,
      'firebase_token': firebaseToken,
    };
  }

  // LOGOUT
  Future<void> logout() async {
    try {
      final token = await _getToken();
      if (token != null) {
        await _remoteSource.logout(token);
      }
      await _deleteToken();
      await _deleteFirebaseToken();  // ✅ NOUVEAU
    } catch (e) {
      rethrow;
    }
  }

  // TOKEN STORAGE (Laravel)
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

  // ✅ NOUVEAU: FIREBASE TOKEN STORAGE
  Future<void> _saveFirebaseToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('firebase_token', token);
  }

  Future<String?> getFirebaseToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('firebase_token');
  }

  Future<void> _deleteFirebaseToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('firebase_token');
  }

  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }
}
