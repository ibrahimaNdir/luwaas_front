import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'home_screen.dart';
import 'property_screen.dart';
import 'dashboard_screen.dart';
import 'paiement_screen.dart'; // ✅ Renommé pour correspondre
import 'bails_screen.dart';
import 'account_screen.dart';

class MainScreenBailleur extends StatefulWidget {
  const MainScreenBailleur({Key? key}) : super(key: key);

  @override
  State<MainScreenBailleur> createState() => _MainScreenBailleurState();
}

class _MainScreenBailleurState extends State<MainScreenBailleur> {
  int _selectedIndex = 0;

  // Liste des écrans correspondant aux items de la BottomBar
  static const List<Widget> _screens = [
    HomeScreen(),          // Accueil
    PropertyScreen(),      // Propriétés
    DashboardScreen(),     // Dashboard
    PaymentsScreen(),      // Paiements (✅ corrigé)
    BailScreen(),         // Bails (pluriel cohérent)
    AccountScreen(),       // Compte
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}