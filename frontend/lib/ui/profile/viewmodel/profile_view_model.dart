import 'package:flutter/material.dart';
import '../../../../data/models/user.dart';
import '../../../../data/repositories/user_repository.dart';

class ProfileViewModel extends ChangeNotifier {
  final UserRepository _repository = UserRepository();

  User? _user;
  bool _isLoading = false;
  bool _isSaving = false;

  User? get user => _user;
  bool get isLoading => _isLoading;
  bool get isSaving => _isSaving;

  Future<void> loadUser(int id) async {
    _isLoading = true;
    notifyListeners();
    try {
      _user = await _repository.getUserById(id);
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(User updatedUser) async {
    _isSaving = true;
    notifyListeners();
    try {
      await _repository.updateUser(updatedUser);
      _user = updatedUser;
    } finally {
      _isSaving = false;
      notifyListeners();
    }
  }
}
