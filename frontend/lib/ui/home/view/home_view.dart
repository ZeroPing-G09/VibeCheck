import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  final _authRepo = AuthRepository();
  bool _signingOut = false;

  Future<void> _logout() async {
    setState(() => _signingOut = true);
    try {
      await _authRepo.signOut();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Sesiunea a fost închisă.')),
        );
      }
      // AuthGate will automatically switch to LoginView.
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
      body: const Center(
        child: Text('Dashboard / Home content here'),
      ),
    );
  }
}
