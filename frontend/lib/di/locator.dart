import 'package:get_it/get_it.dart';

import 'package:frontend/data/repositories/auth_repository.dart';
import 'package:frontend/data/repositories/user_repository.dart';
import 'package:frontend/data/repositories/mood_repository.dart';
import 'package:frontend/data/repositories/genre_repository.dart';
import 'package:frontend/data/repositories/onboarding_repository.dart';
import 'package:frontend/data/local/local_user_storage.dart';

import 'package:frontend/data/services/api_service.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:frontend/data/services/mood_service.dart';
import 'package:frontend/data/services/genre_service.dart';
import 'package:frontend/data/services/onboarding_service.dart';
import 'package:frontend/data/services/playlist_service.dart';

import 'package:frontend/ui/dashboard/viewmodel/dashboard_view_model.dart';
import 'package:frontend/ui/mood/viewmodel/mood_view_model.dart';
import 'package:frontend/ui/onboarding/viewmodel/onboarding_view_model.dart';
import 'package:frontend/ui/profile/viewmodel/profile_view_model.dart';
import 'package:frontend/ui/auth/viewmodel/auth_view_model.dart';
import 'package:frontend/ui/settings/viewmodel/theme_view_model.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Register services (data layer) first
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => UserService(locator<LocalUserStorage>()));
  locator.registerLazySingleton(
    () => PlaylistService(authService: locator<AuthService>()),
  );
  locator.registerLazySingleton(() => MoodService());
  locator.registerLazySingleton(() => GenreService());
  locator.registerLazySingleton(() => OnboardingService());

  // Register repositories (business layer)
  locator.registerLazySingleton(() => AuthRepository(
        authService: locator<AuthService>(),
        userService: locator<UserService>(),
      ));

  locator.registerLazySingleton(() => UserRepository(
        userService: locator<UserService>(),
      ));

  locator.registerLazySingleton(() => MoodRepository(
        moodService: locator<MoodService>(),
      ));

  locator.registerLazySingleton(() => GenreRepository(
        genreService: locator<GenreService>(),
      ));

  locator.registerLazySingleton(() => OnboardingRepository(
        onboardingService: locator<OnboardingService>(),
        userRepository: locator<UserRepository>(),
        genreRepository: locator<GenreRepository>(),
      ));
  locator.registerLazySingleton(() => LocalUserStorage());

  // Register ViewModels (UI layer)
  locator.registerFactory(() => DashboardViewModel(
        userRepository: locator<UserRepository>(),
        authRepository: locator<AuthRepository>(),
        moodRepository: locator<MoodRepository>(),
      ));

  locator.registerFactory(() => MoodViewModel(
        locator<MoodRepository>(),
        locator<AuthRepository>(),
        locator<UserRepository>(),
      ));

  locator.registerFactory(() => OnboardingViewModel(
        locator<OnboardingRepository>(),
        locator<AuthRepository>(),
      ));

  locator.registerFactory(() => ProfileViewModel(
        locator<UserRepository>(),
        locator<GenreRepository>(),
        locator<AuthRepository>(),
        locator<LocalUserStorage>()
      ));

  locator.registerFactory(() => AuthViewModel(
        locator<AuthRepository>(),
      ));

  locator.registerFactory(() => ThemeViewModel());

}
