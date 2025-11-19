class RegisterRequest {
  final String prenom;
  final String nom;
  final String email;
  final String telephone;
  final String password;
  final String passwordConfirmation;
  final String userType;
  final String cni;

  RegisterRequest({
    required this.prenom,
    required this.nom,
    required this.email,
    required this.telephone,
    required this.password,
    required this.passwordConfirmation,
    required this.userType,
    required this.cni,
  });

  Map<String, dynamic> toJson() {
    return {
      'prenom': prenom,
      'nom': nom,
      'email': email,
      'telephone': telephone,
      'password': password,
      'password_confirmation': passwordConfirmation,
      'user_type': userType,
      'cni': cni,
    };
  }
}
