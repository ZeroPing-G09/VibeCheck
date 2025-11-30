import 'dart:convert';

import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UserRepository {
  final UserService _service = UserService();

  Future<User> getUserById(int id) async {
    final user = await _service.fetchUserById(id);
    await _saveGenres(user.genres);
    return user;
  }

  Future<User> getUserByEmail(String email) async {
    final user = await _service.fetchUserByEmail(email);
    await _saveGenres(user.genres);
    return user;
  }

  Future<User> updateUser(User updatedUser) async {
    final user = await _service.updateUser(updatedUser);
    await _saveGenres(user.genres);
    return user;
  }

  Future<void> _saveGenres(List<String> genres) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('genres', jsonEncode(genres));
  }

  Future<List<String>> getSavedGenres() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('genres');
    if (stored != null) {
      return List<String>.from(jsonDecode(stored) as Iterable<dynamic>);
    }
    return [];
  }
}
