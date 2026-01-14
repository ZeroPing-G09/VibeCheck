/// Model representing a user in the system
class User {

  /// Creates a [User] instance
  User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    required this.genres, this.lastLogIn,
  });

  /// Creates a [User] from a JSON map
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      lastLogIn: json['last_log_in'] as String?,
      genres: (json['genres'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          [],
    );
  }
  /// Unique user ID
  final String id;

  /// Display name of the user
  final String displayName;

  /// Email address of the user
  final String email;

  /// URL of the user's avatar
  final String avatarUrl;

  /// Timestamp of the last login, nullable
  final String? lastLogIn;

  /// List of user-selected genres
  final List<String> genres;

  /// Converts the [User] to a JSON map for general usage
  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'email': email,
      'avatar_url': avatarUrl,
      'genres': genres,
    };
  }

  /// Converts the [User] to a JSON map for update operations
  Map<String, dynamic> toUpdateJson() {
    return {
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'genres': genres,
    };
  }

  /// Returns a copy of the [User] with optional updated fields
  User copyWith({
    String? id,
    String? displayName,
    String? email,
    String? avatarUrl,
    String? lastLogIn,
    List<String>? genres,
  }) {
    return User(
      id: id ?? this.id,
      displayName: displayName ?? this.displayName,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      lastLogIn: lastLogIn ?? this.lastLogIn,
      genres: genres ?? this.genres,
    );
  }
}
