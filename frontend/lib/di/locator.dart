import 'package:frontend/data/local/local_user_storage.dart';
import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/genre_repository.dart';
import 'package:frontend/data/repositories/mood_repository.dart';
import 'package:frontend/data/repositories/onboarding_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:frontend/data/services/genre_service.dart';
import 'package:frontend/data/services/mood_service.dart';
import 'package:frontend/data/services/onboarding_service.dart';
import 'package:frontend/data/services/playlist_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/ui/auth/viewmodel/auth_view_model.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/mood/viewmodel/mood_view_model.dart';
import 'package:frontend/ui/onboarding/viewmodel/onboarding_view_model.dart';
import 'package:frontend/ui/profile/viewmodel/profile_view_model.dart';
import 'package:frontend/ui/settings/viewmodel/theme_view_model.dart';
import 'package:get_it/get_it.dart';

/// Centralized dependency injection setup using GetIt
/// Registers services, repositories, and ViewModels
final locator = GetIt.instance;

/// Sets up all dependencies for the application
/// Services are registered first, followed by repositories, then ViewModels
Future<void> setupLocator() async {
  // Register services (data layer)
  locator
    ..registerLazySingleton(ApiService.new)
    ..registerLazySingleton(AuthService.new)
    ..registerLazySingleton(UserService.new)
    ..registerLazySingleton(() => PlaylistService(
      authService: locator<AuthService>()))
    ..registerLazySingleton(MoodService.new)
    ..registerLazySingleton(GenreService.new)
    ..registerLazySingleton(OnboardingService.new)

    // Register repositories (business layer)
    ..registerLazySingleton(() => AuthRepository(
          authService: locator<AuthService>(),
          userService: locator<UserService>(),
        ))
    ..registerLazySingleton(() => UserRepository(
          userService: locator<UserService>(),
        ))
    ..registerLazySingleton(() => MoodRepository(
          moodService: locator<MoodService>(),
        ))
    ..registerLazySingleton(() => GenreRepository(
          genreService: locator<GenreService>(),
        ))
    ..registerLazySingleton(() => OnboardingRepository(
          onboardingService: locator<OnboardingService>(),
          userRepository: locator<UserRepository>(),
          genreRepository: locator<GenreRepository>(),
        ))
    ..registerLazySingleton(LocalUserStorage.new)

    // Register ViewModels (UI layer)
    ..registerFactory(() => DashboardViewModel(
          userRepository: locator<UserRepository>(),
          authRepository: locator<AuthRepository>(),
          moodRepository: locator<MoodRepository>(),
        ))
    ..registerFactory(() => MoodViewModel(
          locator<MoodRepository>(),
          locator<AuthRepository>(),
          locator<UserRepository>(),
        ))
    ..registerFactory(() => OnboardingViewModel(
          locator<OnboardingRepository>(),
          locator<AuthRepository>(),
        ))
    ..registerFactory(() => ProfileViewModel(
          locator<UserRepository>(),
          locator<GenreRepository>(),
          locator<AuthRepository>(),
          locator<LocalUserStorage>(),
        ))
    ..registerFactory(() => AuthViewModel(
          locator<AuthRepository>(),
        ))
    ..registerFactory(ThemeViewModel.new);
}
