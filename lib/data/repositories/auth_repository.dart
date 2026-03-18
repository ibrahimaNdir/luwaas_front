import 'package:shared_preferences/shared_preferences.dart';
import '../source/auth_remote_source.dart';
import '../model/users.dart';

class AuthRepository {
  final AuthRemoteSource _remoteSource = AuthRemoteSource();

  // ═══════════════════════════════════════════════════════════════
  // REGISTER
  // ═══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> register({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String cni,
    String? userType,
  }) async {
    print("═════════════════════════════════");
    print("🔵 AuthRepository.register() DÉBUT");
    print("═════════════════════════════════");

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

      print("✅ Réponse de _remoteSource:");
      print("  - user: ${response['user']}");
      print("  - token: ${response['token']}");
      print("  - firebase_token présent: ${response['firebase_token'] != null}");

      final userData = response['user'] ?? response['data'] ?? response['userData'];

      if (userData == null) {
        throw Exception("Le champ user est manquant dans la réponse API");
      }

      Map<String, dynamic> userMap = Map<String, dynamic>.from(userData);

      // ✅ Token Laravel
      final token = response['token'] ?? response['access_token'];
      if (token == null) {
        throw Exception("Token manquant dans la réponse API");
      }

      // ✅ Firebase Token
      final firebaseToken = response['firebase_token'];
      if (firebaseToken == null) {
        throw Exception("Firebase token manquant dans la réponse API");
      }

      userMap['token'] = token;
      final user = User.fromJson(userMap);

      // Sauvegarde des tokens
      await _saveToken(token);
      await _saveFirebaseToken(firebaseToken);

      print("✅ Token Laravel sauvegardé");
      print("✅ Firebase token sauvegardé");

      // ✅ Retourne user + token + firebase_token
      final result = {
        'user': user,
        'token': token,
        'firebase_token': firebaseToken,
      };

      print("✅ Result à retourner:");
      print("  - user: ${result['user']}");
      print("  - token: ${result['token']}");
      print("  - firebase_token: ${result['firebase_token'] != null ? 'présent' : 'null'}");
      print("═════════════════════════════════");
      print("🔵 AuthRepository.register() FIN");
      print("═════════════════════════════════");

      return result;
    } catch (e) {
      print("❌ Erreur AuthRepository.register(): $e");
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGIN
  // ═══════════════════════════════════════════════════════════════
  Future<Map<String, dynamic>> login({
    required String login,
    required String password,
  }) async {
    print("═════════════════════════════════");
    print("🔵 AuthRepository.login() DÉBUT");
    print("═════════════════════════════════");

    final responseData = await _remoteSource.login(
      login: login,
      password: password,
    );

    print("✅ Réponse de _remoteSource:");
    print("  - user: ${responseData['user']}");
    print("  - token: ${responseData['token']}");
    print("  - firebase_token présent: ${responseData['firebase_token'] != null}");

    if (responseData['user'] == null) {
      throw Exception("Erreur de connexion : Aucun utilisateur renvoyé.");
    }

    Map<String, dynamic> userMap = Map<String, dynamic>.from(responseData['user']);

    // ✅ Token Laravel
    String? token;
    if (responseData.containsKey('token')) {
      token = responseData['token'];
      userMap['token'] = token;
      await _saveToken(token!);
      print("✅ Token Laravel sauvegardé");
    } else {
      print("⚠️ Pas de token Laravel dans la réponse");
    }

    // ✅ Firebase Token
    final firebaseToken = responseData['firebase_token'];
    if (firebaseToken == null) {
      throw Exception("Firebase token manquant dans la réponse API");
    }

    await _saveFirebaseToken(firebaseToken);
    print("✅ Firebase token sauvegardé");

    final user = User.fromJson(userMap);

    // ✅ Retourne user + token + firebase_token
    final result = {
      'user': user,
      'token': token,
      'firebase_token': firebaseToken,
    };

    print("✅ Result à retourner:");
    print("  - user: ${result['user']}");
    print("  - token: ${result['token']}");
    print("  - firebase_token: ${result['firebase_token'] != null ? 'présent' : 'null'}");
    print("═════════════════════════════════");
    print("🔵 AuthRepository.login() FIN");
    print("═════════════════════════════════");

    return result;
  }

  // ═══════════════════════════════════════════════════════════════
  // LOGOUT
  // ═══════════════════════════════════════════════════════════════
  Future<void> logout() async {
    try {
      final token = await _getToken();
      if (token != null) {
        await _remoteSource.logout(token);
      }
      await _deleteToken();
      await _deleteFirebaseToken();
      print("✅ Déconnexion réussie");
    } catch (e) {
      print("❌ Erreur logout: $e");
      rethrow;
    }
  }

  // ═══════════════════════════════════════════════════════════════
  // TOKEN STORAGE (Laravel)
  // ═══════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════
  // FIREBASE TOKEN STORAGE
  // ═══════════════════════════════════════════════════════════════
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

  // ═══════════════════════════════════════════════════════════════
  // HELPERS
  // ═══════════════════════════════════════════════════════════════
  Future<bool> isLoggedIn() async {
    final token = await _getToken();
    return token != null;
  }
}
