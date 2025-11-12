import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import '../services/api_service.dart';
import 'package:flutter/foundation.dart';

class AuthRepository {
  AuthRepository._internal();
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;

  final supabase.SupabaseClient _client = ApiService.client;

  Future<void> signInWithSpotify() async {
    await _client.auth.signInWithOAuth(
      supabase.OAuthProvider.spotify,
      redirectTo: kIsWeb ? null : 'vibecheck://auth-callback',
      scopes: 'user-read-email user-read-private',
    );
  }

  Future<void> signOut() async {
    await _client.auth.signOut();
  }

  supabase.User? get currentUser => _client.auth.currentUser;

  Stream<supabase.AuthState> get onAuthStateChange =>
      _client.auth.onAuthStateChange;
}
