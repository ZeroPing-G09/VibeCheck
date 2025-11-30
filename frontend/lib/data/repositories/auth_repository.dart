import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

class AuthRepository {
  final AuthService _authService;
  final UserService _userService;

  AuthRepository({
    required AuthService authService,
    required UserService userService,
  }) : _authService = authService,
       _userService = userService;

  // Business layer: Orchestrates authentication flow
  Future<User?> login(String email, String password) async {
    // Call service (data layer) for authentication
    await _authService.signInWithPassword(email, password);

    final supabaseUser = _authService.currentUser;
    if (supabaseUser?.email != null) {
      try {
        return await _userService.fetchUserByEmail(supabaseUser!.email!);
      } catch (e) {
        // If user doesn't exist in backend, return null
        return null;
      }
    }
    return null;
  }

  Future<void> signInWithSpotify() async {
    // Call service (data layer) for authentication
    await _authService.signInWithSpotify();
  }

  Future<void> signOut() async {
    // Call service (data layer) for sign out
    await _authService.signOut();
  }

  supabase.User? get currentUser => _authService.currentUser;

  Stream<supabase.AuthState> get onAuthStateChange =>
      _authService.onAuthStateChange;
}
