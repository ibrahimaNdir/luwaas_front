import '../model/bails.dart';
import '../model/bailspaiement.dart'; // <-- modèle léger pour paiement
import '../source/BailSource.dart';


class BailRepository {
  final BailDataSource dataSource;

  BailRepository({required this.dataSource});

  /// Création d'un bail (bailleur)
  Future<Bail?> createBail(Map<String, dynamic> data) async {
    try {
      return await dataSource.createBail(data);
    } catch (e) {
      print("Erreur Repo Bail (createBail): $e");
      rethrow;
    }
  }

  /// Liste des baux du bailleur connecté
  Future<List<Bail>> getBauxBailleur() async {
    try {
      return await dataSource.fetchBauxBailleur();
    } catch (e) {
      print("Erreur Repo Bail (getBauxBailleur): $e");
      rethrow;
    }
  }

  /// Liste des baux du locataire (pour écran Payer loyer)

  // ✅ MODIFICATION ICI : On renvoie des vrais 'Bail'
  Future<List<Bail>> getBauxLocataire() async {
    try {
      return await dataSource.fetchBauxLocataire();
    } catch (e) {
      print("Erreur Repo Bail (getBauxLocataire): $e");
      rethrow;
    }
  }


  /// Détail d'un bail (si tu as fetchBailDetail dans le DataSource)
  Future<Bail> getBailDetail(int id) async {
    try {
      return await dataSource.fetchBailDetail(id);
    } catch (e) {
      print("Erreur Repo Bail (getBailDetail): $e");
      rethrow;
    }
  }
}
