import 'dart:convert';

import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/user_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Repository handling user-related operations
/// Orchestrates [UserService] and local caching of user genres
class UserRepository {

  /// Creates a [UserRepository] with optional [UserService]
  UserRepository({UserService? userService})
      : _service = userService ?? UserService();
  final UserService _service;

  /// Fetches user by [id] from the service
  /// Saves user's genres locally
  /// Returns a [User] object
  Future<User> getUserById(int id) async {
    final user = await _service.fetchUserById(id);
    await _saveGenres(user.genres);
    return user;
  }

  /// Fetches user by [email] from the service
  /// Saves user's genres locally
  /// Returns a [User] object
  Future<User> getUserByEmail(String email) async {
    final user = await _service.fetchUserByEmail(email);
    await _saveGenres(user!.genres);
    return user;
  }

  /// Updates the [updatedUser] via service
  /// Saves user's updated genres locally
  /// Returns the updated [User] object
  Future<User> updateUser(User updatedUser) async {
    final user = await _service.updateUser(updatedUser);
    await _saveGenres(user.genres);
    return user;
  }

  /// Saves [genres] locally in SharedPreferences
  Future<void> _saveGenres(List<String> genres) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('genres', jsonEncode(genres));
  }

  /// Retrieves locally saved genres from SharedPreferences
  /// Returns a list of genre names as [List<String>]
  Future<List<String>> getSavedGenres() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString('genres');
    if (stored != null) {
      return List<String>.from(jsonDecode(stored) as Iterable<dynamic>);
    }
    return [];
  }
}
