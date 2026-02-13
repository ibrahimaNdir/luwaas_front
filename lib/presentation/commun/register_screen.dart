import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../provider/auth_provider.dart';
import '../../presentation/bailleur/home_screen.dart';
import '../../presentation/locataire/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  final String? userType; // 🆕 Optionnel maintenant
  const RegisterScreen({super.key, this.userType});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _pageController = PageController();
  int _currentPage = 0;

  // Controllers pour les champs
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _prenomController = TextEditingController();
  final _nomController = TextEditingController();
  final _cniController = TextEditingController();
  final _telController = TextEditingController();

  // Keys pour les formulaires
  final _formKey1 = GlobalKey<FormState>();
  final _formKey2 = GlobalKey<FormState>();

  // États dynamiques
  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // 🆕 Variables pour la redirection
  Map<String, dynamic>? _navigationArgs;
  String? _forcedRole; // Rôle forcé (locataire si vient de demande logement)

  @override
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments;

      // 🎯 Gérer les 2 formats d'arguments
      if (args is Map<String, dynamic>) {
        // Format Map (nouveau)
        setState(() {
          _navigationArgs = args;
          _forcedRole = args['role'];
        });
      } else if (args is String) {
        // Format String (ancien - pour compatibilité)
        setState(() {
          _forcedRole = args;
        });
      }

      print('📍 Vient de: ${_navigationArgs?['from']}');
      print('👤 Rôle: $_forcedRole');
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _prenomController.dispose();
    _nomController.dispose();
    _cniController.dispose();
    _telController.dispose();
    super.dispose();
  }

  // Aller à la page 2
  void _allerAuPage2() {
    if (_formKey1.currentState!.validate()) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage = 1;
        _errorMessage = null;
      });
    }
  }

  // Retour à la page 1
  void _retourAuPage1() {
    _pageController.previousPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
    setState(() {
      _currentPage = 0;
      _errorMessage = null;
    });
  }

  // 🆕 Inscription finale MODIFIÉE
  Future<void> _terminerInscription() async {
    if (!_formKey2.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      // 🎯 Déterminer le rôle à utiliser
      // Priorité : 1. Rôle forcé (demande logement)
      //           2. userType du constructeur (écran de choix)
      //           3. Défaut : 'locataire'
      final roleToUse = _forcedRole ?? widget.userType ?? 'locataire';

      print('🔑 Inscription avec rôle: $roleToUse');

      await authProvider.register(
        prenom: _prenomController.text.trim(),
        nom: _nomController.text.trim(),
        email: _emailController.text.trim(),
        password: _passwordController.text,
        telephone: _telController.text,
        cni: _cniController.text,
        userType: roleToUse, // 🔥 Utiliser le rôle déterminé
      );

      if (authProvider.isAuthenticated && authProvider.errorMessage == null) {
        if (mounted) {
          // 🎯 VÉRIFIER SI ON VIENT DE DetailsLogementScreen
          if (_navigationArgs != null &&
              _navigationArgs!['from'] == 'details-logement' &&
              _navigationArgs!['action'] == 'demande-logement') {

            // ✅ CAS 1 : Retour vers DetailsLogementScreen pour faire la demande
            print('🔄 Inscription réussie → Retour vers DetailsLogementScreen');

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('✅ Compte créé avec succès !'),
                backgroundColor: Colors.green,
                duration: Duration(milliseconds: 800),
              ),
            );

            await Future.delayed(const Duration(milliseconds: 800));

            if (mounted) {
              // ✅ RETOUR avec succès (pas de pushReplacement)
              Navigator.pop(context, true);
            }

          } else {
            // ✅ CAS 2 : Inscription normale → Redirection selon le rôle
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Inscription réussie !'),
                backgroundColor: Colors.green,
              ),
            );

            final userRole = authProvider.userRole ?? roleToUse;

            if (userRole == 'bailleur' || userRole == 'proprietaire') {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const HomeScreen()),
              );
            } else {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => const ClientHomeScreen()),
              );
            }
          }
        }
      } else {
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Erreur d\'inscription';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Une erreur est survenue. Veuillez réessayer.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: [_buildPage1(), _buildPage2()],
      ),
    );
  }

  // Page 1 - Prénom et Nom
  Widget _buildPage1() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 🆕 Bouton retour SI on vient de DetailsLogementScreen
              if (_navigationArgs != null && _navigationArgs!['from'] == 'details-logement')
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF2E4B8C)),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),

              // Logo LUWAAS
              Row(
                children: [
                  const Text(
                    'LUWAAS',
                    style: TextStyle(
                      color: Color(0xFF2E4B8C),
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 8),
                  SvgPicture.asset(
                    'assets/icons/house_welcome.svg',
                    width: 30,
                    height: 30,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2E4B8C),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),

              // 🆕 Message si rôle forcé
              if (_forcedRole == 'locataire')
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 20),
                  decoration: BoxDecoration(
                    color: const Color(0xFF2E4B8C).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF2E4B8C).withOpacity(0.3),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info_outline,
                        color: Color(0xFF2E4B8C),
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Création de compte locataire pour votre demande de logement',
                          style: TextStyle(
                            color: Colors.grey.shade700,
                            fontSize: 13,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              // Titre
              const Text(
                'Ajouter Votre Nom',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Champ Prénom
              const Text(
                'Prenom',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _prenomController,
                decoration: InputDecoration(
                  hintText: 'Entrez votre prénom',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E4B8C), width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Champ Nom
              const Text(
                'Nom',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nomController,
                decoration: InputDecoration(
                  hintText: 'Entrez votre nom',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E4B8C), width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Champ Téléphone
              const Text(
                'Téléphone',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _telController,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  hintText: 'Entrez votre numéro de téléphone',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E4B8C), width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 60),

              // Bouton Continuer
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _allerAuPage2,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E4B8C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'CONTINUER',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  // Page 2 - Email, Password, CNI
  Widget _buildPage2() {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey2,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bouton retour + Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_back,
                      color: Color(0xFF2E4B8C),
                    ),
                    onPressed: _retourAuPage1,
                  ),
                  Row(
                    children: [
                      const Text(
                        'LUWAAS',
                        style: TextStyle(
                          color: Color(0xFF2E4B8C),
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      SvgPicture.asset(
                        'assets/icons/house_welcome.svg',
                        width: 30,
                        height: 30,
                        colorFilter: const ColorFilter.mode(
                          Color(0xFF2E4B8C),
                          BlendMode.srcIn,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 40),

              // Titre
              const Text(
                'Votre Email et Mot de passe',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 24),

              // Champ Email
              const Text(
                'Email',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  hintText: 'Entrez votre email',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E4B8C), width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
                  if (!emailRegex.hasMatch(value)) {
                    return 'Veuillez entrer un email valide';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Champ Mot de passe
              const Text(
                'Mot de passe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  hintText: 'Entrez votre mot de passe',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E4B8C), width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  if (value.length < 6) {
                    return 'Le mot de passe doit contenir au moins 6 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),

              // Champ CNI
              const Text(
                'CNI',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _cniController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  hintText: 'Entrez votre numéro CNI',
                  hintStyle: TextStyle(color: Colors.grey.shade400),
                  enabledBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.grey),
                  ),
                  focusedBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Color(0xFF2E4B8C), width: 2),
                  ),
                  errorBorder: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.red),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Ce champ est requis';
                  }
                  if (value.length < 12) {
                    return 'La CNI doit contenir au moins 12 caractères';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 24),

              // Message d'erreur
              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.red.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),

              // Bouton Inscription
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _terminerInscription,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF2E4B8C),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                    elevation: 0,
                  ),
                  child: _isLoading
                      ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                      : const Text(
                    'INSCRIPTION',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Lien vers connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Vous avez déjà un compte ? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context, false);
                    },
                    style: TextButton.styleFrom(
                      padding: EdgeInsets.zero,
                      minimumSize: Size.zero,
                    ),
                    child: const Text(
                      'Se connecter',
                      style: TextStyle(
                        color: Color(0xFF2E4B8C),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
