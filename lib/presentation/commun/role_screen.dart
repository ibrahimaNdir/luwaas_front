import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class RoleScreen extends StatefulWidget {
  const RoleScreen({super.key});

  @override
  State<RoleScreen> createState() => _RoleScreenState();
}

class _RoleScreenState extends State<RoleScreen> {
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
              const SizedBox(height: 60),
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
              const SizedBox(height: 80),
              // Titre
              const Text(
                'Choisissez votre profil',
                style: TextStyle(
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
                      Navigator.pushNamed(context, '/login');
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
        // ✅ MODIFICATION : Navigation différente selon le type
        if (userType == 'locataire') {
          // Locataire → Mode invité → Écran d'accueil
          Navigator.pushNamed(context, '/main_client');
        } else {
          // Bailleur → Inscription obligatoire
          Navigator.pushNamed(
            context,
            '/register',
            arguments: userType,
          );
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
