import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import '../../../data/repositories/genre_repository.dart';


class ProfileViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();
  final GenreRepository _genreRepository = GenreRepository();

  User? user;
  bool isLoading = false;
  List<String> availableGenres = [];

  Future<void> loadUser(int id) async {
    isLoading = true;
    notifyListeners();
    try {
      final fetched = await _userRepository.getUserById(id);
      final dedupedGenres = fetched.genres.toSet().toList();
      user = fetched.copyWith(genres: dedupedGenres);
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }

  Future<void> loadAvailableGenres() async {
    try {
      availableGenres = await _genreRepository.getAllGenres();
    } catch (e) {
      availableGenres = await _genreRepository.getCachedGenres();
    }
    notifyListeners();
  }

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
  
  void clear() {
    user = null;
    isLoading = false;
    availableGenres = [];
    notifyListeners();
  }
}
