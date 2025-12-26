class Bail {
  final int id;
  final int logementId;
  final int locataireId;
  final int? demandeId; // Nullable : un bail peut être créé sans demande préalable

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

  final String statut; // 'actif', 'resilie', etc.

  // Objets imbriqués pour l'affichage (facultatif mais utile)
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
    return Bail(
      id: json['id'],
      logementId: int.parse(json['logement_id'].toString()),
      locataireId: int.parse(json['locataire_id'].toString()),
      demandeId: json['demande_id'] != null
          ? int.parse(json['demande_id'].toString())
          : null,

      montantLoyer: int.parse(json['montant_loyer'].toString()),
      caution: int.parse(json['caution'].toString()),
      chargesMensuelles: int.parse(json['charges_mensuelles'].toString()),
      cautionsAPayer: int.parse(json['cautions_a_payer'].toString()),

      dateDebut: DateTime.parse(json['date_debut']),
      dateFin: DateTime.parse(json['date_fin']),

      jourEcheance: int.parse(json['jour_echeance'].toString()),
      // Gestion du booléen qui peut arriver en 0/1 depuis MySQL
      renouvellementAutomatique: json['renouvellement_automatique'] == 1 || json['renouvellement_automatique'] == true,

      statut: json['statut'] ?? 'actif',

      logement: json['logement'],
      locataire: json['locataire'],
    );
  }

  // Utile pour envoyer les données au formulaire de modification si besoin
  Map<String, dynamic> toJson() {
    return {
      'logement_id': logementId,
      'locataire_id': locataireId,
      'demande_id': demandeId,
      'montant_loyer': montantLoyer,
      'caution': caution,
      'date_debut': dateDebut.toIso8601String(),
      'date_fin': dateFin.toIso8601String(),
      // ... ajouter le reste si besoin d'envoyer au back
    };
  }
}
