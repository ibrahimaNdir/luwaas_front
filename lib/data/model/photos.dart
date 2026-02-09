// lib/data/model/photos.dart

class Photo {
  final int? id;
  final String url;
  final String? legende;
  final bool estPrincipale;

  Photo({
    this.id,
    required this.url,
    this.legende,
    required this.estPrincipale,
  });

  factory Photo.fromJson(Map<String, dynamic> json) {
    String rawUrl = json['url'] ?? json['chemin'] ?? '';

    // ✅ Si le backend renvoie déjà une URL complète, on la garde
    if (rawUrl.startsWith('http')) {
      return Photo(
        id: json['id'],
        url: rawUrl, // ✅ URL déjà complète depuis le backend
        legende: json['legende'],
        estPrincipale: (json['est_principale'] == 1 ||
            json['est_principale'] == true ||
            json['is_main'] == true),
      );
    }

    // ⚠️ Sinon, on construit l'URL (mais normalement plus nécessaire)
    if (rawUrl.isNotEmpty && !rawUrl.startsWith('http')) {
      const String ipDeTonOrdi = '192.168.1.9'; // ✅ CHANGÉ ICI

      if (rawUrl.startsWith('/')) {
        rawUrl = rawUrl.substring(1);
      }

      rawUrl = 'http://$ipDeTonOrdi:8000/$rawUrl';
    }

    return Photo(
      id: json['id'],
      url: rawUrl,
      legende: json['legende'],
      estPrincipale: (json['est_principale'] == 1 ||
          json['est_principale'] == true ||
          json['is_main'] == true),
    );
  }
}
