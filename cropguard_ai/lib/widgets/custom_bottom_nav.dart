import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class CustomBottomNav extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNav({
    super.key,
    required this.currentIndex,
  });

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;
    
    String routeName = '/home';
    switch (index) {
      case 0:
        routeName = '/home';
        break;
      case 1:
        routeName = '/scan';
        break;
      case 2:
        routeName = '/history';
        break;
      case 3:
        routeName = '/settings';
        break;
    }
    
    Navigator.pushReplacementNamed(context, routeName);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.bottomNavBackground,
        border: Border(
          top: BorderSide(color: Colors.white.withOpacity(0.05), width: 1),
        ),
      ),
      child: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => _onItemTapped(context, index),
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard),
            label: 'DASHBOARD',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.filter_center_focus),
            label: 'ANALYZE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_shared),
            label: 'ARCHIVE',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'SETTINGS',
          ),
        ],
      ),
    );
  }
}
