import 'package:supabase_flutter/supabase_flutter.dart' as supabase;
import '../models/user.dart';
import '../repositories/auth_repository.dart';
import 'user_service.dart';

class AuthService {
  final AuthRepository _authRepository;
  final UserService _userService;

  AuthService({
    required AuthRepository authRepository,
    required UserService userService,
  })  : _authRepository = authRepository,
        _userService = userService;

  Future<User?> login(String email, String password) async {
    await _authRepository.login(email, password);
    
    final supabaseUser = _authRepository.currentUser;
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
    await _authRepository.signInWithSpotify();
  }

  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  supabase.User? get currentUser => _authRepository.currentUser;

  Stream<supabase.AuthState> get onAuthStateChange => _authRepository.onAuthStateChange;
}

