import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'ui/auth/view/login_view.dart';
import 'di/locator.dart';
import 'core/auth/auth_notifier.dart';
import 'ui/home/view/home_view.dart';

final AuthNotifier _auth = locator<AuthNotifier>();

final GoRouter appRouter = GoRouter(
  initialLocation: '/splash',
  refreshListenable: _auth,
  routes: [
    GoRoute(
      path: '/splash',
      builder: (_, __) => const _SplashDecider(),
    ),
    GoRoute(
      path: '/login',
      builder: (_, __) => const LoginView(), // keep your current login view import if needed
    ),
    GoRoute(
      path: '/dashboard',
      builder: (_, __) => const HomeView(),
    ),
  ],
  redirect: (context, state) {
    final loggedIn = Supabase.instance.client.auth.currentSession != null;
    final loggingIn = state.matchedLocation == '/login';

    if (!loggedIn && state.matchedLocation != '/splash' && !loggingIn) {
      return '/login';
    }
    if (loggedIn && loggingIn) return '/dashboard';
    return null;
  },
);

// tiny splash
class _SplashDecider extends StatelessWidget {
  const _SplashDecider({super.key});
  @override
  Widget build(BuildContext context) {
    final loggedIn = Supabase.instance.client.auth.currentSession != null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.go(loggedIn ? '/dashboard' : '/login');
    });
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}