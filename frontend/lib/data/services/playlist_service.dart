import 'dart:convert';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class PlaylistService {
  String get baseUrl {
    if (kIsWeb) return 'http://localhost:8080';
    try {
      if (Platform.isAndroid) return 'http://10.0.2.2:8080';
    } catch (_) {}
    return 'http://localhost:8080';
  }

  Future<Map<String, dynamic>> savePlaylistToSpotify({
    required int userId,
    required int playlistId,
    required String spotifyPlaylistName,
  }) async {
    final url = Uri.parse('$baseUrl/users/playlist/save');
    debugPrint('PlaylistService.savePlaylistToSpotify POST $url');
    
    final body = jsonEncode({
      'playlistId': playlistId,
      'spotifyPlaylistName': spotifyPlaylistName,
    });

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'X-User-Id': userId.toString(),
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

