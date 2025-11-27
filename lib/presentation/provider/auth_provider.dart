import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/model/users.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // Register - CORRIGÉ avec TOUS les paramètres
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
      _user = await _repository.register(
        prenom: prenom,
        nom: nom,
        email: email,
        password: password,
        telephone: telephone,
        cni: cni,
        userType: userType,

      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Login - INCHANGÉ (déjà correct)
  Future<void> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _user = await _repository.login(
        email: email,
        password: password,
      );
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Logout - INCHANGÉ
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
      _user = null;
    } catch (e) {
      _errorMessage = e.toString();
    }

    _isLoading = false;
    notifyListeners();
  }

  // Check auth status - INCHANGÉ
  Future<void> checkAuthStatus() async {
    final isLoggedIn = await _repository.isLoggedIn();
    if (!isLoggedIn) {
      _user = null;
    }
    notifyListeners();
  }
}
