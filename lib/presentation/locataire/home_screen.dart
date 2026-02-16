import 'package:flutter/material.dart';
import 'package:luwaas/presentation/locataire/select_logement_screen.dart';
import 'package:provider/provider.dart';

import '../../presentation/provider/auth_provider.dart';
import '../../presentation/provider/BailProvider.dart';
import '../../presentation/provider/notification_provider.dart'; // ✅ AJOUTÉ
import '../../data/model/bailspaiement.dart';

import 'baux_screen.dart';
import 'logement_screen.dart';
import 'search_screen.dart';

class ClientHomeScreen extends StatelessWidget {
  const ClientHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: const [
              _TopHeader(),
              SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: Text(
                  'Action Rapide',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111111),
                  ),
                ),
              ),
              SizedBox(height: 18),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 22),
                child: _QuickActionsGrid(),
              ),
              SizedBox(height: 22),
            ],
          ),
        ),
      ),
    );
  }
}

class _TopHeader extends StatefulWidget {
  const _TopHeader();

  @override
  State<_TopHeader> createState() => _TopHeaderState();
}

class _TopHeaderState extends State<_TopHeader> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // ✅ Charger les baux
      Provider.of<BailProvider>(context, listen: false).fetchBauxLocataire();

      // ✅ NOUVEAU : Lancer l'écoute des notifications
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final userId = authProvider.user?.id?.toString(); // Récupérer l'ID utilisateur

      if (userId != null) {
        Provider.of<NotificationProvider>(context, listen: false)
            .listenToNotifications(userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final user = authProvider.user;
    final String prenom = user?.prenom ?? "Locataire";

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
      decoration: const BoxDecoration(
        color: Color(0xFF1E3E8A),
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(34),
          bottomRight: Radius.circular(34),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 6),
                    Text(
                      "Bonjour $prenom",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      "Gérez votre Location",
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Row(
                  children: [
                    // ✅ ICÔNE NOTIFICATIONS AVEC BADGE
                    Consumer<NotificationProvider>(
                      builder: (context, notifProvider, child) {
                        return GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, '/notif');
                          },
                          child: notifProvider.unreadCount > 0
                              ? Badge(
                            label: Text('${notifProvider.unreadCount}'),
                            backgroundColor: Colors.red,
                            textColor: Colors.white,
                            child: const Icon(
                              Icons.notifications_outlined,
                              color: Colors.white,
                              size: 24,
                            ),
                          )
                              : const Icon(
                            Icons.notifications_outlined,
                            color: Colors.white,
                            size: 24,
                          ),
                        );
                      },
                    ),
                    const SizedBox(width: 16),
                    // Icône Profil utilisateur
                    GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(context, '/profile');
                      },
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: const Icon(
                          Icons.person,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          // Carte DYNAMIQUE (Loyer ou Recherche)
          Consumer<BailProvider>(
            builder: (context, bailProvider, child) {
              if (bailProvider.isLoadingBauxLocataire) {
                return const Center(child: CircularProgressIndicator(color: Colors.white));
              }

              if (bailProvider.bauxLocataire.isEmpty) {
                return Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(color: Colors.white30, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Pas encore de logement ?",
                        style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 5),
                      const Text(
                        "Trouvez votre future maison dès maintenant.",
                        style: TextStyle(color: Colors.white70, fontSize: 13),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const SearchScreen()));
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: const Color(0xFF1E3E8A),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: const Text("Rechercher un bien"),
                      )
                    ],
                  ),
                );
              }

              final bail = bailProvider.bauxLocataire.first;

              return Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
                decoration: BoxDecoration(
                  color: const Color(0xFF2C4FA1),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Prochain loyer",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "${bail.montantLoyer} FCFA",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            "Échéance le 05 du mois",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      width: 42,
                      height: 42,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(color: const Color(0xFFFFB59E), width: 2),
                      ),
                      child: const Center(
                        child: Text(
                          "!",
                          style: TextStyle(
                            color: Color(0xFFFFB59E),
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            height: 1,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _QuickActionsGrid extends StatelessWidget {
  const _QuickActionsGrid();

  @override
  Widget build(BuildContext context) {
    return GridView(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 18,
        mainAxisSpacing: 18,
        childAspectRatio: 1.12,
      ),
      children: [
        _ActionCard(
          title: "Payer Loyer",
          subtitle: "Paiement Securise",
          icon: Icons.credit_card_rounded,
          iconColor: const Color(0xFF1E3E8A),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SelectLogementScreen()),
            );
          },
        ),
        _ActionCard(
          title: "Mes Baux",
          subtitle: "Info et Document",
          icon: Icons.home_rounded,
          iconColor: const Color(0xFFFF7B66),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const BauxScreen()),
            );
          },
        ),
        _ActionCard(
          title: "Mes Logement",
          subtitle: "Gestion Logement",
          icon: Icons.home_work_rounded,
          iconColor: const Color(0xFFFF7B66),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const LogementsScreen()),
            );
          },
        ),
        _ActionCard(
          title: "Rechercher",
          subtitle: "Trouver Logement",
          icon: Icons.search_rounded,
          iconColor: const Color(0xFF2AA5DA),
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SearchScreen()),
            );
          },
        ),
      ],
    );
  }
}

class _ActionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconColor;
  final VoidCallback onTap;

  const _ActionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(20),
          boxShadow: const [
            BoxShadow(
              color: Color(0x26000000),
              offset: Offset(4, 4),
              blurRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 36, color: iconColor),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: Color(0xFF111111),
                height: 1.1,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w500,
                color: Color(0xFF8C8C8C),
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}