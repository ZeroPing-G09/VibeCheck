class Mood {
  final int id;
  final String name;
  final String? tempo;
  final String? danceable;
  final String emoji; 
  final String colorCode;

  Mood({
    required this.id,
    required this.name,
    this.tempo,
    this.danceable,
    required this.emoji,
    required this.colorCode,
  });

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

class MoodEntry {
  final int id; 
  final String userId; 
  final int moodId;
  final String moodName;
  final String moodEmoji;
  final String createdAt;
  final int? intensity; // 0-100, percentage
  final String? notes; // Additional user notes

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

// Helper class for creating mood entries with intensity
class MoodEntryData {
  final int moodId;
  final int intensity; // 0-100
  final String? notes;

  MoodEntryData({
    required this.moodId,
    required this.intensity,
    this.notes,
  });

  Map<String, dynamic> toJson() {
    return {
      'moodId': moodId,
      'intensity': intensity,
      if (notes != null && notes!.isNotEmpty) 'notes': notes,
    };
  }
}

