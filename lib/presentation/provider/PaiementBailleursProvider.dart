import 'package:flutter/cupertino.dart';

import '../../data/model/paiementbailleurs.dart';
import '../../data/repositories/paiementBailleursRepository.dart';

class PaiementBailleurProvider extends ChangeNotifier {
  final PaiementBailleurRepository repository;

  PaiementBailleurProvider(this.repository);

  List<PaiementBailleur> paiements = [];
  bool isLoading = false;
  String? errorMessage;

  Future<void> loadPaiementsBailleur() async { // 🔹 plus de token ici
    isLoading = true;
    errorMessage = null;
    notifyListeners();

    try {
      paiements = await repository.getPaiementsBailleur(); // 🔹 sans param
    } catch (e) {
      errorMessage = e.toString();
    }

    isLoading = false;
    notifyListeners();
  }
}
