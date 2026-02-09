class Demande {
  final int id;
  final int logementId;
  final int locataireId;
  final int? proprietaireId; // Peut être null selon qui regarde
  final String status;       // 'en_attente', 'acceptee', 'refusee', 'bail_signe'
  final DateTime dateDemande;

  // Ces objets contiennent les détails (envoyés via ->with() côté Laravel)
  // On utilise Map pour l'instant pour être flexible, mais tu pourras typer avec tes modèles User/Logement existants
  final Map<String, dynamic>? locataire;
  final Map<String, dynamic>? logement;

  Demande({
    required this.id,
    required this.logementId,
    required this.locataireId,
    this.proprietaireId,
    required this.status,
    required this.dateDemande,
    this.locataire,
    this.logement,
  });

  factory Demande.fromJson(Map<String, dynamic> json) {
    return Demande(
      id: json['id'],
      // On s'assure que ce sont bien des entiers (parfois l'API renvoie des strings)
      logementId: int.parse(json['logement_id'].toString()),
      locataireId: int.parse(json['locataire_id'].toString()),
      proprietaireId: json['proprietaire_id'] != null
          ? int.parse(json['proprietaire_id'].toString())
          : null,
      status: json['status'] ?? 'en_attente',
      // On gère la date (created_at ou date_demande selon ta migration)
      dateDemande: DateTime.parse(json['created_at'] ?? json['date_demande']),

      // Récupération des objets imbriqués
      locataire: json['locataire'],
      logement: json['logement'],
    );
  }
}
