import 'package:flutter/material.dart';
import '../../data/repositories/bail_repository.dart';
import '../../data/model/bails.dart';
// Note: On n'utilise plus bailspaiement.dart

class BailProvider with ChangeNotifier {
  final BailRepository repository;

  // --- ÉTATS POUR LA CRÉATION (bailleur) ---
  bool _isCreating = false;
  String? _error;

  // --- ÉTATS POUR LA LISTE BAILLEUR ---
  List<Bail> _bauxBailleur = [];
  bool _isLoadingBauxBailleur = false;

  // --- ÉTATS POUR LA LISTE LOCATAIRE (Pour l'écran Payer loyer / Accueil) ---
  List<Bail> _bauxLocataire = [];
  bool _isLoadingBauxLocataire = false;

  // --- GETTERS ---
  bool get isCreating => _isCreating;
  String? get error => _error;

  List<Bail> get bauxBailleur => _bauxBailleur;
  bool get isLoadingBauxBailleur => _isLoadingBauxBailleur;

  List<Bail> get bauxLocataire => _bauxLocataire;
  bool get isLoadingBauxLocataire => _isLoadingBauxLocataire;

  BailProvider({required this.repository});

  /// 1. CRÉER UN BAIL (BAILLEUR)
  Future<bool> createBail({
    required int logementId,
    required int locataireId,
    required int? demandeId,
    required int montantLoyer,
    required int caution,
    required int charges,
    required int cautionsPayer,
    required DateTime dateDebut,
    required DateTime dateFin,
    required int jourEcheance,
    required bool renouvellementAuto,
  }) async {
    _isCreating = true;
    _error = null;
    notifyListeners();

    final Map<String, dynamic> data = {
      'logement_id': logementId,
      'locataire_id': locataireId,
      'demande_id': demandeId,
      'montant_loyer': montantLoyer,
      'caution': caution,
      'charges_mensuelles': charges,
      'cautions_a_payer': cautionsPayer,
      'date_debut': dateDebut.toIso8601String().split('T')[0],
      'date_fin': dateFin.toIso8601String().split('T')[0],
      'jour_echeance': jourEcheance,
      'renouvellement_automatique': renouvellementAuto,
    };

    try {
      await repository.createBail(data);
      _isCreating = false;
      notifyListeners();

      // Après création, on recharge la liste bailleur
      fetchBauxBailleur();

      return true;
    } catch (e) {
      _isCreating = false;
      _error = "Erreur: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  /// 2. LISTER LES BAUX DU BAILLEUR
  Future<void> fetchBauxBailleur() async {
    debugPrint("🔵 Début fetchBauxBailleur");
    _isLoadingBauxBailleur = true;
    _error = null;
    notifyListeners();

    try {
      _bauxBailleur = await repository.getBauxBailleur();
      debugPrint("✅ Baux récupérés: ${_bauxBailleur.length} éléments");

      // Affichez le premier bail pour vérifier
      if (_bauxBailleur.isNotEmpty) {
        debugPrint("Premier bail: ${_bauxBailleur[0].locataire}");
      }
    } catch (e) {
      _error = "Impossible de charger les baux bailleur.";
      debugPrint("❌ Erreur Provider fetchBauxBailleur: $e");
    } finally {
      _isLoadingBauxBailleur = false;
      debugPrint("🔵 Fin fetchBauxBailleur - isLoading: $_isLoadingBauxBailleur");
      notifyListeners();
    }
  }


  /// 3. LISTER LES BAUX DU LOCATAIRE (Écran Accueil / Payer)
  /// Récupère maintenant des objets 'Bail' complets avec montant_loyer
  Future<void> fetchBauxLocataire() async {
    _isLoadingBauxLocataire = true;
    _error = null;
    notifyListeners();

    try {
      _bauxLocataire = await repository.getBauxLocataire();
    } catch (e) {
      _error = "Impossible de charger les baux locataire.";
      print("Erreur Provider fetchBauxLocataire: $e");
    } finally {
      _isLoadingBauxLocataire = false;
      notifyListeners();
    }
  }
}
