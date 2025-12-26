class PaiementBailleur {
  final int id;
  final int montant;
  final String statut;
  final String periode;
  final DateTime? dateEcheance;
  final DateTime? datePaiement;
  final String locataireNom;
  final String logementTitre;

  PaiementBailleur({
    required this.id,
    required this.montant,
    required this.statut,
    required this.periode,
    this.dateEcheance,
    this.datePaiement,
    required this.locataireNom,
    required this.logementTitre,
  });

  factory PaiementBailleur.fromJson(Map<String, dynamic> json) {
    return PaiementBailleur(
      id: json['id'],
      montant: int.parse(json['montant'].toString()),
      statut: json['statut'] ?? '',
      periode: json['periode'] ?? '',
      dateEcheance: json['date_echeance'] != null
          ? DateTime.parse(json['date_echeance'])
          : null,
      datePaiement: json['date_paiement'] != null
          ? DateTime.parse(json['date_paiement'])
          : null,
      locataireNom: json['locataire']?['nom'] != null
          ? '${json['locataire']['prenom'] ?? ''} ${json['locataire']['nom']}'
          : 'Locataire',
      logementTitre: json['logement']?['titre'] ?? 'Logement',
    );
  }
}
