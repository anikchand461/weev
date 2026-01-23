class PlatformStats {
  final String platform;
  final String username;

  final int solved;
  final int submissions;
  final int activeDays;

  final Map<String, int> difficulty;

  // Optional (platform-specific)
  final int? contests;
  final int? rating;
  final int? maxRating;

  PlatformStats({
    required this.platform,
    required this.username,
    required this.solved,
    required this.submissions,
    required this.activeDays,
    required this.difficulty,
    this.contests,
    this.rating,
    this.maxRating,
  });
}

