import 'song.dart';

/// Model representing the last playlist response from the API.
class LastPlaylist {
  final String? playlistId;        // Database ID (as String)
  final String name;
  final DateTime createdAt;
  final List<Song> songs;
  final String? spotifyPlaylistId; // Spotify playlist ID for embedding player

  LastPlaylist({
    this.playlistId,
    required this.name,
    required this.createdAt,
    this.songs = const [],
    this.spotifyPlaylistId,
  });

  factory LastPlaylist.fromJson(Map<String, dynamic> json) {
    List<Song> songsList = [];
    if (json['songs'] != null) {
      songsList = (json['songs'] as List<dynamic>)
          .map((songJson) => Song.fromJson(songJson as Map<String, dynamic>))
          .toList();
    }
    
    return LastPlaylist(
      playlistId: json['playlistId'] as String?,
      name: json['name'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
      songs: songsList,
      spotifyPlaylistId: json['spotifyPlaylistId'] as String?,
    );
  }

  /// Creates a copy with updated spotifyPlaylistId
  LastPlaylist copyWith({String? spotifyPlaylistId}) {
    return LastPlaylist(
      playlistId: playlistId,
      name: name,
      createdAt: createdAt,
      songs: songs,
      spotifyPlaylistId: spotifyPlaylistId ?? this.spotifyPlaylistId,
    );
  }
}
