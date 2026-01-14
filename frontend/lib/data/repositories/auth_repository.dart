import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as supabase;

/// Repository handling authentication and user retrieval
/// Acts as a business layer orchestrating AuthService and UserService
class AuthRepository {

  /// Creates an [AuthRepository] with required services
  AuthRepository({
    required AuthService authService,
    required UserService userService,
  })  : _authService = authService,
        _userService = userService;
  final AuthService _authService;
  final UserService _userService;

  /// Performs email/password login
  /// Returns the [User] if found in backend, otherwise null
  Future<User?> login(String email, String password) async {
    await _authService.signInWithPassword(email, password);

    final supabaseUser = _authService.currentUser;
    if (supabaseUser?.email != null) {
      try {
        return await _userService.fetchUserByEmail(supabaseUser!.email!);
      } catch (e) {
        return null;
      }
    }
    return null;
  }

  /// Initiates login with Spotify
  Future<void> signInWithSpotify() async {
    await _authService.signInWithSpotify();
  }

  /// Signs out the current user
  Future<void> signOut() async {
    await _authService.signOut();
  }

  /// Returns the currently authenticated Supabase user, nullable
  supabase.User? get currentUser => _authService.currentUser;

  /// Access to [UserService] for user-related operations
  UserService get userService => _userService;

  /// Stream emitting authentication state changes
  Stream<supabase.AuthState> get onAuthStateChange =>
      _authService.onAuthStateChange;
}
