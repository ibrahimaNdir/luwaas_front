import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
  // 🆕 Variables pour gérer les arguments de navigation
  Map<String, dynamic>? _navigationArgs;

  @override
  void initState() {
    super.initState();
    // 🎯 Récupérer les arguments passés depuis LoginScreen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
      if (args != null) {
        setState(() {
          _navigationArgs = args;
        });
        print('📍 RoleScreen - Vient de: ${args['from']}');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),

              // 🆕 Bouton retour SI on vient d'une demande de logement
              if (_navigationArgs != null && _navigationArgs!['from'] == 'details-logement')
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    icon: const Icon(Icons.arrow_back, color: Color(0xFF2E4B8C)),
                    onPressed: () => Navigator.pop(context, false),
                  ),
                ),

              const SizedBox(height: 20),
              // Logo
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'LUWAAS',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF2E4B8C),
                    ),
                  ),
                  const SizedBox(width: 5),
                  SvgPicture.asset(
                    'assets/icons/house_welcome.svg',
                    width: 50,
                    height: 50,
                    colorFilter: const ColorFilter.mode(
                      Color(0xFF2E4B8C),
                      BlendMode.srcIn,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 60),

              // 🆕 Message contexte si vient d'une demande de logement
              if (_navigationArgs != null && _navigationArgs!['from'] == 'details-logement')
                Container(
                  padding: const EdgeInsets.all(12),
                  margin: const EdgeInsets.only(bottom: 30),
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
                          'Créez un compte locataire pour continuer votre demande de logement',
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
              Text(
                _navigationArgs != null && _navigationArgs!['from'] == 'details-logement'
                    ? 'Choisissez votre profil'
                    : 'Choisissez votre profil',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              const Text(
                'Sélectionnez le type de compte que vous souhaitez créer',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 60),
              // Carte Bailleur
              _buildRoleCard(
                context: context,
                icon: Icons.business_outlined,
                title: 'Bailleur',
                subtitle: 'Je suis propriétaire de biens',
                userType: 'proprietaire',
              ),
              const SizedBox(height: 24),
              // Carte Locataire
              _buildRoleCard(
                context: context,
                icon: Icons.person_outline,
                title: 'Locataire',
                subtitle: 'Je recherche un bien à louer',
                userType: 'locataire',
              ),
              const Spacer(),
              // Lien vers la connexion
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Vous avez déjà un compte ? ',
                    style: TextStyle(color: Colors.grey),
                  ),
                  GestureDetector(
                    onTap: () {
                      // 🆕 Passer les arguments aussi au login si nécessaire
                      if (_navigationArgs != null) {
                        Navigator.pushNamed(context, '/login', arguments: _navigationArgs);
                      } else {
                        Navigator.pushNamed(context, '/login');
                      }
                    },
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
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRoleCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required String userType,
  }) {
    return GestureDetector(
      onTap: () {
        // 🎯 LOGIQUE MODIFIÉE

        // CAS 1 : On vient d'une demande de logement
        if (_navigationArgs != null && _navigationArgs!['from'] == 'details-logement') {
          // ✅ Aller TOUJOURS à l'inscription avec le rôle choisi
          Navigator.pushNamed(
            context,
            '/register',
            arguments: {
              ..._navigationArgs!, // Garder tous les arguments
              'role': userType, // Ajouter le rôle choisi
            },
          );
        }
        // CAS 2 : Navigation normale (pas de demande de logement)
        else {
          if (userType == 'locataire') {
            // Locataire → Mode invité → Écran d'accueil
            Navigator.pushNamed(context, '/main_client');
          } else {
            // Bailleur → Inscription obligatoire
            Navigator.pushNamed(
              context,
              '/register',
              arguments: {'role': userType}, // 🆕 Format cohérent
            );
          }
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFF2E4B8C), width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.1),
              spreadRadius: 2,
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF2E4B8C).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 32,
                color: const Color(0xFF2E4B8C),
              ),
            ),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_forward_ios,
              color: Color(0xFF2E4B8C),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}