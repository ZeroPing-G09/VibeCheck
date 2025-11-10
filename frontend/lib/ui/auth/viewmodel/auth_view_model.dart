import 'package:frontend/data/repositories/auth_repository.dart';

class AuthViewModel {
  final AuthRepository _repo = AuthRepository();

  Future<void> loginWithSpotify() => _repo.signInWithSpotify();
  Future<void> logout() => _repo.signOut();
  Stream get onAuthStateChange => _repo.onAuthStateChange;
}
