import 'package:flutter/material.dart';

class Demande {
  final int id;
  final int logementId;
  final int locataireId;
  final int? proprietaireId;
  final String status;
  final DateTime dateDemande;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  final Map<String, dynamic>? locataire;
  final Map<String, dynamic>? logement;

  Demande({
    required this.id,
    required this.logementId,
    required this.locataireId,
    this.proprietaireId,
    required this.status,
    required this.dateDemande,
    this.createdAt,
    this.updatedAt,
    this.locataire,
    this.logement,
  });

  factory Demande.fromJson(Map<String, dynamic> json) {
    try {
      print("🔍 Parsing Demande - JSON: $json");

      return Demande(
        id: _parseIntSafe(json['id'], 'id'),
        logementId: _parseIntSafe(json['logement_id'], 'logement_id'),
        locataireId: _parseIntSafe(json['locataire_id'], 'locataire_id'),
        proprietaireId: json['proprietaire_id'] != null
            ? _parseIntSafe(json['proprietaire_id'], 'proprietaire_id')
            : null,
        status: json['status']?.toString() ?? 'en_attente',
        dateDemande: _parseDateSafe(json['date_demande'], 'date_demande'),
        createdAt: json['created_at'] != null
            ? _parseDateSafe(json['created_at'], 'created_at')
            : null,
        updatedAt: json['updated_at'] != null
            ? _parseDateSafe(json['updated_at'], 'updated_at')
            : null,
        locataire: json['locataire'] as Map<String, dynamic>?,
        logement: json['logement'] as Map<String, dynamic>?,
      );
    } catch (e, stackTrace) {
      print("❌ Erreur parsing Demande: $e");
      print("📄 JSON reçu: $json");
      print("📚 StackTrace: $stackTrace");
      rethrow;
    }
  }

  static int _parseIntSafe(dynamic value, String fieldName) {
    if (value == null) {
      throw Exception("Le champ '$fieldName' est requis mais null");
    }

    if (value is int) {
      return value;
    }

    if (value is String) {
      final parsed = int.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }

    throw Exception("Impossible de parser '$fieldName' avec la valeur: $value");
  }

  static DateTime _parseDateSafe(dynamic value, String fieldName) {
    if (value == null) {
      return DateTime.now();
    }

    if (value is DateTime) {
      return value;
    }

    if (value is String) {
      final parsed = DateTime.tryParse(value);
      if (parsed != null) {
        return parsed;
      }
    }

    print("⚠️ Impossible de parser '$fieldName' ($value), utilisation de DateTime.now()");
    return DateTime.now();
  }

  // ✅ Getters pour accéder facilement aux infos du locataire
  int? get locataireId_fromJson => locataire?['id'];
  String? get locataireNom => locataire?['nom'];
  String? get locatairePrenom => locataire?['prenom'];
  String? get locataireEmail => locataire?['email'];
  String? get locataireTelephone => locataire?['telephone'];

  // ✅ Getters pour accéder facilement aux infos du logement
  int? get logementId_fromJson => logement?['id'];
  String? get logementTitre => logement?['titre'];
  String? get logementNumero => logement?['numero'];
  String? get logementAdresse => logement?['adresse'];
  String? get logementPhotoUrl => logement?['photo_principale'];
  List<dynamic>? get logementPhotos => logement?['photos'];

  // ✅ AJOUTÉ : Getter pour le prix
  dynamic get logementPrix {
    final prix = logement?['prix'];
    if (prix == null) return 0;
    if (prix is int) return prix;
    if (prix is double) return prix.toInt();
    if (prix is String) return int.tryParse(prix) ?? 0;
    return 0;
  }

  // ✅ Nom complet du locataire
  String get locataireNomComplet {
    final prenom = locatairePrenom ?? '';
    final nom = locataireNom ?? '';
    if (prenom.isEmpty && nom.isEmpty) return 'Locataire inconnu';
    return '$prenom $nom'.trim();
  }

  // ✅ Titre complet du logement (avec numéro)
  String get logementTitreComplet {
    final titre = logementTitre ?? 'Logement';
    final numero = logementNumero;
    if (numero != null && numero.isNotEmpty) {
      return '$titre - N°$numero';
    }
    return titre;
  }

  // ✅ Vérifications de status
  bool get isEnAttente => status.toLowerCase() == 'en_attente';
  bool get isAcceptee => status.toLowerCase() == 'acceptee';
  bool get isRefusee => status.toLowerCase() == 'refusee';
  bool get isBailSigne => status.toLowerCase() == 'bail_signe';

  // ✅ Couleur selon le status (pour l'UI)
  Color get statusColor {
    switch (status.toLowerCase()) {
      case 'en_attente':
        return Colors.orange;
      case 'acceptee':
        return Colors.green;
      case 'refusee':
        return Colors.red;
      case 'bail_signe':
        return Colors.blue;
      default:
        return Colors.grey;
    }
  }

  // ✅ Libellé du status (pour l'UI)
  String get statusLibelle {
    switch (status.toLowerCase()) {
      case 'en_attente':
        return 'En attente';
      case 'acceptee':
        return 'Acceptée';
      case 'refusee':
        return 'Refusée';
      case 'bail_signe':
        return 'Bail signé';
      default:
        return status;
    }
  }

  @override
  String toString() {
    return 'Demande(id: $id, logement: $logementTitreComplet, locataire: $locataireNomComplet, status: $status)';
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'logement_id': logementId,
      'locataire_id': locataireId,
      'proprietaire_id': proprietaireId,
      'status': status,
      'date_demande': dateDemande.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'locataire': locataire,
      'logement': logement,
    };
  }
}