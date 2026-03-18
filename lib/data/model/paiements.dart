class Paiement {
  final int id;
  final int? locataireId;      // ✅ Nullable car absent du JSON
  final int? bailId;           // ✅ Nullable car absent du JSON
  final double montantAttendu; // ✅ double au lieu de int
  final String statut;
  final String? mois;          // ✅ Nullable, extrait de periode
  final String? annee;         // ✅ Nullable, extrait de periode
  final DateTime dateEcheance;
  final String periode;

  // Constructeur
  Paiement({
    required this.id,
    this.locataireId,
    this.bailId,
    required this.montantAttendu,
    required this.statut,
    this.mois,
    this.annee,
    required this.dateEcheance,
    required this.periode,
  });

  // ✅ Factory adapté au JSON du backend
  factory Paiement.fromJson(Map<String, dynamic> json) {
    // Le backend renvoie "date echeance " (avec espace) ou "date_echeance"
    final dateEcheanceStr = json['date echeance '] ??
        json['date echeance'] ??
        json['date_echeance'];

    if (dateEcheanceStr == null) {
      throw Exception('date_echeance manquante dans le JSON: $json');
    }

    // Le backend renvoie "montant" au lieu de "montant_attendu"
    final montantStr = json['montant'] ?? json['montant_attendu'];

    if (montantStr == null) {
      throw Exception('montant manquant dans le JSON: $json');
    }

    // Extraire mois et année de la période si nécessaire
    final periode = json['periode'] ?? '';
    String? mois;
    String? annee;

    if (periode.isNotEmpty) {
      final parts = periode.split(' ');
      if (parts.length >= 2) {
        mois = parts[0];
        annee = parts[1];
      }
    }

    return Paiement(
      id: json['id'],
      locataireId: json['locataire_id'] != null
          ? int.parse(json['locataire_id'].toString())
          : null,
      bailId: json['bail_id'] != null
          ? int.parse(json['bail_id'].toString())
          : null,
      montantAttendu: double.parse(montantStr.toString()),
      statut: json['statut'] ?? 'en_attente',
      mois: mois ?? json['mois']?.toString(),
      annee: annee ?? json['annee']?.toString(),
      dateEcheance: DateTime.parse(dateEcheanceStr),
      periode: periode,
    );
  }

  // ✅ Méthode toJson pour debugging
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'locataire_id': locataireId,
      'bail_id': bailId,
      'montant_attendu': montantAttendu,
      'statut': statut,
      'mois': mois,
      'annee': annee,
      'date_echeance': dateEcheance.toIso8601String(),
      'periode': periode,
    };
  }

  @override
  String toString() {
    return 'Paiement(id: $id, periode: $periode, statut: $statut, montant: $montantAttendu)';
  }
}