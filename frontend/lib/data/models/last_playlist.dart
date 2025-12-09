/// Model representing the last playlist response from the API.
class LastPlaylist {
  final String? playlistId;        // Database ID (as String)
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
}
