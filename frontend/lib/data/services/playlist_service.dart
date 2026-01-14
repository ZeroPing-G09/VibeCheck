import 'dart:convert';
import 'dart:io' show Platform;

import 'package:flutter/foundation.dart';
import 'package:frontend/data/models/last_playlist.dart';
import 'package:frontend/data/services/auth_service.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service for fetching and managing playlist-related data from the backend
/// Provides methods to fetch the last playlist, generate new playlists, 
/// and save to Spotify
class PlaylistService {

  /// Creates a [PlaylistService] using the provided [authService]
  PlaylistService({required AuthService authService})
      : _authService = authService;
  final AuthService _authService;

  /// Returns the backend base URL depending on platform
  /// Uses localhost for web, Android emulator, or default
  String get baseUrl {
    if (kIsWeb) {
      return 'http://localhost:8080';
    }
    try {
      if (Platform.isAndroid) {
        return 'http://10.0.2.2:8080';
      }
    } catch (_) {}
    return 'http://localhost:8080';
  }

  /// Fetches the last playlist for the authenticated user
  /// Optional [mood] parameter can filter the playlist
  /// Returns [LastPlaylist] if found, otherwise null
  /// Throws an exception if user is not authenticated
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
      return null;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      debugPrint(
  'Error fetching playlist (${response.statusCode}), treating as no playlist');
      return null;
    }
  }

  /// Generates a new playlist for the authenticated user
  /// Requires [mood] and optional [genres] list
  /// Throws an exception if user is not authenticated or request fails
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

    if (response.statusCode == 200 || response.statusCode == 201) {
      return;
    } else if (response.statusCode == 401) {
      throw Exception('Unauthorized: Invalid or expired token');
    } else {
      throw Exception(
          'Failed to generate playlist: '
          '${response.statusCode} - ${response.body}');
    }
  }

  /// Saves an existing internal playlist to the user's Spotify account
  /// Requires [playlistId] (UUID) and [spotifyPlaylistName]
  /// Returns the response from backend as [Map<String, dynamic>]
  /// Throws an exception if authentication or Spotify permissions are missing, 
  /// or if the request fails
  Future<Map<String, dynamic>> savePlaylistToSpotify({
    required String playlistId,
    required String spotifyPlaylistName,
  }) async {
    final session = Supabase.instance.client.auth.currentSession;
    final supabaseToken = session?.accessToken;
    final spotifyToken = session?.providerToken;

    if (session == null || supabaseToken == null) {
      throw Exception('Not authenticated. Please log in again.');
    }

    if (spotifyToken == null) {
      throw Exception(
        'Spotify permission missing. '
        'Please Log Out and Log In again '
        'to refresh the connection.',
      );
    }

    final userId = session.user.id;
    final url = Uri.parse('$baseUrl/users/playlist/save');
    debugPrint('PlaylistService.savePlaylistToSpotify POST $url');

    final body = jsonEncode({
      'playlistId': playlistId,
      'spotifyPlaylistName': spotifyPlaylistName,
    });

    final response = await http.post(
      url,
      headers: {
        'Authorization': 'Bearer $supabaseToken',
        'X-User-Id': userId,
        'X-Spotify-Token': spotifyToken,
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
      throw Exception(errorBody['message'] ?? 
      'Failed to save playlist to Spotify');
    }
  }
}
