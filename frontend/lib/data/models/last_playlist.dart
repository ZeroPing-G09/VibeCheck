import 'song.dart';

/// Model representing the last playlist response from the API.
class LastPlaylist {
  final String? playlistId;        // Database ID (as String)
  final String name;
  final DateTime createdAt;
  final List<Song> songs;

  LastPlaylist({
    this.playlistId,
    required this.name,
    required this.createdAt,
    this.songs = const [],
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
    );
  }
}
