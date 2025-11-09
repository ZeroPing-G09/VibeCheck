import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/ui/auth/view/login_view.dart';
import 'package:frontend/ui/dashboard/view/dashboard_view.dart';

class VibeCheckApp extends StatefulWidget {
  const VibeCheckApp({super.key});

  @override
  State<VibeCheckApp> createState() => _VibeCheckAppState();
}

class _VibeCheckAppState extends State<VibeCheckApp> {
  final AuthRepository _authRepo = AuthRepository();
  Session? _session;

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;
    _authRepo.onAuthStateChange.listen((data) {
      setState(() => _session = data.session);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'VibeCheck',
      theme: ThemeData.dark(),
      home: _session == null ? const LoginView() : const DashboardView(),
    );
  }
}
