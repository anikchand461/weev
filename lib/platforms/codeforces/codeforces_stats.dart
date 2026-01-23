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

    for (final s in submissions) {
      final ts = s['creationTimeSeconds'] * 1000;
      final d = DateTime.fromMillisecondsSinceEpoch(ts);
      activeDays.add('${d.year}-${d.month}-${d.day}');

      if (s['verdict'] != 'OK') continue;

      final p = s['problem'];
      solvedProblems.add('${p['contestId']}${p['index']}');

      if (p['rating'] != null) {
        final key = p['rating'].toString();
        difficulty.update(
          key,
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

    // ✅ NEW unified PlatformStats return
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

