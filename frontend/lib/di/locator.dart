import 'package:get_it/get_it.dart';
import '../data/repositories/auth_repository.dart';
import '../data/repositories/user_repository.dart';
import '../data/repositories/mood_repository.dart';
import '../data/repositories/genre_repository.dart';
import '../data/repositories/onboarding_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/playlist_service.dart';
import '../data/services/user_service.dart';
import '../data/services/mood_service.dart';
import '../data/services/genre_service.dart';
import '../data/services/onboarding_service.dart';
import '../ui/dashboard/viewmodel/dashboard_view_model.dart';
import '../ui/mood/viewmodel/mood_view_model.dart';
import '../ui/onboarding/viewmodel/onboarding_view_model.dart';
import '../ui/profile/viewmodel/profile_view_model.dart';
import '../ui/auth/viewmodel/auth_view_model.dart';
import '../ui/settings/viewmodel/theme_view_model.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  // Register services (data layer) first
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(
    () => PlaylistService(authService: locator<AuthService>()),
  );
  locator.registerLazySingleton(() => MoodService());
  locator.registerLazySingleton(() => GenreService());
  locator.registerLazySingleton(() => OnboardingService());

  // Register repositories (business layer) that depend on services
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

  // Register ViewModels (UI layer) that depend on repositories
  locator.registerFactory(() => DashboardViewModel(
        userRepository: locator<UserRepository>(),
        authRepository: locator<AuthRepository>(),
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
      ));
  
  locator.registerFactory(() => AuthViewModel(
        locator<AuthRepository>(),
      ));
  
  locator.registerFactory(() => ThemeViewModel());
}
