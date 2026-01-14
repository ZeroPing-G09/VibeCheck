import 'package:frontend/data/services/api_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service handling user authentication via Supabase
/// Provides password, OAuth login, logout, and token management
class AuthService {
  final SupabaseClient _client = ApiService.client;

  /// Signs in a user with [email] and [password]
  /// Throws SupabaseAuthException if authentication fails
  Future<void> signInWithPassword(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  /// Signs in a user with Spotify OAuth
  /// Redirects to the app at 'vibecheck://auth-callback'
  /// Requests scopes for email, private info, and playlist modification
  Future<void> signInWithSpotify() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.spotify,
      redirectTo: 'vibecheck://auth-callback',
      scopes: 'user-read-email user-read-private '
      'playlist-modify-public playlist-modify-private',
    );
  }

  /// Signs out the currently authenticated user
  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  /// Returns the currently authenticated [User] if available, otherwise null
  User? get currentUser => _client.auth.currentUser;

  /// Stream emitting [AuthState] changes when authentication state changes
  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;

  /// Retrieves the current access token for API requests
  /// Returns null if no user is signed in
  Future<String?> getAccessToken() async {
    final session = _client.auth.currentSession;
    return session?.accessToken;
  }
}
