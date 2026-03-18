import '../model/demande.dart';
import '../source/DemandeSource.dart';

class DemandeRepository {
  final DemandeDataSource dataSource;

  DemandeRepository({required this.dataSource});

  /// ✅ 1. RÉCUPÉRER LES DEMANDES DU PROPRIÉTAIRE (demandes reçues)
  Future<List<Demande>> getDemandesProprietaire() async {
    try {
      return await dataSource.fetchDemandesProprietaire();
    } catch (e) {
      print("❌ Erreur Repository (getDemandesProprietaire): $e");
      rethrow;
    }
  }

  /// ✅ 2. RÉCUPÉRER LES DEMANDES DU LOCATAIRE (demandes envoyées)
  Future<List<Demande>> getDemandesLocataire() async {
    try {
      return await dataSource.fetchDemandesLocataire();
    } catch (e) {
      print("❌ Erreur Repository (getDemandesLocataire): $e");
      rethrow;
    }
  }

  /// ✅ 3. CRÉER UNE DEMANDE (Locataire)
  Future<bool> createDemande(int logementId) async {
    try {
      return await dataSource.createDemande(logementId);
    } catch (e) {
      print("❌ Erreur Repository (createDemande): $e");
      rethrow;
    }
  }

  /// ✅ 4. ACCEPTER UNE DEMANDE (Propriétaire)
  Future<bool> accepterDemande(int id) async {
    try {
      return await dataSource.accepterDemande(id);
    } catch (e) {
      print("❌ Erreur Repository (accepterDemande): $e");
      return false;
    }
  }

  /// ✅ 5. REFUSER UNE DEMANDE (Propriétaire)
  Future<bool> refuserDemande(int id) async {
    try {
      return await dataSource.refuserDemande(id);
    } catch (e) {
      print("❌ Erreur Repository (refuserDemande): $e");
      return false;
    }
  }

  /// ✅ 6. ANNULER UNE DEMANDE (Locataire)
  Future<bool> annulerDemande(int id) async {
    try {
      return await dataSource.annulerDemande(id);
    } catch (e) {
      print("❌ Erreur Repository (annulerDemande): $e");
      return false;
    }
  }
}