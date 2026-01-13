import 'package:flutter/material.dart';

/// Bottom navigation bar for the main app
/// Displays Profile, Dashboard, and Settings tabs
class BottomNavBar extends StatelessWidget {

  /// Creates a [BottomNavBar] with [currentIndex] and [onTap] callback
  const BottomNavBar({
    required this.currentIndex, required this.onTap, super.key,
  });
  /// Currently selected tab index
  final int currentIndex;

  /// Callback when a tab is tapped
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: onTap,
      selectedItemColor: Colors.indigo,
      unselectedItemColor: Colors.grey,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        BottomNavigationBarItem
        (icon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.settings), label: 'Settings'),
      ],
    );
  }
}
