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

    if (rawUrl.isNotEmpty && !rawUrl.startsWith('http')) {
      // 👇 Mets ici l’IP de ton PC (celle que tu utilises déjà pour le back)
      const String ipDeTonOrdi = '10.0.18.42';

      // On enlève juste le slash initial
      if (rawUrl.startsWith('/')) {
        rawUrl = rawUrl.substring(1); // "storage/....jpg"
      }

      // On préfixe uniquement par host + port
      rawUrl = 'http://$ipDeTonOrdi:8000/$rawUrl';
      // => http://10.0.18.42:8000/storage/....jpg
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
