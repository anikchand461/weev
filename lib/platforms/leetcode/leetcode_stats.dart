import '../../models/platform_stats.dart';
import 'leetcode_api.dart';

class LeetCodeStatsService {
  static Future<PlatformStats> fetch(String username) async {
    // Fetch solved counts by difficulty
    final solved = await LeetCodeApi.fetchSolved(username);

    final total = solved.values.fold<int>(
      0,
      (a, b) => a + b,
    );

    // Fetch submission calendar
    final calendar =
        await LeetCodeApi.fetchCalendar(username);

    final activeDays = calendar.length;

    return PlatformStats(
      platform: 'leetcode',
      data: {
        'Problems Solved': total,
        'Submissions': calendar.values.fold<int>(
          0,
          (a, b) => a + b,
        ),
        'Active Days': activeDays,
        'Difficulty': {
          'Easy': solved['Easy'] ?? 0,
          'Medium': solved['Medium'] ?? 0,
          'Hard': solved['Hard'] ?? 0,
        },
      },
    );
  }
}

