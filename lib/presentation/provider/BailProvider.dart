import 'package:flutter/material.dart';
import '../../data/repositories/bail_repository.dart';
import '../../data/model/bails.dart';

class BailProvider with ChangeNotifier {
  final BailRepository repository;

  // --- ÉTATS POUR LA CRÉATION (bailleur) ---
  bool _isCreating = false;
  String? _error;

  // --- ÉTATS POUR LA LISTE BAILLEUR ---
  List<Bail> _bauxBailleur = [];
  bool _isLoadingBauxBailleur = false;

  // --- ÉTATS POUR LA LISTE LOCATAIRE ---
  List<Bail> _bauxLocataire = [];
  bool _isLoadingBauxLocataire = false;

  // --- ÉTATS POUR DÉTAIL BAIL ---
  Bail? _bailDetail;
  bool _isLoadingDetail = false;

  // --- GETTERS ---
  bool get isCreating => _isCreating;
  String? get error => _error;

  List<Bail> get bauxBailleur => _bauxBailleur;
  bool get isLoadingBauxBailleur => _isLoadingBauxBailleur;

  List<Bail> get bauxLocataire => _bauxLocataire;
  bool get isLoadingBauxLocataire => _isLoadingBauxLocataire;

  Bail? get bailDetail => _bailDetail;
  bool get isLoadingDetail => _isLoadingDetail;

  // ✅ GETTERS STATISTIQUES
  int get countBauxActifsBailleur =>
      _bauxBailleur.where((b) => b.statut == 'actif').length;

  int get countBauxActifsLocataire =>
      _bauxLocataire.where((b) => b.statut == 'actif').length;

  BailProvider({required this.repository});

  // ══════════════════════════════════════════════════════════
  // CRÉER UN BAIL (BAILLEUR)
  // ══════════════════════════════════════════════════════════
  Future<bool> createBail({
    required int demandeId,
    required int montantLoyer,
    required int nombreMoisCaution,
    required int chargesMensuelles,
    required DateTime dateDebut,
    required DateTime dateFin,
    required int jourEcheance,
    required bool renouvellementAuto,
  }) async {
    print("═════════════════════════════════");
    print("🔵 BailProvider.createBail DÉBUT");
    print("═════════════════════════════════");

    _isCreating = true;
    _error = null;
    notifyListeners();

    final Map<String, dynamic> data = {
      'demande_id': demandeId,
      'montant_loyer': montantLoyer,
      'charges_mensuelles': chargesMensuelles,
      'nombre_mois_caution': nombreMoisCaution,
      'date_debut': dateDebut.toIso8601String().split('T')[0],
      'date_fin': dateFin.toIso8601String().split('T')[0],
      'jour_echeance': jourEcheance,
      'renouvellement_automatique': renouvellementAuto,
    };

    print("📤 Données envoyées:");
    print(data);

    try {
      await repository.createBail(data);

      print("✅ Bail créé avec succès");
      _isCreating = false;
      _error = null;
      notifyListeners();

      // ✅ Recharger la liste des baux
      print("🔄 Rechargement de la liste des baux...");
      await fetchBauxBailleur();

      print("═════════════════════════════════");
      print("✅ BailProvider.createBail FIN");
      print("═════════════════════════════════");

      return true;
    } catch (e, stackTrace) {
      print("❌ Erreur création bail: $e");
      print("❌ StackTrace: $stackTrace");

      _isCreating = false;
      _error = e.toString().replaceAll('Exception: ', '');
      notifyListeners();

      print("═════════════════════════════════");
      print("❌ BailProvider.createBail ÉCHEC");
      print("═════════════════════════════════");

      return false;
    }
  }

  // ══════════════════════════════════════════════════════════
  // LISTER LES BAUX DU BAILLEUR
  // ══════════════════════════════════════════════════════════
  Future<void> fetchBauxBailleur() async {
    print("═════════════════════════════════");
    print("🔵 BailProvider.fetchBauxBailleur DÉBUT");
    print("═════════════════════════════════");

    _isLoadingBauxBailleur = true;
    _error = null;
    notifyListeners();

    try {
      _bauxBailleur = await repository.getBauxBailleur();

      print("✅ Baux bailleur récupérés: ${_bauxBailleur.length}");

      if (_bauxBailleur.isNotEmpty) {
        print("📋 Premier bail:");
        print("  - ID: ${_bauxBailleur[0].id}");
        print("  - Statut: ${_bauxBailleur[0].statut}");
        print("  - Locataire: ${_bauxBailleur[0].locataire}");
        print("  - Logement: ${_bauxBailleur[0].logement}");
      }

      _error = null;
    } catch (e, stackTrace) {
      print("❌ Erreur fetchBauxBailleur: $e");
      print("❌ StackTrace: $stackTrace");

      _error = "Impossible de charger les baux";
      _bauxBailleur = [];
    } finally {
      _isLoadingBauxBailleur = false;
      notifyListeners();

      print("═════════════════════════════════");
      print("🔵 BailProvider.fetchBauxBailleur FIN");
      print("═════════════════════════════════");
    }
  }

  // ══════════════════════════════════════════════════════════
  // LISTER LES BAUX DU LOCATAIRE
  // ══════════════════════════════════════════════════════════
  Future<void> fetchBauxLocataire() async {
    print("═════════════════════════════════");
    print("🔵 BailProvider.fetchBauxLocataire DÉBUT");
    print("═════════════════════════════════");

    _isLoadingBauxLocataire = true;
    _error = null;
    notifyListeners();

    try {
      _bauxLocataire = await repository.getBauxLocataire();

      print("✅ Baux locataire récupérés: ${_bauxLocataire.length}");

      if (_bauxLocataire.isNotEmpty) {
        print("📋 Premier bail:");
        print("  - ID: ${_bauxLocataire[0].id}");
        print("  - Statut: ${_bauxLocataire[0].statut}");
        print("  - Logement: ${_bauxLocataire[0].logement}");
      }

      _error = null;
    } catch (e, stackTrace) {
      print("❌ Erreur fetchBauxLocataire: $e");
      print("❌ StackTrace: $stackTrace");

      _error = "Impossible de charger les baux";
      _bauxLocataire = [];
    } finally {
      _isLoadingBauxLocataire = false;
      notifyListeners();

      print("═════════════════════════════════");
      print("🔵 BailProvider.fetchBauxLocataire FIN");
      print("═════════════════════════════════");
    }
  }

  // ══════════════════════════════════════════════════════════
  // RÉCUPÉRER LES DÉTAILS D'UN BAIL
  // ══════════════════════════════════════════════════════════
  Future<void> fetchBailDetail(int bailId) async {
    print("═════════════════════════════════");
    print("🔵 BailProvider.fetchBailDetail DÉBUT");
    print("🔵 Bail ID: $bailId");
    print("═════════════════════════════════");

    _isLoadingDetail = true;
    _error = null;
    notifyListeners();

    try {
      _bailDetail = await repository.getBailDetail(bailId);

      print("✅ Détail bail récupéré:");
      print("  - ID: ${_bailDetail!.id}");
      print("  - Statut: ${_bailDetail!.statut}");

      _error = null;
    } catch (e, stackTrace) {
      print("❌ Erreur fetchBailDetail: $e");
      print("❌ StackTrace: $stackTrace");

      _error = "Impossible de charger les détails du bail";
      _bailDetail = null;
    } finally {
      _isLoadingDetail = false;
      notifyListeners();

      print("═════════════════════════════════");
      print("🔵 BailProvider.fetchBailDetail FIN");
      print("═════════════════════════════════");
    }
  }

  // ══════════════════════════════════════════════════════════
  // UTILITAIRES
  // ══════════════════════════════════════════════════════════

  /// Nettoyer les erreurs
  void clearError() {
    _error = null;
    notifyListeners();
  }

  /// Rafraîchir les données selon le rôle
  Future<void> refresh({bool isBailleur = false}) async {
    if (isBailleur) {
      await fetchBauxBailleur();
    } else {
      await fetchBauxLocataire();
    }
  }

  /// Récupérer un bail par ID depuis la liste en cache
  Bail? getBailById(int id, {bool fromBailleur = false}) {
    final liste = fromBailleur ? _bauxBailleur : _bauxLocataire;
    try {
      return liste.firstWhere((bail) => bail.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Filtrer les baux par statut
  List<Bail> getBauxByStatut(String statut, {bool fromBailleur = false}) {
    final liste = fromBailleur ? _bauxBailleur : _bauxLocataire;
    return liste.where((bail) => bail.statut == statut).toList();
  }

  /// Réinitialiser le provider
  void reset() {
    _bauxBailleur = [];
    _bauxLocataire = [];
    _bailDetail = null;
    _error = null;
    _isCreating = false;
    _isLoadingBauxBailleur = false;
    _isLoadingBauxLocataire = false;
    _isLoadingDetail = false;
    notifyListeners();
  }
}