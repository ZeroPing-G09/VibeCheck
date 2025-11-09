import 'package:flutter/material.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/user_repository.dart';

class DashboardViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  User? _user;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadUser(int id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userRepository.getUserById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
