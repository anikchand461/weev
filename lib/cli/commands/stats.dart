import '../../services/config_service.dart';
import '../../models/platform_stats.dart';

import '../../platforms/codeforces/codeforces_stats.dart';
import '../../platforms/leetcode/leetcode_stats.dart';
import '../../platforms/github/github_stats.dart';
import '../../platforms/gitlab/gitlab_stats.dart';
import '../../platforms/atcoder/atcoder_stats.dart';

import '../../utils/github_heatmap_renderer.dart';
import '../../platforms/codechef/codechef_stats.dart';
import '../../platforms/cses/cses_stats.dart';

class StatsCommand {
  static Future<void> run() async {
    final config = await ConfigService.load();

    print('📊 Weev Full Stats\n');

    // ─────────────────────────────
    // Codeforces
    // ─────────────────────────────
    if (config.platforms.containsKey('codeforces')) {
      final stats = await CodeforcesStatsService.fetch(
        config.platforms['codeforces']!,
      );
      _print(stats, config.platforms['codeforces']!);
    }

    // ─────────────────────────────
    // LeetCode
    // ─────────────────────────────
    if (config.platforms.containsKey('leetcode')) {
      final stats = await LeetCodeStatsService.fetch(
        config.platforms['leetcode']!,
      );
      _print(stats, config.platforms['leetcode']!);
    }

    // ─────────────────────────────
    // GitHub
    // ─────────────────────────────
    if (config.platforms.containsKey('github') &&
        config.tokens.containsKey('github')) {
      final stats = await GitHubStatsService.fetch(
        config.platforms['github']!,
        config.tokens['github']!,
      );
      _print(stats, config.platforms['github']!);
    }

    // ─────────────────────────────
    // GitLab
    // ─────────────────────────────
    if (config.platforms.containsKey('gitlab')) {
      final stats = await GitLabStatsService.fetch(
        config.platforms['gitlab']!,
        token: config.tokens['gitlab'],
      );
      _print(stats, config.platforms['gitlab']!);
    }

    // ─────────────────────────────
    // AtCoder (STATS ONLY)
    // ─────────────────────────────
    if (config.platforms.containsKey('atcoder')) {
      final stats = await AtCoderStatsService.fetch(
        config.platforms['atcoder']!,
      );
      _print(stats, config.platforms['atcoder']!);
    }

    //codechef
    if (config.platforms.containsKey('codechef')) {
      final stats = await CodeChefStatsService.fetch(
        config.platforms['codechef']!,
      );

      if (stats != null) {
        _print(stats, config.platforms['codechef']!);
      }
    }

    // ─────────────────────────────
    // CSES (STATS ONLY, SAFE)
    // ─────────────────────────────
    if (config.platforms.containsKey('cses')) {
      try {
        final stats = await CsesStatsService.fetch(
          config.platforms['cses']!,
        );
        _print(stats, config.platforms['cses']!);
      } catch (e) {
        print('🔷 CSES (${config.platforms['cses']!})');
        print('Error: Unable to fetch CSES stats\n');
      }
    }
  }

  static void _print(
    PlatformStats stats,
    String username,
  ) {
    print('🔷 ${stats.platform.toUpperCase()} ($username)');

    for (final entry in stats.data.entries) {
      // GitHub heatmap special handling
      if (entry.key == 'Heatmap' && entry.value is Map<String, int>) {
        print('Heatmap:');
        GitHubHeatmapRenderer.render(
          entry.value as Map<String, int>,
        );
        continue;
      }

      if (entry.value is Map) {
        print('${entry.key}:');
        (entry.value as Map).forEach(
          (k, v) => print('  $k : $v'),
        );
      } else {
        print('${entry.key} : ${entry.value}');
      }
    }

    print('');
  }
}
