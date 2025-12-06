import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/user.dart';
import 'api_service.dart';

class UserService {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  Future<User> fetchUserById(int id) async {
    final url = Uri.parse('$baseUrl/users/$id');
    debugPrint('UserService.fetchUserById GET $url');
    final response = await http.get(
      url,
      headers: ApiService.getAuthHeaders(),
    );

    debugPrint('fetchUserById status: ${response.statusCode}');
    debugPrint('fetchUserById body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      json['id'] = json['id'] ?? id;
      return User.fromJson(json);
    } else {
      throw Exception('Failed to load user: ${response.statusCode}');
    }
  }

  Future<User> fetchUserByEmail(String email) async {
    final url = Uri.parse('$baseUrl/users/by-email?email=${Uri.encodeQueryComponent(email)}');
    debugPrint('UserService.fetchUserByEmail GET $url');
    final response = await http.get(
      url,
      headers: ApiService.getAuthHeaders(),
    );

    debugPrint('fetchUserByEmail status: ${response.statusCode}');
    debugPrint('fetchUserByEmail body: ${response.body}');

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      return User.fromJson(json);
    } else {
      throw Exception('Failed to load user by email: ${response.statusCode}');
    }
  }

  Future<User> updateUser(User user) async {
    final url = Uri.parse('$baseUrl/users/${user.id}');
    final body = jsonEncode(user.toUpdateJson());
    debugPrint('UserService.updateUser PUT $url');
    debugPrint('Request body: $body');

    final response = await http.put(
      url,
      headers: ApiService.getAuthHeaders(),
      body: body,
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> json = jsonDecode(response.body) as Map<String, dynamic>;
      return User.fromJson(json);
    } else {
      debugPrint('Failed to update user. Status: ${response.statusCode}');
      debugPrint('Response body: ${response.body}');
      throw Exception('Failed to update user: ${response.statusCode}');
    }
  }
}
