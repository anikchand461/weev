class PlatformAccount {
  final String platform;
  final String username;

  PlatformAccount({
    required this.platform,
    required this.username,
  });

  Map<String, dynamic> toJson() => {
        'platform': platform,
        'username': username,
      };

  factory PlatformAccount.fromJson(Map<String, dynamic> json) {
    return PlatformAccount(
      platform: json['platform'],
      username: json['username'],
    );
  }
}

