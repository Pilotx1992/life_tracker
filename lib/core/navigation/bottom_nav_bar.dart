import 'package:flutter/material.dart';

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const BottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return NavigationBar(
      selectedIndex: currentIndex,
      onDestinationSelected: onTap,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.monitor_heart),
          label: 'Health',
        ),
        NavigationDestination(
          icon: Icon(Icons.account_balance_wallet),
          label: 'Finance',
        ),
        NavigationDestination(
          icon: Icon(Icons.settings),
          label: 'Settings',
        ),
      ],
    );
  }
}
