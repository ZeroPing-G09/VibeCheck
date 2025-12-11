import 'package:flutter/material.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/onboarding_repository.dart';

class OnboardingViewModel extends ChangeNotifier {
  final OnboardingRepository _onboardingRepository;
  final AuthRepository _authRepository;

  OnboardingViewModel(this._onboardingRepository, this._authRepository);

  List<String> _availableGenres = [];
  final List<String> _selectedGenres = [];
  bool _isLoading = false;
  bool _isSaving = false;
  String? _error;
  User? _user;

  List<String> get availableGenres => _availableGenres;
  List<String> get selectedGenres => _selectedGenres;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;
  String? get error => _error;
  User? get user => _user;
  bool get canComplete => _selectedGenres.length == 3;

  /// Command: Load genres
  Future<void> loadGenres() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _availableGenres = await _onboardingRepository.getAvailableGenres();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gets the current authenticated user's email
  String? get currentUserEmail => _authRepository.currentUser?.email;

  /// Command: Load user for onboarding (uses current user email)
  Future<void> loadUser([String? email]) async {
    final userEmail = email ?? currentUserEmail;
    if (userEmail == null) {
      _error = 'No authenticated user found';
      notifyListeners();
      return;
    }

    try {
      _user = await _onboardingRepository.getUserForOnboarding(userEmail);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Command: Toggle genre selection
  void toggleGenre(String genre) {
    if (_selectedGenres.contains(genre)) {
      _selectedGenres.remove(genre);
    } else {
      if (_selectedGenres.length < 3) {
        _selectedGenres.add(genre);
      }
    }
    notifyListeners();
  }

  /// Command: Complete onboarding
  Future<void> completeOnboarding() async {
    if (!canComplete || _user == null) return;

    _isSaving = true;
    _error = null;
    notifyListeners();

    try {
      await _onboardingRepository.completeOnboarding(_user!, _selectedGenres);
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      rethrow;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }

  void clear() {
    _selectedGenres.clear();
    _error = null;
    notifyListeners();
  }
}
