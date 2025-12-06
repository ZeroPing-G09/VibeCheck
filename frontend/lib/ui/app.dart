import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/onboarding_repository.dart';
import 'package:frontend/di/locator.dart';
import 'package:frontend/ui/settings/viewmodel/theme_view_model.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class VibeCheckApp extends StatefulWidget {
  const VibeCheckApp({super.key});

  @override
  State<VibeCheckApp> createState() => _VibeCheckAppState();
}

class _VibeCheckAppState extends State<VibeCheckApp> {
  final AuthRepository _authRepo = locator<AuthRepository>();
  final OnboardingRepository _onboardingRepo = locator<OnboardingRepository>();
  Session? _session;
  StreamSubscription<AuthState>? _authSubscription;
  String? _currentRoute;
  bool _isCheckingOnboarding = false;

  @override
  void initState() {
    super.initState();
    _session = Supabase.instance.client.auth.currentSession;
    // Initialize route based on session state
    _currentRoute = _session == null 
        ? AppRouter.loginRoute 
        : AppRouter.dashboardRoute;

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _syncRouteWithSession(_session);
    });

    _authSubscription = _authRepo.onAuthStateChange.listen((data) {
      setState(() => _session = data.session);
      _syncRouteWithSession(data.session);
    });
  }

  Future<void> _syncRouteWithSession(Session? session) async {
    final navigator = AppRouter.navigatorKey.currentState;
    if (navigator == null) {
      return;
    }

    if (session == null) {
      final targetRoute = AppRouter.loginRoute;
      if (_currentRoute != targetRoute) {
        debugPrint('Navigating to login route: $targetRoute');
        navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
        _currentRoute = targetRoute;
      }
      return;
    }

    if (!_isCheckingOnboarding) {
      _isCheckingOnboarding = true;
      try {
        final email = session.user.email;
        if (email != null) {
          final needsOnboarding = await _onboardingRepo.needsOnboarding(email);
          
          final targetRoute = needsOnboarding
              ? AppRouter.onboardingRoute
              : AppRouter.dashboardRoute;
          
          if (_currentRoute != targetRoute) {
            navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
            _currentRoute = targetRoute;
          }
        } else {
          final targetRoute = AppRouter.dashboardRoute;
          if (_currentRoute != targetRoute) {
            navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
            _currentRoute = targetRoute;
          }
        }
      } catch (e) {
        // On error, default to dashboard
        final targetRoute = AppRouter.dashboardRoute;
        if (_currentRoute != targetRoute) {
          navigator.pushNamedAndRemoveUntil(targetRoute, (route) => false);
          _currentRoute = targetRoute;
        }
      } finally {
        _isCheckingOnboarding = false;
      }
    }
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
          themeMode: themeViewModel.isDarkMode
              ? ThemeMode.dark
              : ThemeMode.light,
          navigatorKey: AppRouter.navigatorKey,
          initialRoute: _session == null 
              ? AppRouter.loginRoute 
              : AppRouter.dashboardRoute,
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
