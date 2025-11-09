import 'package:flutter/foundation.dart';
import '../../../data/models/user.dart';
import '../../../data/repositories/auth_repository.dart';
import '../../../di/locator.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository = locator<AuthRepository>();

  bool _isLoading = false;
  UserModel? _user;

  bool get isLoading => _isLoading;
  UserModel? get user => _user;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    _user = await _authRepository.login(email, password);

    _isLoading = false;
    notifyListeners();
  }
}
