

import 'package:luwaas/data/model/photos.dart';
import '../model/demande.dart';
import '../source/DemandeSource.dart';



class DemandeRepository {
  final DemandeDataSource dataSource;

  // Injection de dépendance simple via le constructeur
  DemandeRepository({required this.dataSource});

  Future<bool> createDemande(int logementId) async {
    try {
      return await dataSource.createDemande(logementId);
    } catch (e) {
      print("Erreur Repository (createDemande): $e");
      rethrow; // On renvoie l'erreur pour afficher le message précis (ex: "Déjà demandé")
    }
  }

  /// Récupère la liste des demandes depuis l'API
  Future<List<Demande>> getDemandes() async {
    try {
      return await dataSource.fetchDemandesBailleur();
    } catch (e) {
      // Tu peux loguer l'erreur ici ou la renvoyer telle quelle
      print("Erreur Repository (getDemandes): $e");
      rethrow; // On renvoie l'erreur pour que le Provider puisse l'afficher (Toast/Snackbar)
    }
  }

  /// Accepte une demande
  Future<bool> accepterDemande(int id) async {
    try {
      return await dataSource.accepterDemande(id);
    } catch (e) {
      print("Erreur Repository (accepterDemande): $e");
      return false;
    }
  }

  /// Refuse une demande
  Future<bool> refuserDemande(int id) async {
    try {
      return await dataSource.refuserDemande(id);
    } catch (e) {
      print("Erreur Repository (refuserDemande): $e");
      return false;
    }
  }
}
