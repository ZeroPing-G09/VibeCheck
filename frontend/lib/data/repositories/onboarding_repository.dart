import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/onboarding_service.dart';
import '../repositories/user_repository.dart';
import '../repositories/genre_repository.dart';

class OnboardingRepository {
  final OnboardingService _service;
  final UserRepository _userRepository;
  final GenreRepository _genreRepository;

  OnboardingRepository({
    OnboardingService? onboardingService,
    UserRepository? userRepository,
    GenreRepository? genreRepository,
  })  : _service = onboardingService ?? OnboardingService(),
        _userRepository = userRepository ?? UserRepository(),
        _genreRepository = genreRepository ?? GenreRepository();

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

  Future<User> getUserForOnboarding(String email) async {
    return await _userRepository.getUserByEmail(email);
  }

  Future<List<String>> getAvailableGenres() async {
    try {
      return await _genreRepository.getAllGenres();
    } catch (e) {
      return await _genreRepository.getCachedGenres();
    }
  }

  Future<User> completeOnboarding(User user, List<String> selectedGenres) async {
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

  Future<void> _markOnboardingComplete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_complete_$userId', true);
  }

  Future<bool> isOnboardingComplete(String userId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete_$userId') ?? false;
  }
}
