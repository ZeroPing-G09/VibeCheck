import 'package:flutter/material.dart';
import 'package:frontend/core/routing/oauth-handler.dart';
import 'package:frontend/ui/auth/view/login_view.dart';
import 'package:frontend/ui/home/view/home_view.dart';
import 'package:frontend/ui/onboarding/view/onboarding_view.dart';
import 'package:frontend/ui/profile/view/profile_view.dart';
import 'package:frontend/ui/settings/view/settings_view.dart';

class AppRouter {
  AppRouter._();

  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String loginRoute = '/login';
  static const String dashboardRoute = '/dashboard';
  static const String profileRoute = '/profile';
  static const String settingsRoute = '/settings';
  static const String onboardingRoute = '/onboarding';

  static const String initialRoute = dashboardRoute;

  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('Generating route for: ${settings.name}');

    if (settings.name == null) {
      debugPrint('Route name is null, defaulting to login');
      return MaterialPageRoute(builder: (_) => const LoginView());
    }

    if (settings.name!.startsWith('/?') || settings.name!.contains('code=')) {
      return MaterialPageRoute(
        builder: (_) => OAuthCallbackHandler(callbackRoute: settings.name!),
      );
    }

    switch (settings.name) {
      case '/':
        return MaterialPageRoute(
          builder: (_) =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
        );
      case loginRoute:
        return MaterialPageRoute(builder: (_) => const LoginView());
      case dashboardRoute:
        return MaterialPageRoute(builder: (_) => const HomeView());
      case profileRoute:
        return MaterialPageRoute(builder: (_) => const ProfileView());
      case settingsRoute:
        return MaterialPageRoute(builder: (_) => const SettingsView());
      case onboardingRoute:
        return MaterialPageRoute(builder: (_) => const OnboardingView());
      default:
        debugPrint('Unknown route: ${settings.name}');
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('Route not found: ${settings.name}'),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      navigatorKey.currentState?.pushNamedAndRemoveUntil(
                        loginRoute,
                        (route) => false,
                      );
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            ),
          ),
        );
    }
  }

  static Future<void> goToRouteAndClearStack(String route) async {
    await navigatorKey.currentState?.pushNamedAndRemoveUntil(
      route,
      (r) => false,
    );
  }

  static Future<void> goToLogin() async {
    await goToRouteAndClearStack(loginRoute);
  }

  static Future<void> goToDashboard() async {
    await goToRouteAndClearStack(dashboardRoute);
  }
}
