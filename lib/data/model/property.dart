import 'localisation.dart';

class Property {
  final int? id;
  final String titre;
  final String type;
  final String adresse;
  final String description;
  final double latitude;
  final double longitude;

  // Pour l'ENVOI (IDs)
  final int regionId;
  final int departementId;
  final int communeId;

  // Pour la RÉCEPTION (Noms) - optionnel car pas utilisé lors de l'envoi
  final Localisation? localisation;
  // ⬅️ Pour quand tu récupères les propriétés

  Property({
    this.id,
    required this.titre,
    required this.type,
    required this.adresse,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.regionId,
    required this.departementId,
    required this.communeId,
    this.localisation,

  });

  // ENVOI au backend
  Map<String, dynamic> toJson() {
    return {
      "region_id": regionId,
      "departement_id": departementId,
      "commune_id": communeId,
      "titre": titre,
      "type": type,
      "adresse": adresse,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
    };
  }

  // RÉCEPTION du backend
// Dans lib/data/model/property.dart

  factory Property.fromJson(Map<String, dynamic> json) {

    print("🔍 REÇU DE LARAVEL : $json");
    return Property(
      id: json['id'] ?? 0, // ✅ Ça c'est très bien !

      titre: json['titre'] ?? "Sans titre",

      // 👇 AJOUTE LES '??' ICI AUSSI (Sinon crash assuré plus tard)
      type: json['type'] ?? "Type inconnu",
      adresse: json['adresse'] ?? "Adresse inconnue",
      description: json['description'] ?? "",

      // Conversion sécurisée pour les nombres (parfois l'API envoie des Strings)
      latitude: (json['latitude'] is String)
          ? double.tryParse(json['latitude']) ?? 0.0
          : (json['latitude']?.toDouble() ?? 0.0),

      longitude: (json['longitude'] is String)
          ? double.tryParse(json['longitude']) ?? 0.0
          : (json['longitude']?.toDouble() ?? 0.0),

      regionId: json['region_id'] ?? 0,
      departementId: json['departement_id'] ?? 0,
      communeId: json['commune_id'] ?? 0,

      localisation: json['localisation'] != null
          ? Localisation.fromJson(json['localisation'])
          : null,
    );
  }

}
