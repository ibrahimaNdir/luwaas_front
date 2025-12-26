class Localisation {
  final String region;
  final String departement;
  final String commune;

  Localisation({
    required this.region,
    required this.departement,
    required this.commune,
  });

  factory Localisation.fromJson(Map<String, dynamic> json) {
    return Localisation(
      region: json['region'],
      departement: json['departement'],
      commune: json['commune'],
    );
  }
}
