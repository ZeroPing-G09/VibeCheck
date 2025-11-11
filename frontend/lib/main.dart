import 'dart:async';
import 'package:flutter/material.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/ui/auth/auth_gate.dart';

void main() {
  runZonedGuarded(() async {
    WidgetsFlutterBinding.ensureInitialized();
    await ApiService.init();
    runApp(const MyApp());
  }, (error, stack) {
    // Prevent crashes from auth deeplink errors; log instead.
    debugPrint('Auth deeplink error: $error');
  });
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeCheck',
      theme: ThemeData(
        colorSchemeSeed: Colors.deepPurple,
        useMaterial3: true,
      ),
      home: const AuthGate(),
    );
  }
}
