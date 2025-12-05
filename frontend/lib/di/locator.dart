import 'package:get_it/get_it.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/playlist_service.dart';
import '../data/services/user_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerLazySingleton(() => ApiService());
  // Register services (data layer) first
  locator.registerLazySingleton(() => AuthService());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(
    () => PlaylistService(authService: locator<AuthService>()),
  );
  // Register repositories (business layer) that depend on services
  locator.registerLazySingleton(() => AuthRepository(
        authService: locator<AuthService>(),
        userService: locator<UserService>(),
      ));
}
