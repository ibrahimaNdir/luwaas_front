import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../provider/auth_provider.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _isLoading = false;
  bool _obscurePassword = true;
  String? _errorMessage;

  // 🆕 Variables pour gérer la redirection
  Map<String, dynamic>? _navigationArgs;

  @override
  void initState() {
    super.initState();
    // 🎯 Récupérer les arguments passés depuis DetailsLogementScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _navigationArgs = args;
        });
        print('📍 Vient de: ${args['from']}');
        print('🏠 Logement ID: ${args['logementId']}');
      }
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // ✅ Fonction de connexion
  Future<void> _login() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      print("🔵 LoginScreen - Tentative de connexion...");

      await authProvider.login(
        login: _emailController.text.trim(),
        password: _passwordController.text,
      );

      print("🔵 LoginScreen - Login terminé");
      print("🔵 isAuthenticated: ${authProvider.isAuthenticated}");
      print("🔵 userRole: ${authProvider.userRole}");

      // ✅ VÉRIFIER L'AUTHENTIFICATION MÊME EN CAS D'EXCEPTION
      if (authProvider.isAuthenticated && mounted) {
        print("✅ Utilisateur authentifié - Navigation...");

        // 🎯 VÉRIFIER SI ON VIENT DE DetailsLogementScreen
        if (_navigationArgs != null && _navigationArgs!['from'] == 'details-logement') {
          print("🔄 Retour vers DetailsLogementScreen");
          Navigator.pop(context, true);
        } else {
          // ✅ Navigation selon le rôle
          final userRole = authProvider.userRole;
          print("🔵 Navigation pour rôle: $userRole");

          if (userRole == 'proprietaire') {
            Navigator.pushReplacementNamed(context, '/main_bailleur');
          } else if (userRole == 'locataire' || userRole == 'client') {
            Navigator.pushReplacementNamed(context, '/client_home');
          } else {
            Navigator.pushReplacementNamed(context, '/role');
          }
        }
      } else if (mounted) {
        // ✅ Si vraiment pas authentifié
        print("❌ Authentification échouée");
        setState(() {
          _errorMessage = authProvider.errorMessage ?? 'Erreur de connexion';
        });
      }
    } catch (e) {
      print("❌ Exception dans _login(): $e");

      // ✅ VÉRIFIER QUAND MÊME L'AUTHENTIFICATION
      if (authProvider.isAuthenticated && mounted) {
        print("✅ Exception mais utilisateur authentifié - Navigation...");

        // Navigation même en cas d'exception
        final userRole = authProvider.userRole;

        if (_navigationArgs != null && _navigationArgs!['from'] == 'details-logement') {
          Navigator.pop(context, true);
        } else if (userRole == 'proprietaire') {
          Navigator.pushReplacementNamed(context, '/main_bailleur');
        } else if (userRole == 'locataire' || userRole == 'client') {
          Navigator.pushReplacementNamed(context, '/client_home');
        } else {
          Navigator.pushReplacementNamed(context, '/role');
        }
      } else if (mounted) {
        // ✅ Vraiment une erreur de connexion
        setState(() {
          _errorMessage = 'Email/téléphone ou mot de passe incorrect';
        });
      }
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
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 🆕 Bouton retour SI on vient de DetailsLogementScreen
                if (_navigationArgs != null &&
                    _navigationArgs!['from'] == 'details-logement')
                  Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.arrow_back),
                          onPressed: () => Navigator.pop(context, false),
                          color: const Color(0xFF2E4B8C),
                        ),
                        const SizedBox(width: 8),
                        const Expanded(
                          child: Text(
                            'Connectez-vous pour continuer',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
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
                const SizedBox(height: 50),

                // Titre
                const Text(
                  'Votre Numero Tel ou Email',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 24),

                // Champ Email ou Téléphone
                const Text(
                  'Email ou Telephone',
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
                    hintText: 'Entrez votre email ou téléphone',
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

                // Champ Mot de passe
                const Text(
                  'Mots de passe',
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
                const SizedBox(height: 16),

                // Mot de passe oublié
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot-password');
                    },
                    child: const Text(
                      'Mot de passe oublié ?',
                      style: TextStyle(
                        color: Color(0xFF2E4B8C),
                      ),
                    ),
                  ),
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
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline, color: Colors.red, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Bouton Connexion
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _login,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2E4B8C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      elevation: 0,
                      disabledBackgroundColor: const Color(0xFF2E4B8C).withOpacity(0.6),
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
                      'CONNEXION',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),

                // Lien vers inscription
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Pas encore de compte ? ',
                      style: TextStyle(color: Colors.grey),
                    ),
                    TextButton(
                      onPressed: () {
                        // 🔍 DEBUG
                        print('🔍 _navigationArgs: $_navigationArgs');
                        print('🔍 from: ${_navigationArgs?['from']}');
                        print('🔍 Condition: ${_navigationArgs != null && _navigationArgs!['from'] == 'details-logement'}');

                        if (_navigationArgs != null &&
                            _navigationArgs!['from'] == 'details-logement') {

                          print('✅ Va vers RegisterScreen');
                          Navigator.pushNamed(
                            context,
                            '/register',
                            arguments: {
                              'from': 'details-logement',
                              'logementId': _navigationArgs!['logementId'],
                              'logement': _navigationArgs!['logement'],
                              'action': 'demande-logement',
                              'role': 'locataire',
                            },
                          );
                        } else {
                          print('❌ Va vers RoleScreen');
                          Navigator.pushNamed(context, '/role');
                        }
                      },
                      child: const Text('S\'inscrire'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}