import 'package:flutter/material.dart';
import '../../data/model/paiements.dart';
import '../../data/repositories/PaiementRepository.dart';

class PaiementProvider with ChangeNotifier {
  final PaiementRepository repository;

  // --- ÉTATS ---
  List<Paiement> _paiements = [];
  bool _isLoading = false;
  String? _error;

  Paiement? _currentPaiement;
  bool _isLoadingDetail = false;

  // --- GETTERS ---
  List<Paiement> get paiements => _paiements;
  bool get isLoading => _isLoading;
  String? get error => _error;
  Paiement? get currentPaiement => _currentPaiement;
  bool get isLoadingDetail => _isLoadingDetail;

  // ✅ GETTERS UTILES
  int get countPaiements => _paiements.length;
  int get countPayes => _paiements.where((p) => p.statut.toLowerCase() == 'paye' || p.statut.toLowerCase() == 'payé').length;
  int get countImpayes => _paiements.where((p) => p.statut.toLowerCase() == 'impaye' || p.statut.toLowerCase() == 'impayé').length;

  // Constructeur
  PaiementProvider({required this.repository});

  /// Charge les paiements pour un bail donné
  Future<void> fetchPaiements(int bailId) async {
    print("═════════════════════════════════");
    print("🔵 PaiementProvider.fetchPaiements DÉBUT");
    print("🔵 Bail ID: $bailId");
    print("═════════════════════════════════");

    _isLoading = true;
    _error = null;
    _paiements = [];
    notifyListeners();

    try {
      _paiements = await repository.getPaiementsByBail(bailId);

      print("✅ Paiements récupérés: ${_paiements.length}");

      if (_paiements.isNotEmpty) {
        print("📋 Premier paiement:");
        print("  - ID: ${_paiements[0].id}");
        print("  - Période: ${_paiements[0].periode}");
        print("  - Statut: ${_paiements[0].statut}");
        print("  - Montant: ${_paiements[0].montantAttendu}");
      }

      _error = null;
    } catch (e, stackTrace) {
      print("❌ Erreur fetchPaiements: $e");
      print("❌ StackTrace: $stackTrace");

      _error = "Impossible de charger l'historique.";
      _paiements = [];
    } finally {
      _isLoading = false;
      notifyListeners();

      print("═════════════════════════════════");
      print("🔵 PaiementProvider.fetchPaiements FIN");
      print("═════════════════════════════════");
    }
  }

  /// Charge le détail d'un paiement spécifique
  Future<void> fetchDetailPaiement(int bailId, int paiementId) async {
    print("═════════════════════════════════");
    print("🔵 PaiementProvider.fetchDetailPaiement DÉBUT");
    print("🔵 Bail ID: $bailId");
    print("🔵 Paiement ID: $paiementId");
    print("═════════════════════════════════");

    _isLoadingDetail = true;
    _error = null;
    _currentPaiement = null;
    notifyListeners();

    try {
      _currentPaiement = await repository.getDetailPaiement(bailId, paiementId);

      print("✅ Détail paiement récupéré:");
      print("  - ID: ${_currentPaiement!.id}");
      print("  - Période: ${_currentPaiement!.periode}");
      print("  - Statut: ${_currentPaiement!.statut}");

      _error = null;
    } catch (e, stackTrace) {
      print("❌ Erreur fetchDetailPaiement: $e");
      print("❌ StackTrace: $stackTrace");

      _error = "Impossible de charger le détail du paiement.";
      _currentPaiement = null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();

      print("═════════════════════════════════");
      print("🔵 PaiementProvider.fetchDetailPaiement FIN");
      print("═════════════════════════════════");
    }
  }

  /// Nettoyer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Réinitialiser le provider
  void reset() {
    _paiements = [];
    _currentPaiement = null;
    _error = null;
    _isLoading = false;
    _isLoadingDetail = false;
    notifyListeners();
  }
}