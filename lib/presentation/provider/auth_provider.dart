
import 'package:luwaas/services/fcm_service.dart';
import 'package:flutter/material.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/model/users.dart';

class AuthProvider extends ChangeNotifier {
  final AuthRepository _repository = AuthRepository();
  final FcmService _fcmService = FcmService();

  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  // ✅ Getter pour récupérer le rôle de l'utilisateur
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
      _user = await _repository.register(
        prenom: prenom,
        nom: nom,
        email: email,
        password: password,
        telephone: telephone,
        cni: cni,
        userType: userType,
      );
      _errorMessage = null;

      if (_user?.telephone != null && _user!.telephone!.isNotEmpty) {
        await _fcmService.saveTokenForPhone(_user!.telephone!);
        _fcmService.listenTokenRefresh(_user!.telephone!);
      }
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
      _user = await _repository.login(
        login: login,
        password: password,
      );
      _errorMessage = null;
      if (_user?.telephone != null && _user!.telephone!.isNotEmpty) {
        await _fcmService.saveTokenForPhone(_user!.telephone!);
        _fcmService.listenTokenRefresh(_user!.telephone!);
      }
    } catch (e) {
      _errorMessage = e.toString();
      _user = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Logout
  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _repository.logout();
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