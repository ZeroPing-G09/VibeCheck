/// Model representing a mood definition
class Mood {

  /// Creates a mood instance
  Mood({
    required this.id,
    required this.name,
    required this.emoji, required this.colorCode, this.tempo,
    this.danceable,
  });

  /// Creates a [Mood] from a JSON map
  factory Mood.fromJson(Map<String, dynamic> json) {
    return Mood(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      tempo: json['tempo'] as String?,
      danceable: json['danceable'] as String?,
      emoji: json['emoji'] as String? ?? '😐',
      colorCode: json['colorCode'] as String? ?? '#FFC107',
    );
  }
  /// Unique ID of the mood
  final int id;

  /// Name of the mood
  final String name;

  /// Optional tempo description
  final String? tempo;

  /// Optional danceable description
  final String? danceable;

  /// Emoji representing the mood
  final String emoji;

  /// Hex color code associated with the mood
  final String colorCode;

  /// Converts the [Mood] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'tempo': tempo,
      'danceable': danceable,
      'emoji': emoji,
      'colorCode': colorCode,
    };
  }
}

/// Model representing a user mood entry
class MoodEntry {

  /// Creates a mood entry
  MoodEntry({
    required this.id,
    required this.userId,
    required this.moodId,
    required this.moodName,
    required this.moodEmoji,
    required this.createdAt,
    this.intensity,
    this.notes,
  });

  /// Creates a [MoodEntry] from a JSON map
  factory MoodEntry.fromJson(Map<String, dynamic> json) {
    return MoodEntry(
      id: json['id'] as int? ?? 0,
      userId: json['userId']?.toString() ?? '',
      moodId: json['moodId'] as int? ?? 0,
      moodName: json['moodName'] as String? ?? '',
      moodEmoji: json['moodEmoji'] as String? ?? '',
      createdAt: json['createdAt'] as String? ?? '',
      intensity: json['intensity'] as int?,
      notes: json['notes'] as String?,
    );
  }
  /// Unique ID of the mood entry
  final int id;

  /// ID of the user
  final String userId;

  /// ID of the mood
  final int moodId;

  /// Name of the mood
  final String moodName;

  /// Emoji representing the mood
  final String moodEmoji;

  /// Creation timestamp
  final String createdAt;

  /// Optional intensity (0-100)
  final int? intensity;

  /// Optional user notes
  final String? notes;

  /// Converts the [MoodEntry] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'moodId': moodId,
      'moodName': moodName,
      'moodEmoji': moodEmoji,
      'createdAt': createdAt,
      'intensity': intensity,
      'notes': notes,
    };
  }
}

/// Helper class for creating mood entries with intensity
class MoodEntryData {

  /// Creates a mood entry data object
  MoodEntryData({
    required this.moodId,
    required this.intensity,
    this.notes,
  });
  /// Mood ID
  final int moodId;

  /// Intensity (0-100)
  final int intensity;

  /// Optional user notes
  final String? notes;

  /// Converts the [MoodEntryData] to a JSON map
  Map<String, dynamic> toJson() {
    return {
      'moodId': moodId,
      'intensity': intensity,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

/// Model representing a playlist for mood history
class Playlist {

  /// Creates a playlist instance
  Playlist({
    required this.id,
    required this.name,
    required this.userId, required this.createdAt, this.mood,
  });

  /// Creates a [Playlist] from a JSON map
  factory Playlist.fromJson(Map<String, dynamic> json) {
    return Playlist(
      id: json['id'] as int? ?? 0,
      name: json['name'] as String? ?? '',
      mood: json['mood'] as String?,
      userId: json['userId']?.toString() ?? '',
      createdAt: json['createdAt'] as String? ?? '',
    );
  }
  /// Playlist ID
  final int id;

  /// Playlist name
  final String name;

  /// Optional mood associated with the playlist
  final String? mood;

  /// User ID
  final String userId;

  /// Creation timestamp
  final String createdAt;
}

/// Model representing mood history combining mood entry with playlists
class MoodHistory {

  /// Creates a mood history instance
  MoodHistory({
    required this.id,
    required this.userId,
    required this.moodId,
    required this.moodName,
    required this.moodEmoji,
    required this.createdAt, required this.playlists, this.intensity,
    this.notes,
  });

  /// Creates a [MoodHistory] from a JSON map
  factory MoodHistory.fromJson(Map<String, dynamic> json) {
    return MoodHistory(
      id: json['id'] as int? ?? 0,
      userId: json['userId']?.toString() ?? '',
      moodId: json['moodId'] as int? ?? 0,
      moodName: json['moodName'] as String? ?? '',
      moodEmoji: json['moodEmoji'] as String? ?? '',
      intensity: json['intensity'] as int?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String? ?? '',
      playlists: (json['playlists'] as List<dynamic>?)
              ?.map((p) => Playlist.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }
  /// Mood entry ID
  final int id;

  /// User ID
  final String userId;

  /// Mood ID
  final int moodId;

  /// Name of the mood
  final String moodName;

  /// Emoji representing the mood
  final String moodEmoji;

  /// Optional intensity (0-100)
  final int? intensity;

  /// Optional user notes
  final String? notes;

  /// Creation timestamp
  final String createdAt;

  /// List of associated playlists
  final List<Playlist> playlists;
}
