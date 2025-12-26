import 'package:flutter/material.dart';
import '../../data/model/paiements.dart';
import '../../data/repositories/PaiementRepository.dart';

class PaiementProvider with ChangeNotifier {
  final PaiementRepository repository;

  // --- ÉTATS ---
  List<Paiement> _paiements = [];
  bool _isLoading = false;
  String? _error;

  // --- GETTERS ---
  List<Paiement> get paiements => _paiements;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Paiement? _currentPaiement;
  bool _isLoadingDetail = false;


  Paiement? get currentPaiement => _currentPaiement;
  bool get isLoadingDetail => _isLoadingDetail;

  // Constructeur
  PaiementProvider({required this.repository});

  /// Charge les paiements pour un bail donné
  Future<void> fetchPaiements(int bailId) async {
    _isLoading = true;
    _error = null;
    // On vide la liste précédente pour ne pas afficher de vieux résultats pendant le chargement
    _paiements = [];
    notifyListeners();

    try {
      _paiements = await repository.getPaiementsByBail(bailId);
    } catch (e) {
      _error = "Impossible de charger l'historique.";
      print("Erreur Provider fetchPaiements: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  //Charge le détail d'un paiement spécifique
  Future<void> fetchDetailPaiement(int bailId, int paiementId) async {
    _isLoadingDetail = true;
    _error = null;
    _currentPaiement = null; // Reset avant chargement
    notifyListeners();

    try {
      _currentPaiement = await repository.getDetailPaiement(bailId, paiementId);
    } catch (e) {
      _error = "Impossible de charger le détail du paiement.";
      print("Erreur Provider fetchDetailPaiement: $e");
    } finally {
      _isLoadingDetail = false;
      notifyListeners();
    }
  }
}
