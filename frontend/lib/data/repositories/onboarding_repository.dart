import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/repositories/genre_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/services/onboarding_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository handling onboarding flow
/// Orchestrates [OnboardingService], [UserRepository], [GenreRepository] 
/// and local caching
class OnboardingRepository {

  /// Creates an instance of [OnboardingRepository] with optional service, 
  /// user, and genre repositories
  OnboardingRepository({
    OnboardingService? onboardingService,
    UserRepository? userRepository,
    GenreRepository? genreRepository,
  })  : _service = onboardingService ?? OnboardingService(),
        _userRepository = userRepository ?? UserRepository(),
        _genreRepository = genreRepository ?? GenreRepository();

  final OnboardingService _service;
  final UserRepository _userRepository;
  final GenreRepository _genreRepository;

  /// Determines if the user with [email] still needs onboarding
  /// Falls back to checking user's genres if service call fails
  /// Returns true if onboarding is required, false otherwise
  Future<bool> needsOnboarding(String email) async {
    try {
      return await _service.checkOnboardingNeeded(email);
    } catch (e) {
      try {
        final user = await _userRepository.getUserByEmail(email);
        return user.genres.isEmpty || user.genres.length < 3;
      } catch (_) {
        return true;
      }
    }
  }

  /// Retrieves user information for onboarding by [email]
  /// Returns a [User] object
  Future<User> getUserForOnboarding(String email) async {
    return _userRepository.getUserByEmail(email);
  }

  /// Returns list of available genres
  /// Falls back to cached genres if fetching fails
  /// Returns a list of genre names as [List<String>]
  Future<List<String>> getAvailableGenres() async {
    try {
      return await _genreRepository.getAllGenres();
    } catch (e) {
      return _genreRepository.getCachedGenres();
    }
  }

  /// Completes onboarding for [user] with exactly 3 [selectedGenres]
  /// Updates user via service or repository and marks onboarding 
  /// complete locally
  /// Throws exception if selectedGenres length is not exactly 3
  /// Returns updated [User] object
  Future<User> completeOnboarding(User user, List<String> selectedGenres) 
  async {
    if (selectedGenres.length != 3) {
      throw Exception('Exactly 3 genres must be selected');
    }

    try {
      await _service.completeOnboarding(user.id, selectedGenres);
      final updatedUser = await _userRepository.getUserByEmail(user.email);
      await _markOnboardingComplete(user.id);
      return updatedUser;
    } catch (e) {
      final updatedUser = user.copyWith(genres: selectedGenres);
      final savedUser = await _userRepository.updateUser(updatedUser);
      await _markOnboardingComplete(user.id);
      return savedUser;
    }
  }

  /// Marks onboarding as complete locally for user with [userId]
  Future<void> _markOnboardingComplete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete_$userId', true);
  }

  /// Checks if onboarding has been completed for user with [userId]
  /// Returns true if onboarding is complete, false otherwise
  Future<bool> isOnboardingComplete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete_$userId') ?? false;
  }
}
