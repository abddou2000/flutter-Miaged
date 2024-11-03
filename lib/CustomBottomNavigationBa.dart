import 'package:flutter/material.dart';
import 'profile_screen.dart';
import 'dashboard.dart';
import 'CartScreen.dart';

class CustomBottomNavigationBar extends StatelessWidget {
  final int currentIndex;

  const CustomBottomNavigationBar({Key? key, required this.currentIndex}) : super(key: key);

  void _onItemTapped(BuildContext context, int index) {
    if (index == currentIndex) return;

    Widget targetPage;
    switch (index) {
      case 0:
        targetPage = const Dashboard();
        break;
      case 1:
        targetPage = const CartScreen();
        break;
      case 2:
        targetPage = const ProfileScreen();
        break;
      default:
        return;
    }

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => targetPage),
      (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_bag),
          label: 'Acheter',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.shopping_cart),
          label: 'Panier',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.person),
          label: 'Profil',
        ),
      ],
      currentIndex: currentIndex,
      onTap: (index) => _onItemTapped(context, index),
    );
  }
}
