class User {
  final int? id;
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String cni;
  final String userType;
  final String? token;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    this.id,
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.cni,
    required this.userType,
    this.token,
    this.createdAt,
    this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      prenom: json['prenom'],
      nom: json['nom'],
      email: json['email'],
      telephone: json['telephone'],
      cni: json['cni'],
      userType: json['user_type'],
      token: json['token'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'cni': cni,
      'user_type': userType,
      'token': token,
      'created_at': createdAt?.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }
}
