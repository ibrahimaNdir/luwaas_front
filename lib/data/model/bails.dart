class Bail {
  final int id;
  final int logementId;
  final int locataireId;
  final int? demandeId;

  // Infos financières
  final int montantLoyer;
  final int caution;
  final int chargesMensuelles;
  final int cautionsAPayer;

  // Dates et Durée
  final DateTime dateDebut;
  final DateTime dateFin;
  final int jourEcheance;
  final bool renouvellementAutomatique;

  final String statut;

  // Objets imbriqués
  final Map<String, dynamic>? logement;
  final Map<String, dynamic>? locataire;

  Bail({
    required this.id,
    required this.logementId,
    required this.locataireId,
    this.demandeId,
    required this.montantLoyer,
    required this.caution,
    required this.chargesMensuelles,
    required this.cautionsAPayer,
    required this.dateDebut,
    required this.dateFin,
    required this.jourEcheance,
    required this.renouvellementAutomatique,
    required this.statut,
    this.logement,
    this.locataire,
  });

  factory Bail.fromJson(Map<String, dynamic> json) {
    // Helper sécurisé contre les null
    int parseIntSafe(dynamic val, [int defaultVal = 0]) {
      if (val == null) return defaultVal;
      return int.tryParse(val.toString()) ?? defaultVal;
    }

    return Bail(
      id: parseIntSafe(json['id']),
      logementId: parseIntSafe(json['logement_id']),
      locataireId: parseIntSafe(json['locataire_id']),
      demandeId: json['demande_id'] != null
          ? parseIntSafe(json['demande_id'])
          : null,
      montantLoyer: parseIntSafe(json['montant_loyer']),
      caution: parseIntSafe(json['caution']),
      chargesMensuelles: parseIntSafe(json['charges_mensuelles']),
      cautionsAPayer: parseIntSafe(json['cautions_a_payer']),
      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),
      jourEcheance: parseIntSafe(json['jour_echeance']),
      // ⚠️ Ton API renvoie 'renouvellement' pas 'renouvellement_automatique'
      renouvellementAutomatique: json['renouvellement_automatique'] == 1 ||
          json['renouvellement_automatique'] == true ||
          json['renouvellement'] == true,
      statut: json['statut'] ?? 'actif',
      logement: json['logement'],
      locataire: json['locataire'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'logement_id': logementId,
      'locataire_id': locataireId,
      'demande_id': demandeId,
      'montant_loyer': montantLoyer,
      'caution': caution,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
    };
  }
}