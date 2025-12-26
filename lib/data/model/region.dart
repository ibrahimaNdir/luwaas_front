class Region {
  final int id;
  final String nom;

  Region({
    required this.id,
    required this.nom,
  });

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      nom: json['nom'],
    );
  }
}
