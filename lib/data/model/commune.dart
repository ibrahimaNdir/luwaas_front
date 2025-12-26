class Commune {
  final int id;
  final String nom;
  final int departementId;

  Commune({
    required this.id,
    required this.nom,
    required this.departementId,
  });

  factory Commune.fromJson(Map<String, dynamic> json) {
    return Commune(
      // 👇 Ajout des sécurités ?? 0 et ?? ""
      id: json['id'] ?? 0,
      nom: json['nom'] ?? "Inconnu",
      departementId: json['departement_id'] ?? 0,
    );
  }
}
