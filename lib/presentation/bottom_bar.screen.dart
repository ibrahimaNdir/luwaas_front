import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BottomBar extends StatelessWidget {
  static const Color _selectedColor = Color(0xFF2E4B8C); // Bleu Luwaas
  static const Color _unselectedColor = Color(0xFFFFFFFF); // Gris visible
  static const Color _backgroundColor = Colors.white;

  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomBar({
    Key? key,
    required this.currentIndex,
    required this.onTap,
  }) : super(key: key);

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
        backgroundColor: Colors.transparent,
        selectedItemColor: _selectedColor,
        unselectedItemColor: _unselectedColor,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        selectedFontSize: 12,
        unselectedFontSize: 11, // Légère différence
        elevation: 0,
        items: _buildItems(),
      ),
    );
  }

  List<BottomNavigationBarItem> _buildItems() {
    final items = [
      {'asset': 'assets/icons/house_welcome.svg', 'label': 'Accueil'},
      {'asset': 'assets/icons/house.svg', 'label': 'Propriétés'},
      {'asset': 'assets/icons/dashboard.svg', 'label': 'Dashboard'},
      {'asset': 'assets/icons/credit.svg', 'label': 'Paiements'},
      {'asset': 'assets/icons/files.svg', 'label': 'Bails'},
      {'asset': 'assets/icons/user.svg', 'label': 'Compte'},
    ];

    return items.asMap().entries.map((entry) {
      final index = entry.key;
      final item = entry.value;
      final isSelected = currentIndex == index;

      return BottomNavigationBarItem(
        icon: _buildIcon(
          asset: item['asset']!,
          isSelected: isSelected,
        ),
        label: item['label'],
      );
    }).toList();
  }

  Widget _buildIcon({required String asset, required bool isSelected}) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        SvgPicture.asset(
          asset,
          width: 24,
          height: 24,
          colorFilter: ColorFilter.mode(
            isSelected ? _selectedColor : _unselectedColor,
            BlendMode.srcIn,
          ),
        ),
        const SizedBox(height: 6),
        AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
          height: 4,
          width: isSelected ? 20 : 0,
          decoration: BoxDecoration(
            color: _selectedColor,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
      ],
    );
  }
}
