import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/ui/settings/viewmodel/theme_view_model.dart';

class VibeCheckApp extends StatefulWidget {
  const VibeCheckApp({super.key});

  @override
  State<VibeCheckApp> createState() => _VibeCheckAppState();
}

class _VibeCheckAppState extends State<VibeCheckApp> {
  final AuthRepository _authRepo = AuthRepository();
  Session? _session;
  StreamSubscription<AuthState>? _authSubscription;
  String? _currentRoute;

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;
    _currentRoute = AppRouter.dashboardRoute;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncRouteWithSession(_session);
    });

    _authSubscription = _authRepo.onAuthStateChange.listen((data) {
      setState(() => _session = data.session);
      _syncRouteWithSession(data.session);
    });
  }

  void _syncRouteWithSession(Session? session) {
    final navigator = AppRouter.navigatorKey.currentState;
    if (navigator == null) return;

    final targetRoute =
        session == null ? AppRouter.loginRoute : AppRouter.dashboardRoute;
    if (_currentRoute == targetRoute) {
      return;
    }

    navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
    _currentRoute = targetRoute;
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeViewModel>(
      builder: (context, themeViewModel, child) {
        return MaterialApp(
          title: 'VibeCheck',
          theme: ThemeData.light(),
          darkTheme: ThemeData.dark(),
          themeMode: themeViewModel.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          navigatorKey: AppRouter.navigatorKey,
          initialRoute: AppRouter.initialRoute,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
