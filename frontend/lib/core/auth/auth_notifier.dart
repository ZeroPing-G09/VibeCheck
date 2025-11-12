import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthNotifier extends ChangeNotifier {
  AuthNotifier() {
    _sub = Supabase.instance.client.auth.onAuthStateChange.listen((event) {
      // Any sign-in / sign-out / token-refresh will trigger a router refresh.
      notifyListeners();
    });
  }

  StreamSubscription<AuthState>? _sub;

  bool get isLoggedIn =>
      Supabase.instance.client.auth.currentSession != null;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}
