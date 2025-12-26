
import '../../data/source/paiement_data_source.dart';
import '../model/paiementbailleurs.dart'; // Assure-toi que le nom du fichier est bon


class PaiementBailleurRepository {
  final PaiementDataSource dataSource;

  PaiementBailleurRepository({required this.dataSource});

  Future<List<PaiementBailleur>> getPaiementsBailleur() {
    return dataSource.fetchPaiementsBailleur();
  }
}
