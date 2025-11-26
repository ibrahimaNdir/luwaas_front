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

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: const Color(0xFF2E4B8C), // navy color
      backgroundColor: const Color(0xFFDCD9D9), // #979797 avec 4% d'opacité
      items: [
        BottomNavigationBarItem(
          icon: SvgPicture.asset("assets/icons/house_welcome.svg", width: 24),
          label: "Accueil",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset("assets/icons/house.svg", width: 24),
          label: "Propriétés",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset("assets/icons/dashboard.svg", width: 24),
          label: "Dashboard",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset("assets/icons/users.svg", width: 24),
          label: "Locataire",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset("assets/icons/bails.svg", width: 24),
          label: "Bails",
        ),
        BottomNavigationBarItem(
          icon: SvgPicture.asset("assets/icons/user.svg", width: 24),
          label: "Compte",
        ),
      ],
    );
  }
}