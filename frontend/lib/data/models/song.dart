/// Model representing a song in a playlist.
class Song {
  final int id;
  final String name;
  final String url;
  final String artistName;

  Song({
    required this.id,
    required this.name,
    required this.url,
    required this.artistName,
  });

  factory Song.fromJson(Map<String, dynamic> json) {
    return Song(
      id: json['id'] as int,
      name: json['name'] as String? ?? '',
      url: json['url'] as String? ?? '',
      artistName: json['artistName'] as String? ?? '',
    );
  }
}
