import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/genre_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository;
  final GenreRepository _genreRepository;
  final AuthRepository _authRepository;

  ProfileViewModel(
    this._userRepository,
    this._genreRepository,
    this._authRepository,
  );

  User? user;
  bool isLoading = false;
  List<String> availableGenres = [];

  /// Gets the current authenticated user's email
  String? get currentUserEmail => _authRepository.currentUser?.email;

  /// Command: Load user by email
  Future<void> loadUserByEmail(String email) async {
    isLoading = true;
    notifyListeners();
    try {
      final fetched = await _userRepository.getUserByEmail(email);
      final dedupedGenres = fetched.genres.toSet().toList();
      user = fetched.copyWith(genres: dedupedGenres);
    } catch (e, st) {
      debugPrint('ProfileViewModel.loadUserByEmail error: $e');
      debugPrint('$st');
      user = null;
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
