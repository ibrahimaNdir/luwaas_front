import 'package:luwaas/data/model/photos.dart';

class Logement {
  final int? id;
  final String? numero; // Peut être null si non renseigné
  final String type;
  final double superficie;
  final int nombrePieces;
  final bool estMeuble;
  final String etat;
  final String? description;
  final double loyerMensuel;
  final int proprieteId;
  final Map<String, String>? propriete;
  final List<Photo>? photos;
  final bool? disponible;
  final String? statutPublication;
  final double? distance;
  final String? photoPrincipaleUrl;

  Logement({
    this.id,
    this.numero, // Optionnel ici
    required this.type,
    required this.superficie,
    required this.nombrePieces,
    required this.estMeuble,
    required this.etat,
    this.description,
    required this.loyerMensuel,
    required this.proprieteId,
    this.propriete,
    this.photos,
    this.disponible,
    this.statutPublication,
    this.distance,
    this.photoPrincipaleUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'typelogement': type, // Backend attend 'type', pas 'typelogement'
      'superficie': superficie,
      'nombre_pieces': nombrePieces,
      'meuble': estMeuble ? 1 : 0,
      'etat': etat,
      'description': description,
      'prix_loyer': loyerMensuel,
      'propriete_id': proprieteId,
      // Pas besoin d'envoyer 'statut_occupe' car le Back met 'disponible' par défaut
    };
  }

  factory Logement.fromJson(Map<String, dynamic> json) {
    // 1. Gestion des champs qui peuvent avoir plusieurs noms
    final m = json['est_meuble'] ?? json['meuble'];
    final rawLoyer = json['prix_loyer'] ?? json['prix_indicatif'] ?? json['loyer_mensuel'];

    // 2. Gestion du statut disponible (Correction clé)
    // Le backend envoie "statut_occupe": "disponible" ou "occupe"
    // Par sécurité, on checke aussi si c'est un booléen (1/true) au cas où
    bool isAvailable = false;
    if (json['statut_occupe'] != null) {
      isAvailable = json['statut_occupe'] == 'disponible';
    } else if (json['disponible'] != null) {
      isAvailable = (json['disponible'] == 1 || json['disponible'] == true);
    } else {
      isAvailable = true; // Par défaut si info manquante
    }

    return Logement(
      id: json['id'],

      // ✅ CORRECTION MAJEURE : Ta migration a créé "numero", pas "numero_porte"
      numero: (json['numero'] ?? json['numero_porte'])?.toString(),

      type: (json['type'] ?? json['typelogement'] ?? '').toString(),

      superficie: double.tryParse(json['superficie']?.toString().replaceAll(RegExp(r'[^0-9.]'), '') ?? '0') ?? 0.0,

      nombrePieces: int.tryParse(json['nombre_pieces']?.toString() ?? '0') ?? 0,

      estMeuble: (m == true || m == 1 || m == '1'),

      etat: (json['etat'] ?? '').toString(),

      statutPublication: (json['statut_publication'] ?? 'brouillon').toString(),

      description: json['description'],

      loyerMensuel: double.tryParse(rawLoyer?.toString() ?? '0') ?? 0.0,

      proprieteId: int.tryParse(json['propriete_id']?.toString() ?? '0') ?? 0,

      // ✅ C'est ici que la magie opère pour ton statut "Occupé par défaut"
      disponible: isAvailable,

      propriete: json['propriete'] != null
          ? {
        'adresse': json['propriete']['adresse']?.toString() ?? '',
        'ville': json['propriete']['ville']?.toString() ?? '',
        'commune': json['propriete']['commune']?.toString() ?? '',
      }
          : null,

      photos: json['photos'] != null && (json['photos'] is List)
          ? (json['photos'] as List)
          .map((photoJson) => Photo.fromJson(photoJson))
          .toList()
          : null,

      distance: double.tryParse(json['distance']?.toString() ?? ''),


      // 🔹 Nouveau : lien direct avec `photo_principale` de la Resource
      photoPrincipaleUrl: json['photo_principale']?.toString(),
    );
  }

  Photo? get photoPrincipale {
    if (photos == null || photos!.isEmpty) return null;
    try {
      return photos!.firstWhere((photo) => photo.estPrincipale);
    } catch (e) {
      return photos!.first;
    }
  }

  String get loyerFormat => '${loyerMensuel.toStringAsFixed(0)} FCFA';
  String get superficieFormat => '${superficie.toStringAsFixed(0)} m²';
  String get nombrePiecesFormat {
    if (type.toLowerCase() == 'studio') return 'Studio';
    // Si c'est 0 pièces (donnée manquante), on affiche juste le type
    if (nombrePieces == 0) return type[0].toUpperCase() + type.substring(1);
    return 'F$nombrePieces';
  }
}
