class BailPaiement {
  final int id;
  final String adresse;
  final String type;
  final String numero;
  final double surface;
  final String statut;

  BailPaiement({
    required this.id,
    required this.adresse,
    required this.type,
    required this.numero,
    required this.surface,
    required this.statut,
  });

  factory BailPaiement.fromJson(Map<String, dynamic> json) {
    return BailPaiement(
      id: json['logement']['id'],
      adresse: json['logement']['adresse'],
      type: json['logement']['type'],
      numero: json['logement']['numero'],
      surface: (json['logement']['surface'] as num).toDouble(),
      statut: json['statut'],
    );
  }
}
