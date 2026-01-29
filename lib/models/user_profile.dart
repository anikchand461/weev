class UserProfile {
  Map<String, String> platforms;
  Map<String, String> tokens;

  UserProfile({
    required this.platforms,
    required this.tokens,
  });

  factory UserProfile.empty() => UserProfile(
        platforms: {},
        tokens: {},
      );

  Map<String, dynamic> toJson() => {
        'platforms': platforms,
        'tokens': tokens,
      };

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      platforms: Map<String, String>.from(json['platforms'] ?? {}),
      tokens: Map<String, String>.from(json['tokens'] ?? {}),
    );
  }
}

