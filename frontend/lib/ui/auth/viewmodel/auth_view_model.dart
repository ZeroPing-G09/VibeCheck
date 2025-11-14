import 'package:flutter/foundation.dart';
import '../../../data/models/user.dart';
import '../../../data/services/auth_service.dart';
import '../../../di/locator.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthService _authService = locator<AuthService>();

  bool _isLoading = false;
  User? _user;

  bool get isLoading => _isLoading;
  User? get user => _user;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    _user = await _authService.login(email, password);

    _isLoading = false;
    notifyListeners();
  }
}
