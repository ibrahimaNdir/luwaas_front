import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/model/users.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final firebase_auth.FirebaseAuth _firebaseAuth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;
  String? get userRole => _user?.userType;

  // Register
  Future<void> register({
    required String prenom,
    required String nom,
    required String email,
    required String password,
    required String telephone,
    required String cni,
    String? userType,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1️⃣ Appel à Laravel (retourne user + firebase_token)
      final result = await _repository.register(
        prenom: prenom,
        nom: nom,
        email: email,
        password: password,
        telephone: telephone,
        cni: cni,
        userType: userType,
      );

      _user = result['user'];
      final firebaseToken = result['firebase_token'];

      // 2️⃣ Authentification avec Firebase Auth via Custom Token
      await _signInWithFirebase(firebaseToken);

      // 3️⃣ Maintenant on peut enregistrer le token FCM dans Firestore
      await _saveFCMToken(_user!.id.toString());

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login
  Future<void> login({
    required String login,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // 1️⃣ Appel à Laravel (retourne user + firebase_token)
      final result = await _repository.login(
        login: login,
        password: password,
      );

      _user = result['user'];
      final firebaseToken = result['firebase_token'];

      // 2️⃣ Authentification avec Firebase Auth via Custom Token
      await _signInWithFirebase(firebaseToken);

      // 3️⃣ Maintenant on peut enregistrer le token FCM dans Firestore
      await _saveFCMToken(_user!.id.toString());

      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // 🔐 Méthode privée: Authentification Firebase avec Custom Token
  Future<void> _signInWithFirebase(String customToken) async {
    try {
      await _firebaseAuth.signInWithCustomToken(customToken);
      print('✅ Authentifié avec Firebase Auth');
    } catch (e) {
      print('❌ Erreur Firebase Auth: $e');
      throw Exception('Erreur d\'authentification Firebase: $e');
    }
  }

  // 🔔 Méthode privée: Enregistrer le token FCM dans Firestore
  Future<void> _saveFCMToken(String userId) async {
    try {
      final token = await _messaging.getToken();

      if (token != null) {
        await _firestore
            .collection('device_tokens')
            .doc(userId)  // Utilise l'userId comme document ID
            .set({
          'token': token,
          'timestamp': FieldValue.serverTimestamp(),
          'platform': 'android',  // ou détecte iOS si besoin
        }, SetOptions(merge: true));

        print('✅ Token FCM enregistré dans Firestore');
      }
    } catch (e) {
      print('❌ Erreur enregistrement FCM: $e');
      // N'empêche pas la connexion si l'enregistrement du token échoue
    }
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      await _firebaseAuth.signOut();  // ✅ Déconnexion Firebase aussi
      _user = null;
      _errorMessage = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Check auth status
  Future<void> checkAuthStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final isLoggedIn = await _repository.isLoggedIn();
      if (!isLoggedIn) {
        _user = null;
      }
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }
}
