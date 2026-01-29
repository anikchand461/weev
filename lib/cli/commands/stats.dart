import '../../services/config_service.dart';
import '../../models/platform_stats.dart';
import '../../platforms/codeforces/codeforces_stats.dart';
import '../../platforms/leetcode/leetcode_stats.dart';
import '../../platforms/github/github_stats.dart';
import '../../platforms/gitlab/gitlab_stats.dart';
import '../../utils/github_heatmap_renderer.dart';

class StatsCommand {
  static Future<void> run() async {
    final config = await ConfigService.load();

    print('📊 Weev Full Stats\n');

    if (config.platforms.containsKey('codeforces')) {
      final stats = await CodeforcesStatsService.fetch(
        config.platforms['codeforces']!,
      );
      _print(stats, config.platforms['codeforces']!);
    }

    if (config.platforms.containsKey('leetcode')) {
      final stats = await LeetCodeStatsService.fetch(
        config.platforms['leetcode']!,
      );
      _print(stats, config.platforms['leetcode']!);
    }

    // AFTER leetcode block
    if (config.platforms.containsKey('github') &&
        config.tokens.containsKey('github')) {
      final stats = await GitHubStatsService.fetch(
        config.platforms['github']!,
        config.tokens['github']!,
      );
      _print(stats, config.platforms['github']!);
    }

    if (config.platforms.containsKey('gitlab')) {
      final stats = await GitLabStatsService.fetch(
        config.platforms['gitlab']!,
        token: config.tokens['gitlab'],
      );
      _print(stats, config.platforms['gitlab']!);
    }

  }

  static void _print(
    PlatformStats stats,
    String username,
  ) {
    print('🔷 ${stats.platform.toUpperCase()} ($username)');

    for (final entry in stats.data.entries) {
      // 🔥 Special handling for GitHub heatmap
      if (entry.key == 'Heatmap' &&
          entry.value is Map<String, int>) {
        print('Heatmap:');
        GitHubHeatmapRenderer.render(
          entry.value as Map<String, int>,
        );
        continue;
      }

      // Normal map fields (difficulty, etc.)
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

