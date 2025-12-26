class Paiement {
  final int id;
  final int locataireId;
  final int bailId;
  final int montantAttendu;
  final String statut;        // 'paye', 'en_attente', etc.
  final String mois;          // ex: "Janvier"
  final String annee;         // ex: "2024" (parfois string ou int, à vérifier)
  final DateTime dateEcheance;
  final String periode;       // ex: "Janvier 2024"

  // Constructeur
  Paiement({
    required this.id,
    required this.locataireId,
    required this.bailId,
    required this.montantAttendu,
    required this.statut,
    required this.mois,
    required this.annee,
    required this.dateEcheance,
    required this.periode,
  });

  // Factory depuis JSON
  factory Paiement.fromJson(Map<String, dynamic> json) {
    return Paiement(
      id: json['id'],
      locataireId: int.parse(json['locataire_id'].toString()),
      bailId: int.parse(json['bail_id'].toString()),
      montantAttendu: int.parse(json['montant_attendu'].toString()),
      statut: json['statut'] ?? 'en_attente',

      mois: json['mois'].toString(),
      annee: json['annee'].toString(),

      dateEcheance: DateTime.parse(json['date_echeance']),
      periode: json['periode'] ?? "${json['mois']} ${json['annee']}",
    );
  }
}
