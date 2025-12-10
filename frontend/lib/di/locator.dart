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
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/ui/auth/viewmodel/auth_view_model.dart';
import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/mood/viewmodel/mood_view_model.dart';
import 'package:frontend/ui/onboarding/viewmodel/onboarding_view_model.dart';
import 'package:frontend/ui/profile/viewmodel/profile_view_model.dart';
import 'package:frontend/ui/settings/viewmodel/theme_view_model.dart';
import 'package:get_it/get_it.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Register services (data layer) first
  locator
    ..registerLazySingleton(ApiService.new)
    ..registerLazySingleton(AuthService.new)
    ..registerLazySingleton(UserService.new)
    ..registerLazySingleton(MoodService.new)
    ..registerLazySingleton(GenreService.new)
    ..registerLazySingleton(OnboardingService.new)
    // Register repositories (business layer) that depend on services
    ..registerLazySingleton(
      () => AuthRepository(
        authService: locator<AuthService>(),
        userService: locator<UserService>(),
      ),
    )
    ..registerLazySingleton(
      () => UserRepository(userService: locator<UserService>()),
    )
    ..registerLazySingleton(
      () => MoodRepository(moodService: locator<MoodService>()),
    )
    ..registerLazySingleton(
      () => GenreRepository(genreService: locator<GenreService>()),
    )
    ..registerLazySingleton(
      () => OnboardingRepository(
        onboardingService: locator<OnboardingService>(),
        userRepository: locator<UserRepository>(),
        genreRepository: locator<GenreRepository>(),
      ),
    )
    // Register ViewModels (UI layer) that depend on repositories
    ..registerFactory(
      () => DashboardViewModel(
        locator<UserRepository>(),
        locator<AuthRepository>(),
      ),
    )
    ..registerFactory(
      () => MoodViewModel(
        locator<MoodRepository>(),
        locator<AuthRepository>(),
        locator<UserRepository>(),
      ),
    )
    ..registerFactory(
      () => OnboardingViewModel(
        locator<OnboardingRepository>(),
        locator<AuthRepository>(),
      ),
    )
    ..registerFactory(
      () => ProfileViewModel(
        locator<UserRepository>(),
        locator<GenreRepository>(),
        locator<AuthRepository>(),
      ),
    )
    ..registerFactory(() => AuthViewModel(locator<AuthRepository>()))
    ..registerFactory(ThemeViewModel.new);
}
