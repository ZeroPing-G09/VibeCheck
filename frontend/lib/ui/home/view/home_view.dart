import 'package:flutter/material.dart';
import 'package:frontend/ui/components/bottom_nav_bar.dart';
import 'package:frontend/ui/dashboard/view/dashboard_view.dart';
import 'package:frontend/ui/profile/view/profile_view.dart';
import 'package:frontend/ui/settings/view/settings_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();

  static _HomeViewState? of(BuildContext context) {
    return context.findAncestorStateOfType<_HomeViewState>();
  }
}

class _HomeViewState extends State<HomeView> {
  int _currentIndex = 1;

  final List<Widget> _pages = const [
    ProfileView(),
    DashboardView(),
    SettingsView(),
  ];

  void switchToTab(int index) {
    setState(() => _currentIndex = index);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() => _currentIndex = index);
        },
      ),
    );
  }
}
