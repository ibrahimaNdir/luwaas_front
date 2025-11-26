import 'package:flutter/material.dart';
import 'bottom_bar.dart';
import 'home_screen.dart'; // Exemple d'écran Home pour bailleur
import 'property_screen.dart'; // Exemple d'écran Propriétés
import 'dashboard_screen.dart'; // Exemple Dashboard
import 'locataire_screen.dart'; // Exemple Locataire
import 'bails_screen.dart';
import 'account_screen.dart'; // Exemple Compte

class MainScreenBailleur extends StatefulWidget {
  const MainScreenBailleur({Key? key}) : super(key: key);

  @override
  State<MainScreenBailleur> createState() => _MainScreenBailleurState();
}

class _MainScreenBailleurState extends State<MainScreenBailleur> {
  int _selectedIndex = 0;

  final List<Widget> _screens = const [
    HomeScreen(),
    PropertyScreen(),
    DashboardScreen(),
    LocataireScreen(),
    BailScreen(),
    AccountScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
