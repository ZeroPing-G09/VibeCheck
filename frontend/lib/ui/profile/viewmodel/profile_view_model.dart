import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/genre_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/local/local_user_storage.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final GenreRepository _genreRepository;
  final AuthRepository _authRepository;
  final LocalUserStorage _localStorage;

  ProfileViewModel(
    this._userRepository,
    this._genreRepository,
    this._authRepository,
    this._localStorage
  );

  User? user;
  bool isLoading = false;
  List<String> availableGenres = [];

  bool _isServerAvailable = true;
  bool get isServerAvailable => _isServerAvailable;

  /// Gets the current authenticated user's email
  String? get currentUserEmail => _authRepository.currentUser?.email;

  /// Command: Load user by email
  Future<void> loadUserByEmail(String email) async {
    // Show cached user immediately
    final cachedUser = await _localStorage.getUser();
    if (cachedUser != null) {
      user = cachedUser;
      _isServerAvailable = false;
      notifyListeners();
    }

    isLoading = true;
    notifyListeners();

    try {
      final fetched = await _userRepository
          .getUserByEmail(email)
          .timeout(const Duration(seconds: 5));

      user = fetched.copyWith(
        genres: fetched.genres.toSet().toList(),
      );

      _isServerAvailable = true;
      await _localStorage.saveUser(user!);
    } catch (_) {
      // Server unreachable
      _isServerAvailable = false;
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }


  /// Command: Load available genres
  Future<void> loadAvailableGenres() async {
    try {
      availableGenres = await _genreRepository.getAllGenres();
    } catch (e) {
      availableGenres = await _genreRepository.getCachedGenres();
    }
    notifyListeners();
  }

  /// Command: Update user
  Future<void> updateUser(User updatedUser) async {
    debugPrint('ProfileViewModel.updateUser called for id=${updatedUser.id}');
    if (!_isServerAvailable) {
      throw Exception('Server offline');
    }

    try {
      user = await _userRepository.updateUser(updatedUser);
      notifyListeners();
    } catch (e, st) {
      debugPrint('ProfileViewModel.updateUser error: $e');
      debugPrint('$st');
      rethrow;
    }
  }

  /// Command: Sign out user
  Future<void> signOut() async {
    await _authRepository.signOut();
  }

  void clear() {
    user = null;
    isLoading = false;
    availableGenres = [];
    notifyListeners();
  }
}
