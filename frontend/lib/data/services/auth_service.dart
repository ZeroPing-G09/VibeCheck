import 'package:supabase_flutter/supabase_flutter.dart';
import 'api_service.dart';

class AuthService {
  final SupabaseClient _client = ApiService.client;

  // Data layer: Direct Supabase operations
  Future<void> signInWithPassword(String email, String password) async {
    await _client.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }

  Future<void> signInWithSpotify() async {
    await _client.auth.signInWithOAuth(
      OAuthProvider.spotify,
      redirectTo: 'vibecheck://auth-callback',
      scopes: 'user-read-email user-read-private',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  User? get currentUser => _client.auth.currentUser;

  Stream<AuthState> get onAuthStateChange => _client.auth.onAuthStateChange;
}

