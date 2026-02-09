import 'package:flutter/material.dart';
import 'package:luwaas/presentation/bailleur/logement_publie.dart';
import 'package:provider/provider.dart'; // ✅ Ajoutez cet import
import 'package:luwaas/presentation/provider/BailProvider.dart'; // ✅ Ajoutez cet import
import 'bottom_bar.dart';
import 'home_screen.dart';
import 'property_screen.dart';
import 'dashboard_screen.dart';
import 'logement_publie.dart';
import 'paiement_screen.dart';
import 'bails_screen.dart';
import 'account_screen.dart';

class MainScreenBailleur extends StatefulWidget {
  const MainScreenBailleur({Key? key}) : super(key: key);

  @override
  State<MainScreenBailleur> createState() => _MainScreenBailleurState();
}

class _MainScreenBailleurState extends State<MainScreenBailleur> {
  int _selectedIndex = 0;

  // ✅ AJOUTEZ CECI
  @override
  void initState() {
    super.initState();

    // Charger les baux dès que le bailleur arrive sur l'écran principal
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint("🔵 MainScreenBailleur: Chargement des baux");
      Provider.of<BailProvider>(context, listen: false).fetchBauxBailleur();
    });
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final screens = <Widget>[
      const HomeScreen(),
      const PropertyScreen(),
      const LogementPublieScreen(),
      const PaymentsScreen(),
      const BailScreen(),
      const AccountScreen(),
    ];

    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: screens,
      ),
      bottomNavigationBar: BottomBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }
}
