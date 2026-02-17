import 'package:flutter/material.dart';

import '../../data/repositories/DemandeRepository.dart';
import '../../data/model/demande.dart';

class DemandeProvider with ChangeNotifier {

  String? _error;
  String? get error => _error;
  final DemandeRepository repository;

  // États
  List<Demande> _demandes = [];
  bool _isLoading = false;
  String? _errorMessage;

  // Getters pour l'UI
  List<Demande> get demandes => _demandes;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Constructeur
  DemandeProvider({required this.repository}) {
    print("🏗️ DemandeProvider créé");
  }

  /// 1. Charger les demandes depuis le serveur
  Future<void> fetchDemandesBailleur() async {
    print("🔄 DemandeProvider - fetchDemandesBailleur début");
    print("   _isLoading avant: $_isLoading");

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    print("   _isLoading après: $_isLoading (notifyListeners appelé)");

    try {
      print("📡 Appel repository.getDemandes()...");
      _demandes = await repository.getDemandes();
      print("✅ ${_demandes.length} demande(s) récupérée(s)");

      // Debug : afficher les IDs des demandes
      for (var demande in _demandes) {
        print("   - Demande ID: ${demande.id}, Status: ${demande.status}");
      }

    } catch (e) {
      _errorMessage = "Impossible de charger les demandes. Vérifiez votre connexion.";
      print("❌ Erreur fetchDemandesBailleur: $e");
    } finally {
      _isLoading = false;
      print("🏁 fetchDemandesBailleur terminé - _isLoading: $_isLoading");
      notifyListeners();
    }
  }

  /// 2. Action : Accepter une demande
  Future<void> accepterDemande(int demandeId) async {
    print("✅ DemandeProvider - accepterDemande($demandeId)");

    final success = await repository.accepterDemande(demandeId);

    if (success) {
      print("✅ Demande $demandeId acceptée - Rechargement de la liste...");
      await fetchDemandesBailleur();
    } else {
      _errorMessage = "Erreur lors de l'acceptation.";
      print("❌ Échec acceptation demande $demandeId");
      notifyListeners();
    }
  }

  /// 3. Action : Refuser une demande
  Future<void> refuserDemande(int demandeId) async {
    print("❌ DemandeProvider - refuserDemande($demandeId)");

    final success = await repository.refuserDemande(demandeId);

    if (success) {
      print("✅ Demande $demandeId refusée - Rechargement de la liste...");
      await fetchDemandesBailleur();
    } else {
      _errorMessage = "Erreur lors du refus.";
      print("❌ Échec refus demande $demandeId");
      notifyListeners();
    }
  }

  /// 4. Créer une demande (POST)
  Future<bool> createDemande(int logementId) async {
    print("➕ DemandeProvider - createDemande($logementId)");

    _error = null;
    try {
      final success = await repository.createDemande(logementId);
      if (success) {
        print("✅ Demande créée avec succès pour logement $logementId");
        return true;
      } else {
        _error = "Le serveur n'a pas validé la demande (vérifiez si déjà demandée).";
        print("⚠️ $_error");
        notifyListeners();
        return false;
      }
    } catch (e) {
      _error = e.toString();
      print("❌ Erreur création demande: $_error");
      notifyListeners();
      return false;
    }
  }

  // Getter pour avoir seulement les demandes en attente (pour le Badge)
  int get countEnAttente {
    final count = _demandes.where((d) => d.status == 'en_attente').length;
    print("🔢 countEnAttente: $count");
    return count;
  }
}