import 'package:intl/intl.dart';
import 'package:luwaas/data/model/photos.dart';

class Logement {
  final int? id;
  final String? numero; // Peut être null si non renseigné
  final String type;
  final double superficie;
  final String ?nombrePieces;
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
  final int sdb ;
  final int nbrChambres ;
  final String ? titreAffiche ;



  Logement({
    this.id,
    this.numero, // Optionnel ici
    required this.type,
    required this.superficie,
    this.nombrePieces,
    required this.estMeuble,
    required this.etat,
    this.description,
    required this.loyerMensuel,
    required this.proprieteId,
    this.titreAffiche,
    this.propriete,
    this.photos,
    this.disponible,
    this.statutPublication,
    this.distance,
    this.photoPrincipaleUrl,
    required this.nbrChambres,
    required this.sdb,
  });
// doit Avoir le meme syntaxe que le json
  Map<String, dynamic> toJson() {
    return {
      'numero': numero,
      'typelogement': type,
      'superficie': superficie,
      'meuble': estMeuble ,
      'etat': etat,
      'description': description,
      'prix_loyer': loyerMensuel,
      'propriete_id': proprieteId,
      'nombre_chambres' : nbrChambres,
      'nombre_salles_de_bain': sdb

      // Pas besoin d'envoyer 'statut_occupe' car le Back met 'disponible' par défaut
    };
  }

  factory Logement.fromJson(Map<String, dynamic> json) {
    return Logement(
      id: json['id'],

      // identifiant → numero
      numero: json['identifiant']?.toString(),

      titreAffiche: json['titre_affiche']?.toString(),

      type: json['type']?.toString() ?? '',

      superficie: double.tryParse(json['superficie']?.toString() ?? '0') ?? 0.0,

      estMeuble: json['meuble'] == true || json['meuble'] == 1,

      etat: json['etat']?.toString() ?? '',

      description: json['description']?.toString(),

      nombrePieces: json['nombre_pieces']?.toString(), // ex: "F3"

      loyerMensuel: double.tryParse(
        json['loyer_mensuel']?.toString() ?? '0',
      ) ?? 0.0,

      proprieteId: int.tryParse(
          (json['propriete_id'] ?? json['id_propriete'])?.toString() ?? '0'
      ) ?? 0,

      statutPublication: json['statut_publication']?.toString(),

      disponible: json['statut_occupe'] == 'disponible',

      nbrChambres: int.tryParse(
        json['chambres']?.toString() ?? '0',
      ) ?? 0,

      sdb: int.tryParse(
        json['sdb']?.toString() ?? '0',
      ) ?? 0,

      photoPrincipaleUrl: json['photo_principale']?.toString(),

      photos: (json['photos'] as List?)
          ?.map((p) => Photo.fromJson(p))
          .toList(),

      propriete: {
        'adresse': json['adresse']?.toString() ?? '',
        'commune': json['commune']?.toString() ?? '',
      },
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

  String get loyerFormat {
    final formatter = NumberFormat('#,###', 'fr_FR');
    return '${formatter.format(loyerMensuel)} FCFA';
  }
  String get superficieFormat => '${superficie.toStringAsFixed(0)} m²';
  String get nombrePiecesFormat {
    if (type.toLowerCase() == 'studio') return 'Studio';
    // Si c'est 0 pièces (donnée manquante), on affiche juste le type
    if (nombrePieces == 0) return type[0].toUpperCase() + type.substring(1);
    return 'F$nombrePieces';
  }
}