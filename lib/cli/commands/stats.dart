import '../../services/config_service.dart';
import '../../platforms/codeforces/codeforces_stats.dart';
import '../../platforms/leetcode/leetcode_stats.dart';

class StatsCommand {
  static Future<void> run() async {
    final config = await ConfigService.load();

    print('\n📊 Weev Full Stats\n');

    if (config.platforms.containsKey('codeforces')) {
      final handle = config.platforms['codeforces']!;
      final s = await CodeforcesStatsService.fetch(handle);

      _printStats(s);
    }

    if (config.platforms.containsKey('leetcode')) {
      final handle = config.platforms['leetcode']!;
      final s = await LeetCodeStatsService.fetch(handle);

      _printStats(s);
    }
  }

  static void _printStats(s) {
    print('🔹 ${s.platform.toUpperCase()} (${s.username})');
    print('  Problems Solved : ${s.solved}');
    print('  Submissions     : ${s.submissions}');
    print('  Active Days     : ${s.activeDays}');

    if (s.contests != null) {
      print('  Contests        : ${s.contests}');
    }
    if (s.rating != null) {
      print('  Rating          : ${s.rating}');
      print('  Max Rating      : ${s.maxRating}');
    }

    print('  Difficulty:');
    s.difficulty.forEach((k, v) {
      print('    $k : $v');
    });

    print('');
  }
}

