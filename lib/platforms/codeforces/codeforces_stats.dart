import 'codeforces_api.dart';
import '../../models/platform_stats.dart';

class CodeforcesStatsService {
  static Future<PlatformStats> fetch(String handle) async {
    final submissions =
        await CodeforcesApi.fetchSubmissions(handle);
    final contests =
        await CodeforcesApi.fetchContests(handle);

    final solvedProblems = <String>{};
    final difficulty = <String, int>{};
    final activeDays = <String>{};

    // Track difficulty per UNIQUE problem
    final Map<String, int> problemDifficulty = {};

    for (final s in submissions) {
      final ts = s['creationTimeSeconds'] * 1000;
      final d = DateTime.fromMillisecondsSinceEpoch(ts);
      activeDays.add('${d.year}-${d.month}-${d.day}');

      if (s['verdict'] != 'OK') continue;

      final p = s['problem'];
      final problemId = '${p['contestId']}${p['index']}';

      // Only count once per problem
      if (solvedProblems.contains(problemId)) continue;

      solvedProblems.add(problemId);

      if (p['rating'] != null) {
        final ratingKey = p['rating'].toString();
        difficulty.update(
          ratingKey,
          (v) => v + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final rating =
        contests.isEmpty ? null : contests.last['newRating'];

    final maxRating = contests.isEmpty
        ? null
        : contests
            .map<int>((c) => c['newRating'])
            .reduce((a, b) => a > b ? a : b);

    return PlatformStats(
      platform: 'codeforces',
      data: {
        'Problems Solved': solvedProblems.length,
        'Submissions': submissions.length,
        'Active Days': activeDays.length,
        'Contests': contests.length,
        'Rating': rating,
        'Max Rating': maxRating,
        'Difficulty': difficulty,
      },
    );
  }
}

