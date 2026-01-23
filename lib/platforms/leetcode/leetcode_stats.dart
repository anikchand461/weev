import '../../models/platform_stats.dart';
import 'leetcode_api.dart';

class LeetCodeStatsService {
  static Future<PlatformStats> fetch(String username) async {
    final solvedByDifficulty =
        await LeetCodeApi.fetchSolved(username);

    final calendar =
        await LeetCodeApi.fetchCalendar(username);

    final int solved =
        solvedByDifficulty['All'] ?? 0;

    final int easy =
        solvedByDifficulty['Easy'] ?? 0;
    final int medium =
        solvedByDifficulty['Medium'] ?? 0;
    final int hard =
        solvedByDifficulty['Hard'] ?? 0;

    final int activeDays = calendar.length;

    return PlatformStats(
      platform: 'leetcode',
      data: {
        'Problems Solved': solved,
        'Active Days': activeDays,
        'Difficulty': {
          'Easy': easy,
          'Medium': medium,
          'Hard': hard,
        },
      },
    );
  }
}

