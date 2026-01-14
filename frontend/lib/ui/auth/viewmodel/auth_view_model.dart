import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

/// ViewModel managing authentication state and commands
/// Handles login, logout, and Spotify sign-in flows
class AuthViewModel extends ChangeNotifier {

  /// Creates an [AuthViewModel] with the provided [_authRepository]
  /// Listens to auth state changes to update [_user] and error state
  AuthViewModel(this._authRepository) {
    _authRepository.onAuthStateChange.listen((_) async {
      final supabaseUser = _authRepository.currentUser;

      if (supabaseUser?.email != null) {
        try {
          _user = await _authRepository.userService.fetchUserByEmail(
            supabaseUser!.email!);
          _error = null;
          notifyListeners();

          _loginCompleter?.complete();
          _loginCompleter = null;
        } catch (e) {
          _error = 'Failed to fetch user data';
          notifyListeners();
          _loginCompleter?.complete();
          _loginCompleter = null;
        }
      } else {
        _user = null;
        notifyListeners();

        _loginCompleter?.complete();
        _loginCompleter = null;
      }
    });
  }
  final AuthRepository _authRepository;

  bool _isLoading = false;
  String? _error;
  User? _user;

  /// Indicates if a login or sign-in process is ongoing
  bool get isLoading => _isLoading;

  /// Stores the last error message from authentication actions
  String? get error => _error;

  /// The currently authenticated user, if any
  User? get user => _user;

  Completer<void>? _loginCompleter;

  /// Performs login with [email] and [password]
  /// Updates [isLoading], [user], and [error] states
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

  /// Initiates Spotify login flow
  /// Prevents multiple concurrent sign-ins
  /// Waits for auth state confirmation before completing
  Future<void> signInWithSpotify() async {
    if (_isLoading) {
      return;
    }
    _isLoading = true;
    _error = null;
    notifyListeners();

    _loginCompleter = Completer<void>();

    try {
      await _authRepository.signInWithSpotify();
      await _loginCompleter!.future;
    } catch (e) {
      _error = 'Login failed. Please try again';
    } finally {
      _isLoading = false;
      _loginCompleter = null;
      notifyListeners();
    }
  }

  /// Signs out the current user
  /// Resets [user] and [isLoading] states
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
