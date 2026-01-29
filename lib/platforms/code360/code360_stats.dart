import '../../models/platform_stats.dart';
import 'code360_api.dart';

class Code360StatsService {
  static Future<PlatformStats> fetch(String username) async {
    final profile = await Code360Api.fetchProfile(username);
    final submissions = await Code360Api.fetchSubmissions(username);

    final solvedProblems = <String>{};
    final activeDays = <String>{};
    final difficulty = <String, int>{};

    for (final sub in submissions) {
      if (sub['status'] != 'AC') continue;

      solvedProblems.add(sub['problem_id'].toString());

      final date = DateTime.parse(sub['submitted_at']);
      activeDays.add('${date.year}-${date.month}-${date.day}');

      final level = sub['difficulty'] ?? 'Unknown';
      difficulty.update(level, (v) => v + 1, ifAbsent: () => 1);
    }

    return PlatformStats(
      platform: 'code360',
      data: {
        'Problems Solved': solvedProblems.length,
        'Submissions': submissions.length,
        'Active Days': activeDays.length,
        'Difficulty': difficulty,
      },
    );
  }
}

