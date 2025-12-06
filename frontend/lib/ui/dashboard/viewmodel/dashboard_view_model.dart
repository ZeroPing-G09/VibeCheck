import 'package:flutter/material.dart';
import '../../../data/models/user.dart';
import '../../../../data/repositories/user_repository.dart';
import '../../../../data/repositories/auth_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final AuthRepository _authRepository;

  DashboardViewModel(
    this._userRepository,
    this._authRepository,
  );

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Gets the current authenticated user's email
  String? get currentUserEmail => _authRepository.currentUser?.email;

  /// Gets the display name with fallback logic
  String getDisplayName() {
    if (_user != null && _user!.displayName.isNotEmpty) {
      return _user!.displayName;
    }

    final supabaseUser = _authRepository.currentUser;
    if (supabaseUser != null) {
      final fullName = supabaseUser.userMetadata?['full_name'];
      if (fullName is String && fullName.isNotEmpty) {
        return fullName;
      }

      final email = supabaseUser.email;
      if (email != null && email.contains('@')) {
        return email.split('@')[0];
      }
    }

    return 'User';
  }

  /// Gets the avatar URL with fallback logic
  String getAvatarUrl() {
    if (_user != null && _user!.avatarUrl.isNotEmpty) {
      return _user!.avatarUrl;
    }

    final supabaseUser = _authRepository.currentUser;
    if (supabaseUser != null) {
      final avatarUrl = supabaseUser.userMetadata?['avatar_url'];
      if (avatarUrl is String && avatarUrl.isNotEmpty) {
        return avatarUrl;
      }
    }

    return '';
  }

  /// Command: Load user by email
  Future<void> loadUserByEmail(String email) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userRepository.getUserByEmail(email);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Command: Handle user action (profile, settings, logout)
  Future<void> handleUserAction(String action) async {
    switch (action) {
      case 'profile':
        // Navigation is handled by the view/router
        break;
      case 'settings':
        // Navigation is handled by the view/router
        break;
      case 'logout':
        await _authRepository.signOut();
        clear();
        break;
    }
    notifyListeners();
  }

  void clear() {
    _user = null;
    _error = null;
    notifyListeners();
  }
}
