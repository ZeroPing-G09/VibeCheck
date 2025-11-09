import 'package:flutter/material.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final AuthRepository _authRepo = AuthRepository();
  bool _loading = false;
  String? _error;

  void _login() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      await _authRepo.signInWithSpotify();
    } catch (e) {
      setState(() => _error = 'Login failed. Please try again.');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (_loading) const CircularProgressIndicator(),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(_error!, style: const TextStyle(color: Colors.red)),
              ),
            ElevatedButton.icon(
              onPressed: _loading ? null : _login,
              icon: const Icon(Icons.music_note),
              label: const Text('Login with Spotify'),
            ),
          ],
        ),
      ),
    );
  }
}
