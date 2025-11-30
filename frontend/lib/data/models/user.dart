class User {
  final String id;
  final String displayName;
  final String email;
  final String avatarUrl;
  final String? lastLogIn;
  final List<String> genres;

  User({
    required this.id,
    required this.displayName,
    required this.email,
    required this.avatarUrl,
    this.lastLogIn,
    required this.genres,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as String? ?? '',
      displayName: json['display_name'] as String? ?? '',
      email: json['email'] as String? ?? '',
      avatarUrl: json['avatar_url'] as String? ?? '',
      lastLogIn: json['last_log_in'] as String?, // Nullable
      // Assumes 'genres' is returned as a list of strings (names or IDs)
      genres:
          (json['genres'] as List<dynamic>?)
              ?.map((g) => g.toString())
              .toList() ??
          [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'display_name': displayName,
      'email': email,
      'avatar_url': avatarUrl,
      'genres': genres,
    };
  }

  Map<String, dynamic> toUpdateJson() => {
    'display_name': displayName,
    'avatar_url': avatarUrl,
    'genres': genres,
  };

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
