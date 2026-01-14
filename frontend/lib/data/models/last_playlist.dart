import 'package:frontend/data/models/song.dart';

/// Model representing the last playlist response from the API
class LastPlaylist {

  /// Creates a last playlist instance
  LastPlaylist({
    required this.name, required this.createdAt, this.playlistId,
    this.songs = const [],
    this.spotifyPlaylistId,
  });

  /// Creates a [LastPlaylist] from a JSON map
  factory LastPlaylist.fromJson(Map<String, dynamic> json) {
    var songsList = <Song>[];
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
  /// Database ID of the playlist as a string
  final String? playlistId;

  /// Name of the playlist
  final String name;

  /// Date and time when the playlist was created
  final DateTime createdAt;

  /// List of songs in the playlist
  final List<Song> songs;

  /// Spotify playlist ID for embedding the player
  final String? spotifyPlaylistId;

  /// Returns a copy of this playlist with an updated [spotifyPlaylistId]
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
