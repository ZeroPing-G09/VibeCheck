/// Model representing a song in a playlist
class Song {

  /// Creates a song instance
  Song({
    required this.id,
    required this.name,
    required this.url,
    required this.artistName,
  });

  /// Creates a [Song] from a JSON map
  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
    );
  }
  /// Unique ID of the song
  final int id;

  /// Name of the song
  final String name;

  /// URL to the song resource
  final String url;

  /// Name of the artist
  final String artistName;
}
