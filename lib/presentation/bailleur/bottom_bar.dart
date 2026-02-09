import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

  // Méthode pour créer les icônes avec changement de couleur
  Widget _buildIcon(String assetPath, int index) {
    final isSelected = currentIndex == index;

    return SvgPicture.asset(
      assetPath,
      width: 24,
      height: 24,
      colorFilter: ColorFilter.mode(
        isSelected
            ? const Color(0xFF2E4B8C)  // Bleu si sélectionné
            : const Color(0xFF9E9E9E),  // Gris si non sélectionné
        BlendMode.srcIn,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xFF2E4B8C),
      unselectedItemColor: const Color(0xFF9E9E9E),
      backgroundColor: const Color(0xFFFFFFFF),
      selectedFontSize: 12,
      unselectedFontSize: 12,
      items: [
        BottomNavigationBarItem(
          icon: _buildIcon("assets/icons/house_welcome.svg", 0),
          label: "Accueil",
        ),
        BottomNavigationBarItem(
          icon: _buildIcon("assets/icons/house.svg", 1),
          label: "Biens",
        ),
        BottomNavigationBarItem(
          icon: _buildIcon("assets/icons/search.svg", 2),
          label: "Logements",
        ),
        BottomNavigationBarItem(
          icon: _buildIcon("assets/icons/credit.svg", 3),
          label: "Paiements",
        ),
        BottomNavigationBarItem(
          icon: _buildIcon("assets/icons/file.svg", 4),
          label: "Bails",
        ),
        BottomNavigationBarItem(
          icon: _buildIcon("assets/icons/user.svg", 5),
          label: "Compte",
        ),
      ],
    );
  }
}
