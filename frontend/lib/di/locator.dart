import 'package:get_it/get_it.dart';
import '../data/repositories/auth_repository.dart';
import '../data/services/api_service.dart';

final locator = GetIt.instance;

Future<void> setupLocator() async {
  locator.registerLazySingleton(() => ApiService());
  locator.registerLazySingleton(() => AuthRepository(locator<ApiService>()));
}
