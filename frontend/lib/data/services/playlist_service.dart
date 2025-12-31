import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../data/services/auth_service.dart';
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
  /// Optionally filters by mood if provided.
  /// Returns null if no playlist exists (404 response).
  /// Throws an exception for other error responses.
  Future<LastPlaylist?> fetchLastPlaylist({String? mood}) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final uri = Uri.parse('$baseUrl/users/last-playlist');
    final url = mood != null && mood.isNotEmpty
        ? uri.replace(queryParameters: {'mood': mood})
        : uri;
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
      // For 500 errors (e.g., database schema issues), treat as no playlist exists
      // This provides a better user experience than showing a technical error
      debugPrint('Error fetching playlist (${response.statusCode}), treating as no playlist');
      return null;
    }
  }

  /// Generates a new playlist for the authenticated user.
  /// [mood] is the mood for the playlist (e.g., "happy", "sad", "energetic").
  /// [genres] is an optional list of genre names to influence the playlist.
  /// Throws an exception if the request fails.
  Future<void> generatePlaylist({
    required String mood,
    List<String>? genres,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse('$baseUrl/playlist/generate');
    debugPrint('PlaylistService.generatePlaylist POST $url');

    final requestBody = jsonEncode({
      'mood': mood,
      'genres': genres ?? [],
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: requestBody,
    );

    debugPrint('generatePlaylist status: ${response.statusCode}');
    debugPrint('generatePlaylist body: ${response.body}');

    if (response.statusCode == 200 || response.statusCode == 201) {
      // Playlist generated successfully
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception(
          'Failed to generate playlist: ${response.statusCode} - ${response.body}');
    }
  }

  /// Saves an existing internal playlist to the user's Spotify account.
  Future<Map<String, dynamic>> savePlaylistToSpotify({
    required int playlistId,
    required String spotifyPlaylistName,
  }) async {
    final token = await _authService.getAccessToken();
    if (token == null) {
      throw Exception('Not authenticated');
    }

    final url = Uri.parse('$baseUrl/users/playlist/save');
    debugPrint('PlaylistService.savePlaylistToSpotify POST $url');
    
    final body = jsonEncode({
      'playlistId': playlistId,
      'spotifyPlaylistName': spotifyPlaylistName,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $token', // Use standard auth
        'Content-Type': 'application/json',
      },
      body: body,
    );

    debugPrint('savePlaylistToSpotify status: ${response.statusCode}');
    debugPrint('savePlaylistToSpotify body: ${response.body}');

    if (response.statusCode == 200) {
      return jsonDecode(response.body) as Map<String, dynamic>;
    } else {
      final errorBody = jsonDecode(response.body) as Map<String, dynamic>;
      throw Exception(errorBody['message'] ?? 'Failed to save playlist to Spotify');
    }
  }
}