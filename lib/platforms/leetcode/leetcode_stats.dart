import 'leetcode_api.dart';
import '../../models/platform_stats.dart';

class LeetCodeStatsService {
  static Future<PlatformStats> fetch(String username) async {
    final solvedMap =
        await LeetCodeApi.fetchSolved(username);
    final calendar =
        await LeetCodeApi.fetchCalendar(username);

    final difficulty = <String, int>{};
    int solved = 0;

    solvedMap.forEach((k, v) {
      difficulty[k] = v;
      if (k == 'All') solved = v;
    });

    final submissions =
        calendar.values.fold<int>(0, (a, b) => a + b);

    return PlatformStats(
      platform: 'LeetCode',
      username: username,
      solved: solved,
      submissions: submissions,
      activeDays: calendar.length,
      difficulty: difficulty,
    );
  }
}

