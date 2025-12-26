import '../../data/model/paiements.dart';

import '../../data/source/PaiementSource.dart'; // Assure-toi que le nom du fichier est bon

class PaiementRepository {
  final PaiementDataSource dataSource;

  PaiementRepository({required this.dataSource});

  /// Récupère la liste des paiements pour un bail donné
  Future<List<Paiement>> getPaiementsByBail(int bailId) async {
    try {
      return await dataSource.fetchPaiementsByBail(bailId);
    } catch (e) {
      print("Erreur Repo Paiement (getPaiementsByBail): $e");
      rethrow; // On renvoie l'erreur pour que le Provider puisse l'afficher
    }
  }


  /// Récupère le détail d'un paiement spécifique
  Future<Paiement> getDetailPaiement(int bailId, int paiementId) async {
    try {
      return await dataSource.fetchDetailPaiement(bailId, paiementId);
    } catch (e) {
      print("Erreur Repo Paiement (getDetailPaiement): $e");
      rethrow;
    }
  }

}
