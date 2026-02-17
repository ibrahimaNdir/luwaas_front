import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:luwaas/presentation/commun/notif_screen.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart' hide AuthProvider; // ✅ AJOUTÉ hide
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../presentation/provider/PropertyProvider.dart';
import '../../presentation/provider/DemandeProvider.dart';
import '../../presentation/provider/notification_provider.dart';
import '../../presentation/provider/auth_provider.dart'; // Votre AuthProvider
import '../../data/model/property.dart';
import 'add_property_screen.dart';
import 'demande_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final FirebaseMessaging _messaging;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    print("🚀 HomeScreen initState");

    _messaging = FirebaseMessaging.instance;

    // Charger les données après l'affichage
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      print("⏰ PostFrameCallback - Début initialisation");
      await _initializeData();
    });

    _initForegroundMessagingListener();
  }

  Future<void> _initializeData() async {
    try {
      // Attendre que l'auth soit prête
      await Future.delayed(const Duration(milliseconds: 500));

      if (!mounted) return;

      final authProvider = context.read<AuthProvider>();
      print("👤 AuthProvider - User: ${authProvider.user?.email ?? 'null'}");

      // Charger les propriétés
      print("🏠 Chargement des propriétés...");
      await context.read<PropertyProvider>().loadOwnerProperties();

      // Charger les demandes si connecté
      if (authProvider.user != null) {
        print("✅ Utilisateur connecté, chargement des demandes...");
        await context.read<DemandeProvider>().fetchDemandesBailleur();

        final demandeProvider = context.read<DemandeProvider>();
        print("📋 Demandes chargées: ${demandeProvider.demandes.length}");
        print("📊 Demandes en attente: ${demandeProvider.demandes.where((d) => d.status == 'en_attente').length}");
      } else {
        print("⚠️ Pas d'utilisateur connecté");
      }

      await _initNotificationListener();

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
        print("✅ Initialisation terminée");
      }
    } catch (e) {
      print("❌ Erreur initialisation: $e");
    }
  }

  Future<void> _initNotificationListener() async {
    final firebaseUserId = FirebaseAuth.instance.currentUser?.uid;
    final prefs = await SharedPreferences.getInstance();
    final laravelUserId = prefs.getInt('userId')?.toString();
    final userId = firebaseUserId ?? laravelUserId;

    print("🔔 Notification userId: $userId");

    if (userId != null && mounted) {
      Provider.of<NotificationProvider>(context, listen: false)
          .listenToNotifications(userId);
    }
  }

  void _initForegroundMessagingListener() {
    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      final notification = message.notification;
      if (!mounted) return;

      if (notification != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(notification.title ?? 'Nouvelle notification'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.blue,
          ),
        );
      }
    });
  }

  void _goToAddProperty(String type) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => AddPropertyScreen(propertyType: type)),
    );
  }

  void _goToNotifications() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const NotifScreen()),
    );
  }

  void _goToDemandes() {
    print("🔥 _goToDemandes appelée !");

    final authProvider = context.read<AuthProvider>();
    print("👤 User dans _goToDemandes: ${authProvider.user?.email ?? 'null'}");

    if (authProvider.user == null) {
      print("⚠️ Utilisateur non connecté");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Veuillez vous connecter pour voir vos demandes"),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    print("➡️ Navigation vers DemandeScreen");
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const DemandeScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final isLoggedIn = authProvider.user != null;

    print("🔄 Build - isLoggedIn: $isLoggedIn, _isInitialized: $_isInitialized");

    // Afficher un loader pendant l'initialisation
    if (!_isInitialized) {
      return const Scaffold(
        backgroundColor: Color(0xFF1E3A8A),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 20),
              Text(
                "Chargement...",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
        ),
      );
    }

    return Material(
      child: CustomScrollView(
        slivers: [
          // 🔵 HEADER BLEU
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Container(
                decoration: const BoxDecoration(
                  color: Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(30),
                    bottomRight: Radius.circular(30),
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 30),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // 1. LA LIGNE DU HAUT (Icônes)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        // --- A. GESTION DES DEMANDES ---
                        Consumer<DemandeProvider>(
                          builder: (context, provider, child) {
                            final count = isLoggedIn
                                ? provider.demandes
                                .where((d) => d.status == 'en_attente')
                                .length
                                : 0;

                            return GestureDetector(
                              onTap: () {
                                print("👆 TAP DÉTECTÉ sur l'icône add_home !");
                                _goToDemandes();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(
                                      Icons.add_home_outlined,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                    if (count > 0)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: _buildBadge(count),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),

                        // ✅ B. NOTIFICATIONS
                        Consumer<NotificationProvider>(
                          builder: (context, notifProvider, child) {
                            return GestureDetector(
                              onTap: () {
                                print("👆 TAP DÉTECTÉ sur notifications !");
                                _goToNotifications();
                              },
                              behavior: HitTestBehavior.opaque,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                child: Stack(
                                  clipBehavior: Clip.none,
                                  children: [
                                    const Icon(
                                      Icons.notifications_none,
                                      color: Colors.white,
                                      size: 34,
                                    ),
                                    if (notifProvider.unreadCount > 0)
                                      Positioned(
                                        right: -2,
                                        top: -2,
                                        child: _buildBadge(notifProvider.unreadCount),
                                      ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // 2. BARRE DE RECHERCHE
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Rechercher",
                        hintStyle: TextStyle(color: Colors.grey[400]),
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search, color: Colors.grey),
                        contentPadding: const EdgeInsets.symmetric(vertical: 0),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(15),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),

                    const SizedBox(height: 25),

                    // 3. TEXTE ET ILLUSTRATION
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("Louez.",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("Encaissez.",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                              SizedBox(height: 4),
                              Text("Gérez",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold)),
                            ],
                          ),
                          SvgPicture.asset(
                            'assets/images/searching house.svg',
                            width: 100,
                            height: 100,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // BODY (Propriétés)
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Catégories",
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  const SizedBox(height: 15),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _categoryButton("VILLA", Icons.villa,
                            onPressed: () => _goToAddProperty("villa")),
                        const SizedBox(width: 15),
                        _categoryButton("MAISON", Icons.home,
                            onPressed: () => _goToAddProperty("maison")),
                        const SizedBox(width: 15),
                        _categoryButton("IMMEUBLE", Icons.apartment,
                            onPressed: () => _goToAddProperty("immeuble")),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text("Vos Propriétés",
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                      Text("Voir Tous",
                          style: TextStyle(
                              color: Color(0xFF1E3A8A), fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Consumer<PropertyProvider>(
                    builder: (context, provider, _) {
                      if (provider.isLoading) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(20),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }
                      if (provider.properties.isEmpty) {
                        return Center(
                          child: Column(
                            children: [
                              const SizedBox(height: 20),
                              Icon(Icons.house_siding_rounded,
                                  size: 60, color: Colors.grey[300]),
                              const SizedBox(height: 10),
                              Text("Aucune propriété ajoutée",
                                  style: TextStyle(color: Colors.grey[500])),
                            ],
                          ),
                        );
                      }
                      return Column(
                        children: provider.properties
                            .take(3)
                            .map(
                              (p) => Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.blue[50],
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: const Icon(Icons.home,
                                    color: Color(0xFF1E3A8A)),
                              ),
                              title: Text(p.titre,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold)),
                              subtitle: Text(p.adresse),
                              trailing: const Icon(Icons.arrow_forward_ios,
                                  size: 14, color: Colors.grey),
                            ),
                          ),
                        )
                            .toList(),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBadge(int count) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: const BoxDecoration(
        color: Colors.orange,
        shape: BoxShape.circle,
        border: Border.fromBorderSide(
          BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
        ),
      ),
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      child: Center(
        child: Text(
          '$count',
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _categoryButton(String label, IconData icon,
      {required VoidCallback onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F7FA),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(icon, size: 20, color: const Color(0xFF1E3A8A)),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF1E3A8A),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }
}