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
  StreamSubscription<AuthState>? _authSubscription;
  String? _currentRoute;
  bool _isCheckingOnboarding = false;

  @override
  void initState() {
    super.initState();
    // Initialize route based on session state
    _currentRoute = null;

    _authSubscription = _authRepo.onAuthStateChange.listen((data) {
      _syncRouteWithSession(data.session);
    });
  }

  Future<void> _syncRouteWithSession(Session? session) async {
  final navigator = AppRouter.navigatorKey.currentState;
  if (navigator == null) return;

  // 🔓 Not logged in → go to login immediately
  if (session == null) {
    _navigateOnce(AppRouter.loginRoute);
    return;
  }

  // ✅ Logged in → ALWAYS enter app immediately
  _navigateOnce(AppRouter.dashboardRoute);

  // 🔄 Check onboarding asynchronously (never block UI)
  _checkOnboardingInBackground(session);
}

void _navigateOnce(String route) async {
  if (_currentRoute == route) return;

  await AppRouter.navigatorKey.currentState!
      .pushNamedAndRemoveUntil(route, (route) => false);

  _currentRoute = route;
}

Future<void> _checkOnboardingInBackground(Session session) async {
  if (_isCheckingOnboarding) return;

  _isCheckingOnboarding = true;
  try {
    final email = session.user.email;
    if (email == null) return;

    final needsOnboarding = await _onboardingRepo
        .needsOnboarding(email)
        .timeout(const Duration(seconds: 5));

    if (needsOnboarding) {
      _navigateOnce(AppRouter.onboardingRoute);
    }
  } catch (e) {
    // Backend down? Offline? Timeout?
    // → Ignore and keep user in app
    debugPrint('Onboarding check skipped: $e');
  } finally {
    _isCheckingOnboarding = false;
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
          initialRoute: '/',
          onGenerateRoute: AppRouter.generateRoute,
        );
      },
    );
  }
}
