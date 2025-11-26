import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_svg/flutter_svg.dart';

// Écran Accueil
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int notificationCount = 0;
  String currentUserId = "TonUserID"; // Remplace par ton user réel

  @override
  void initState() {
    super.initState();
    _listenToNotifications();
  }

  void _listenToNotifications() {
    FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: currentUserId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .listen((snapshot) {
          if (mounted) {
            setState(() {
              notificationCount = snapshot.docs.length;
            });
          }
        });
  }

  void _navigateToAddProperty(String category) {
    // Ici tu navigues vers ton écran d'ajout existant
    // Navigator.push(context, MaterialPageRoute(builder: (context) => YourAddScreen(category: category)));

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigation vers ajout de $category'),
        backgroundColor: const Color(0xFF263A8B),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(16),
                    bottomRight: Radius.circular(16),
                  ),
                ),

                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Bienvenue Ibou !",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            // Navigation vers écran notifications
                            /* Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const NotificationsScreen(),
                          ),
                        ); */
                          },
                          child: Stack(
                            children: [
                              const Icon(
                                Icons.notifications,
                                color: Colors.white,
                                size: 32,
                              ),
                              if (notificationCount > 0)
                                Positioned(
                                  right: 0,
                                  top: 0,
                                  child: Container(
                                    width: 12,
                                    height: 12,
                                    decoration: const BoxDecoration(
                                      color: Colors.red,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Rechercher",
                        filled: true,
                        fillColor: Colors.white,
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(32),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Container(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          SvgPicture.asset(
                            'assets/images/searching house.svg',
                            width: 40,
                            height: 40,
                            colorFilter: const ColorFilter.mode(
                              Colors.white,
                              BlendMode.srcIn,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  "Louez.\nEncaissez.\nGérez.",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: const Color(0xFF263A8B),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                  ),
                                  onPressed: () {},
                                  child: const Text("Commencer"),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Catégories",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 16, // espace horizontal
                    runSpacing: 16, // espace vertical
                    children: [
                      categoryButton(
                        "VILLA",
                        Icons.villa,
                        onPressed: () {
                          // Action quand on clique sur VILLA
                          print("VILLA sélectionnée");
                        },
                      ),
                      categoryButton(
                        "MAISON",
                        Icons.home,
                        onPressed: () {
                          // Action quand on clique sur MAISON
                          print("MAISON sélectionnée");
                        },
                      ),
                      categoryButton(
                        "IMMEUBLE",
                        Icons.apartment,
                        onPressed: () {
                          // Action quand on clique sur IMMEUBLE
                          print("IMMEUBLE sélectionnée");
                        },
                      ),
                    ],
                  ),

                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        "Vos Propriétés",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          // Navigation vers la liste complète
                        },
                        child: const Text(
                          "Voir Tous",
                          style: TextStyle(color: Colors.blue),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.home_outlined,
                          size: 52,
                          color: Colors.grey[400],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "Aucune propriété ajoutée pour le moment",
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget categoryButton(
    String label,
    IconData icon, {
    required VoidCallback onPressed,
  }) {
    return GestureDetector(
      onTap: () {},
      child: Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: const Color(0xFFF2F2F2), // gris très pâle comme ton image
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Petit carré blanc autour de l'icône
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 24,
                color: const Color(0xFF263A8B), // même bleu que ton image
              ),
            ),

            const SizedBox(width: 12),

            Text(
              label,
              style: const TextStyle(
                color: Color(0xFF263A8B),
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
