import 'package:supabase_flutter/supabase_flutter.dart';
import '../models/user.dart';
import '../services/api_service.dart';

class AuthRepository {
  final SupabaseClient _client = ApiService.client;

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
