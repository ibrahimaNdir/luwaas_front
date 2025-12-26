class Departement {
  final int id;
  final String nom;
  final int regionId;

  Departement({
    required this.id,
    required this.nom,
    required this.regionId,
  });

  factory Departement.fromJson(Map<String, dynamic> json) {
    return Departement(
      // 👇 Sécurité anti-crash
      id: json['id'] ?? 0,

      // 👇 Sécurité texte
      nom: json['nom'] ?? "Nom inconnu",

      // 👇 Sécurité ID région
      regionId: json['region_id'] ?? 0,
    );
  }
}
