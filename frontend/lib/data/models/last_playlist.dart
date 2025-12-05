/// Model representing the last playlist response from the API.
class LastPlaylist {
  final String? playlistId;
  final String name;
  final DateTime createdAt;

  LastPlaylist({
    this.playlistId,
    required this.name,
    required this.createdAt,
  });

  factory LastPlaylist.fromJson(Map<String, dynamic> json) {
    return LastPlaylist(
      playlistId: json['playlistId'] as String?,
      name: json['name'] as String? ?? '',
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }

  /// Check if this playlist has a valid Spotify ID for embedding
  bool get hasSpotifyId => playlistId != null && playlistId!.isNotEmpty;
}
