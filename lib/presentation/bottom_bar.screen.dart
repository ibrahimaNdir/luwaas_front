import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomBar extends StatelessWidget {
  // ✅ 1. Actif : Ton Bleu Luwaas
  static const Color _selectedColor = Color(0xFF2E4B8C);

  // ✅ 2. Inactif : Un Gris doux et moderne (évite le gris par défaut parfois trop sombre)
  static const Color _unselectedColor = Color(0xFFFFFFFF);

  // ✅ 3. Fond : Blanc pur
  static const Color _backgroundColor = Colors.white;

  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  BottomNavigationBarItem _customItem({
    required String asset,
    required String label,
    required int index, // On a besoin de l'index pour savoir si c'est actif
  }) {
    final bool isSelected = currentIndex == index;

    return BottomNavigationBarItem(
      // On utilise 'icon' pour tout faire, car BottomNavBarItem supporte les Widgets complexes
      icon: Column(
        mainAxisSize: MainAxisSize.min, // Prend le minimum de place
        children: [
          // 1. L'ICÔNE SVG
          SvgPicture.asset(
            asset,
            width: 24,
            height: 24,
            colorFilter: ColorFilter.mode(
              isSelected ? _selectedColor : _unselectedColor,
              BlendMode.srcIn,
            ),
          ),

          const SizedBox(height: 6), // Espace entre icône et barre

          // 2. LA BARRE ANIMÉE
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            height: 4, // Épaisseur de la barre
            width: isSelected ? 20 : 0, // Largeur (20 si actif, 0 si inactif)
            decoration: BoxDecoration(
              color: _selectedColor,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
        ],
      ),
      label: label,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: _backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: currentIndex,
        onTap: onTap,
        backgroundColor: Colors.transparent, // On gère la couleur via le Container
        selectedItemColor: _selectedColor,
        unselectedItemColor: _unselectedColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 12,
        elevation: 0, // On enlève l'ombre par défaut pour mettre la nôtre
        items: [
          _customItem(
            asset: 'assets/icons/house_welcome.svg',
            label: 'Accueil',
            index: 0,
          ),
          _customItem(
            asset: 'assets/icons/house.svg',
            label: 'Propriétés',
            index: 1,
          ),
          _customItem(
            asset: 'assets/icons/dashboard.svg',
            label: 'Dashboard',
            index: 2,
          ),
          // Si tu veux enlever Paiements et Bails pour alléger, commente les lignes ci-dessous
          _customItem(
            asset: 'assets/icons/credit.svg',
            label: 'Paiements',
            index: 3,
          ),
          _customItem(
            asset: 'assets/icons/files.svg',
            label: 'Bails',
            index: 4,
          ),
          _customItem(
            asset: 'assets/icons/user.svg',
            label: 'Compte',
            index: 5,
          ),
        ],
      ),
    );
  }
}
