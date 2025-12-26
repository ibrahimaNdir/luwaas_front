import 'package:flutter/material.dart';

import '../../data/repositories/DemandeRepository.dart';
import '../../data/model/demande.dart';

class DemandeProvider with ChangeNotifier {

  String? _error; // La variable privée
  String? get error => _error; // Le getter public
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
  DemandeProvider({required this.repository});

  /// 1. Charger les demandes depuis le serveur
  Future<void> fetchDemandesBailleur() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Notifie l'UI d'afficher le loader

    try {
      _demandes = await repository.getDemandes();
    } catch (e) {
      _errorMessage = "Impossible de charger les demandes. Vérifiez votre connexion.";
      print(e);
    } finally {
      _isLoading = false;
      notifyListeners(); // Notifie l'UI que c'est fini
    }
  }

  /// 2. Action : Accepter une demande
  Future<void> accepterDemande(int demandeId) async {
    // Optimistic Update : On pourrait changer l'état tout de suite,
    // mais on va attendre la confirmation serveur pour être sûr.

    final success = await repository.accepterDemande(demandeId);

    if (success) {
      // On met à jour la liste locale manuellement pour éviter de rappeler l'API
      final index = _demandes.indexWhere((d) => d.id == demandeId);
      if (index != -1) {
        // On remplace l'ancienne demande par une copie avec le nouveau statut
        // Note: Comme nos champs sont 'final', on doit recréer l'objet ou le modifier si non final.
        // Ici, méthode simple : on recharge la liste ou on bidouille la liste.
        // Le plus propre : recharger la liste pour avoir les données fraîches.
        // fetchDemandes();

        // Méthode rapide (si on veut éviter le chargement) :
        // Il faudrait que DemandeLocation ait une méthode copyWith ou ne soit pas immuable.
        // Pour faire simple ici : on recharge tout.
        await fetchDemandesBailleur();
      }
    } else {
      _errorMessage = "Erreur lors de l'acceptation.";
      notifyListeners();
    }
  }

  /// 3. Action : Refuser une demande
  Future<void> refuserDemande(int demandeId) async {
    final success = await repository.refuserDemande(demandeId);

    if (success) {
      // On recharge la liste pour voir la demande disparaître ou changer d'état
      await fetchDemandesBailleur();
    } else {
      _errorMessage = "Erreur lors du refus.";
      notifyListeners();
    }
  }

  /// ✅ 2. Créer une demande (POST) - C'EST CE QU'IL MANQUAIT !
  Future<bool> createDemande(int logementId) async {
    _error = null; // Reset
    try {
      final success = await repository.createDemande(logementId);
      if (success) {
        return true;
      } else {
        // ✅ CORRECTION : Remplir _error au lieu de _errorMessage
        _error = "Le serveur n'a pas validé la demande (vérifiez si déjà demandée).";
        notifyListeners(); // Important pour notifier l'UI
        return false;
      }
    } catch (e) {
      _error = e.toString(); // ✅ Ça c'est bon
      notifyListeners();
      return false;
    }
  }


  // Petit bonus : Getter pour avoir seulement les demandes en attente (pour le Badge par exemple)
  int get countEnAttente => _demandes.where((d) => d.status == 'en_attente').length;
}
