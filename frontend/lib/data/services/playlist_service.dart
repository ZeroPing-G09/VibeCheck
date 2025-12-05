import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:http/http.dart' as http;

import '../models/last_playlist.dart';

/// Service for fetching playlist-related data from the backend.
class PlaylistService {
  final AuthService _authService;

  PlaylistService({required AuthService authService})
      : _authService = authService;

  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  /// Fetches the last playlist for the authenticated user.
  /// Returns null if no playlist exists (404 response).
  /// Throws an exception for other error responses.
  Future<LastPlaylist?> fetchLastPlaylist() async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse('$baseUrl/users/last-playlist');
    debugPrint('PlaylistService.fetchLastPlaylist GET $url');

    final response = await http.get(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    debugPrint('fetchLastPlaylist status: ${response.statusCode}');
    debugPrint('fetchLastPlaylist body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body) as Map<String, dynamic>;
      return LastPlaylist.fromJson(json);
    } else if (response.statusCode == 404) {
      // No playlist found - this is expected for new users
      return null;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception('Failed to fetch last playlist: ${response.statusCode}');
    }
  }
}
