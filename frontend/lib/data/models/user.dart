class User {
  final int id;
  final String username;
  final String email;
  final String profilePicture;
  final List<String> genres;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.profilePicture,
    required this.genres,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int? ?? 0,
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      profilePicture: json['profile_picture'] as String? ?? '',
      genres: (json['genres'] as List<dynamic>?)?.map((g) => g.toString()).toList() ?? [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'profile_picture': profilePicture,
      'genres': genres,
    };
  }

  Map<String, dynamic> toUpdateJson() => {
    'username': username,
    'profile_picture': profilePicture,
    'genres': genres,
  };

  User copyWith({
    int? id,
    String? username,
    String? email,
    String? profilePicture,
    List<String>? genres,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      profilePicture: profilePicture ?? this.profilePicture,
      genres: genres ?? this.genres,
    );
  }
}
