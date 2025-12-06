import 'package:flutter/foundation.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel(this._authRepository);

  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _authRepository.login(email, password);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Command: Sign in with Spotify
  Future<void> signInWithSpotify() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authRepository.signInWithSpotify();
    } catch (e) {
      _error = 'Login failed. Please try again.';
      notifyListeners();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Command: Sign out
  Future<void> signOut() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authRepository.signOut();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
