import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;
  User? get user => _user;

  Completer<void>? _loginCompleter;

  AuthViewModel(this._authRepository) {
    // Listen to auth state changes
    _authRepository.onAuthStateChange.listen((_) async {
      final supabaseUser = _authRepository.currentUser;

      if (supabaseUser?.email != null) {
        try {
          _user = await _authRepository.userService.fetchUserByEmail(supabaseUser!.email!);
          _error = null;
          notifyListeners();

          // Complete login completer if exists
          _loginCompleter?.complete();
          _loginCompleter = null;
        } catch (e) {
          _error = 'Failed to fetch user data.';
          notifyListeners();
          _loginCompleter?.complete();
          _loginCompleter = null;
        }
      } else {
        // Logged out
        _user = null;
        notifyListeners();

        // Complete login completer if any
        _loginCompleter?.complete();
        _loginCompleter = null;
      }
    });
  }

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
    if (_isLoading) return; // prevent double taps
    _isLoading = true;
    _error = null;
    notifyListeners();

    _loginCompleter = Completer<void>();

    try {
      await _authRepository.signInWithSpotify();

      // Wait until auth state confirms the user
      await _loginCompleter!.future;
    } catch (e) {
      _error = 'Login failed. Please try again.';
    } finally {
      _isLoading = false;
      _loginCompleter = null;
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
