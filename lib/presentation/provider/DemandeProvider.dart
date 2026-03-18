import 'package:flutter/material.dart';
import '../../data/repositories/DemandeRepository.dart';
import '../../data/model/demande.dart';

class DemandeProvider with ChangeNotifier {
  final DemandeRepository repository;

  // États
  List<Demande> _demandes = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Demande> get demandes => _demandes;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Constructeur
  DemandeProvider({required this.repository}) {
    debugPrint("🏗️ DemandeProvider créé");
  }

  /// ✅ 1. CHARGER LES DEMANDES DU PROPRIÉTAIRE (demandes reçues)
  Future<void> fetchDemandesProprietaire() async {
    debugPrint("═════════════════════════════════");
    debugPrint("🔵 DÉBUT fetchDemandesProprietaire");
    debugPrint("═════════════════════════════════");

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("📡 Appel repository.getDemandesProprietaire()...");
      _demandes = await repository.getDemandesProprietaire();
      debugPrint("✅ ${_demandes.length} demande(s) récupérée(s)");

      // Debug : afficher les demandes
      for (var demande in _demandes) {
        debugPrint("  → Demande ID: ${demande.id}, Status: ${demande.status}");
      }
    } catch (e, stackTrace) {
      _error = "Impossible de charger les demandes.";
      debugPrint("❌ ERREUR fetchDemandesProprietaire: $e");
      debugPrint("❌ StackTrace: $stackTrace");
    } finally {
      _isLoading = false;
      debugPrint("═════════════════════════════════");
      debugPrint("🔵 FIN fetchDemandesProprietaire - isLoading: $_isLoading");
      debugPrint("═════════════════════════════════");
      notifyListeners();
    }
  }

  /// ✅ 2. CHARGER LES DEMANDES DU LOCATAIRE (demandes envoyées)
  Future<void> fetchDemandesLocataire() async {
    debugPrint("═════════════════════════════════");
    debugPrint("🔵 DÉBUT fetchDemandesLocataire");
    debugPrint("═════════════════════════════════");

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint("📡 Appel repository.getDemandesLocataire()...");
      _demandes = await repository.getDemandesLocataire();
      debugPrint("✅ ${_demandes.length} demande(s) récupérée(s)");

      for (var demande in _demandes) {
        debugPrint("  → Demande ID: ${demande.id}, Status: ${demande.status}");
      }
    } catch (e, stackTrace) {
      _error = "Impossible de charger vos demandes.";
      debugPrint("❌ ERREUR fetchDemandesLocataire: $e");
      debugPrint("❌ StackTrace: $stackTrace");
    } finally {
      _isLoading = false;
      debugPrint("═════════════════════════════════");
      debugPrint("🔵 FIN fetchDemandesLocataire - isLoading: $_isLoading");
      debugPrint("═════════════════════════════════");
      notifyListeners();
    }
  }

  /// ✅ 3. ACCEPTER UNE DEMANDE (Propriétaire)
  Future<bool> accepterDemande(int demandeId) async {
    debugPrint("✅ DemandeProvider - accepterDemande($demandeId)");

    try {
      final success = await repository.accepterDemande(demandeId);

      if (success) {
        debugPrint("✅ Demande $demandeId acceptée - Rechargement...");
        await fetchDemandesProprietaire();
        return true;
      } else {
        _error = "Erreur lors de l'acceptation.";
        debugPrint("❌ Échec acceptation demande $demandeId");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Erreur: ${e.toString()}";
      debugPrint("❌ Exception accepterDemande: $e");
      notifyListeners();
      return false;
    }
  }

  /// ✅ 4. REFUSER UNE DEMANDE (Propriétaire)
  Future<bool> refuserDemande(int demandeId) async {
    debugPrint("❌ DemandeProvider - refuserDemande($demandeId)");

    try {
      final success = await repository.refuserDemande(demandeId);

      if (success) {
        debugPrint("✅ Demande $demandeId refusée - Rechargement...");
        await fetchDemandesProprietaire();
        return true;
      } else {
        _error = "Erreur lors du refus.";
        debugPrint("❌ Échec refus demande $demandeId");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Erreur: ${e.toString()}";
      debugPrint("❌ Exception refuserDemande: $e");
      notifyListeners();
      return false;
    }
  }

  /// ✅ 5. CRÉER UNE DEMANDE (Locataire)
  Future<bool> createDemande(int logementId) async {
    debugPrint("➕ DemandeProvider - createDemande($logementId)");

    _error = null;

    try {
      final success = await repository.createDemande(logementId);

      if (success) {
        debugPrint("✅ Demande créée avec succès pour logement $logementId");
        return true;
      } else {
        _error = "Impossible de créer la demande (déjà existante ?).";
        debugPrint("⚠️ $_error");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Erreur: ${e.toString()}";
      debugPrint("❌ Exception createDemande: $e");
      notifyListeners();
      return false;
    }
  }

  /// ✅ 6. ANNULER UNE DEMANDE (Locataire)
  Future<bool> annulerDemande(int demandeId) async {
    debugPrint("🚫 DemandeProvider - annulerDemande($demandeId)");

    try {
      final success = await repository.annulerDemande(demandeId);

      if (success) {
        debugPrint("✅ Demande $demandeId annulée - Rechargement...");
        await fetchDemandesLocataire();
        return true;
      } else {
        _error = "Impossible d'annuler cette demande.";
        debugPrint("❌ Échec annulation demande $demandeId");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = "Erreur: ${e.toString()}";
      debugPrint("❌ Exception annulerDemande: $e");
      notifyListeners();
      return false;
    }
  }

  /// ✅ GETTERS UTILES

  // Nombre de demandes en attente (pour badge)
  int get countEnAttente {
    final count = _demandes.where((d) => d.status == 'en_attente').length;
    debugPrint("🔢 countEnAttente: $count");
    return count;
  }

  // Demandes acceptées (pour le dropdown dans FormulaireBailScreen)
  List<Demande> get demandesAcceptees {
    return _demandes.where((d) => d.status == 'acceptee').toList();
  }

  // Nombre de demandes acceptées
  int get countAcceptees {
    return demandesAcceptees.length;
  }
}