import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:go_router/go_router.dart';

import '../../../ui/profile/view/profile_view.dart';
import '../../../ui/dashboard/view/dashboard_view.dart';
import '../../../ui/settings/view/settings_view.dart';
import '../../components/bottom_nav_bar.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _authRepo = AuthRepository();
  bool _signingOut = false;
  int _currentIndex = 0;

  final List<Widget> _pages = const [
    ProfileView(),
    DashboardView(),
    SettingsView(),
  ];

  Future<void> _logout() async {
    setState(() => _signingOut = true);
    try {
      await _authRepo.signOut();

      if (mounted) {
        context.go('/login'); // redirect immediately
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesiunea a fost închisă.')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Eroare la logout.')),
        );
      }
    } finally {
      if (mounted) setState(() => _signingOut = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('VibeCheck'),
        actions: [
          IconButton(
            onPressed: _signingOut ? null : _logout,
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
          ),
        ],
      ),
      body: IndexedStack(index: _currentIndex, children: _pages),
      bottomNavigationBar: BottomNavBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
      ),
    );
  }
}
