import 'dart:async';

import 'package:flutter/material.dart';
import 'package:frontend/core/routing/app_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Widget that handles OAuth callback routes and completes authentication flow
class OAuthCallbackHandler extends StatefulWidget {

  /// Creates an OAuth callback handler
  const OAuthCallbackHandler({required this.callbackRoute, super.key});
  /// Raw callback route containing auth parameters
  /// Example: "/?code=..." or "/?access_token=..."
  final String callbackRoute;

  @override
  State<OAuthCallbackHandler> createState() => _OAuthCallbackHandlerState();
}

/// State class for [OAuthCallbackHandler]
class _OAuthCallbackHandlerState extends State<OAuthCallbackHandler> {
  /// Subscription to Supabase auth state changes
  StreamSubscription<AuthState>? _sub;

  /// Whether navigation has already been handled
  bool _handled = false;

  /// Timeout fallback in case auth does not complete
  Timer? _timeout;

  @override
  void initState() {
    super.initState();

    /// Listen to auth changes and navigate when session becomes available
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      final session =
          event.session ?? Supabase.instance.client.auth.currentSession;
      if (!_handled && session != null) {
        _handled = true;
        _navigateToPostAuth();
      }
    });

    /// Fallback navigation to login after a short timeout
    _timeout = Timer(const Duration(seconds: 10), () {
      if (!_handled) {
        _handled = true;
        _goToLogin();
      }
    });
  }

  /// Navigates to the dashboard after successful authentication
  void _navigateToPostAuth() {
    AppRouter.goToDashboard();
  }

  /// Navigates to the login screen when authentication fails or times out
  void _goToLogin() {
    AppRouter.goToLogin();
  }

  @override
  void dispose() {
    _sub?.cancel();
    _timeout?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Completing authentication...'),
          ],
        ),
      ),
    );
  }
}
