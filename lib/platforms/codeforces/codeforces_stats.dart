class CodeforcesStats {
  final int totalSolved;
  final int totalSubmissions;
  final int contests;
  final int currentRating;
  final int maxRating;
  final Map<int, int> difficulty;

  CodeforcesStats({
    required this.totalSolved,
    required this.totalSubmissions,
    required this.contests,
    required this.currentRating,
    required this.maxRating,
    required this.difficulty,
  });
}

