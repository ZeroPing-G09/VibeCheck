import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:frontend/data/local/local_user_storage.dart';
import 'package:frontend/data/models/user.dart';
import 'package:frontend/data/services/api_service.dart';
import 'package:http/http.dart' as http;

/// Service handling user-related API operations
/// Provides methods to fetch users by ID or email, and update user data
class UserService {

  /// Creates a [UserService]
  UserService();

  /// Fetches a user by their [id] from the backend
  /// Returns a [User] object
  /// Throws an exception if the API request fails
  Future<User> fetchUserById(int id) async {
    final url = ApiService.buildBackendUrl('/users/$id');
    debugPrint('UserService.fetchUserById GET $url');
    final response = await http.get(
      url,
      headers: ApiService.getAuthHeaders(),
    );

    debugPrint('fetchUserById status: ${response.statusCode}');
    debugPrint('fetchUserById body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      json['id'] = json['id'] ?? id;
      return User.fromJson(json);
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  /// Fetches a user by their [email] from cache or backend
  /// Optional [localStorage] can be provided for cache usage
  /// Returns a [User] object if found, otherwise null
  /// Throws an exception if the API request fails
  Future<User?> fetchUserByEmail(String email, {LocalUserStorage? localStorage})
  async {
    if (localStorage != null) {
      final cachedUser = await localStorage.getUser();
      if (cachedUser != null) {
        debugPrint('UserService: returning cached user');
        return cachedUser;
      }
    }

    final url = ApiService.buildBackendUrl('/users/by-email?email=${Uri.encodeQueryComponent(email)}');
    debugPrint('UserService.fetchUserByEmail GET $url');

    final response = await http.get(
      url,
      headers: ApiService.getAuthHeaders(),
    );

    debugPrint('fetchUserByEmail status: ${response.statusCode}');
    debugPrint('fetchUserByEmail body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      final user = User.fromJson(json);

      if (localStorage != null) {
        await localStorage.saveUser(user);
      }

      return user;
    } else {
      throw Exception('Failed to load user by email: ${response.statusCode}');
    }
  }

  /// Updates the given [user] on the backend
  /// Returns the updated [User] object
  /// Throws an exception if the API request fails
  Future<User> updateUser(User user) async {
    final url = ApiService.buildBackendUrl('/users/${user.id}');
    final body = jsonEncode(user.toUpdateJson());
    debugPrint('UserService.updateUser PUT $url');
    debugPrint('Request body: $body');

    final response = await http.put(
      url,
      headers: ApiService.getAuthHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return User.fromJson(json);
    } else {
      debugPrint('Failed to update user. Status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }
}
