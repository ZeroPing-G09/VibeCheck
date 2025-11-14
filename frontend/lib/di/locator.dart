import 'package:get_it/get_it.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/api_service.dart';
import '../data/services/auth_service.dart';
import '../data/services/user_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => AuthRepository());
  locator.registerLazySingleton(() => UserService());
  locator.registerLazySingleton(() => AuthService(
        authRepository: locator<AuthRepository>(),
        userService: locator<UserService>(),
      ));
}
