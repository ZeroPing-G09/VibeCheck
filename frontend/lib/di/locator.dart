import 'package:get_it/get_it.dart';
import 'package:frontend/core/auth/auth_notifier.dart';
import 'package:frontend/data/repositories/auth_repository.dart';

final locator = GetIt.instance;

void setupLocator() {
  if (!locator.isRegistered<AuthRepository>()) {
    locator.registerLazySingleton<AuthRepository>(() => AuthRepository());
  }

  if (!locator.isRegistered<AuthNotifier>()) {
    locator.registerLazySingleton<AuthNotifier>(() => AuthNotifier());
  }
}