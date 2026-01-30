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
import '../../platforms/gfg/gfg_stats.dart';

class StatsCommand {
  static Future<void> run(List<String> args) async {
    final config = await ConfigService.load();

    final requestedPlatform = args.isNotEmpty ? args.first.toLowerCase() : null;

    if (requestedPlatform != null &&
        !config.platforms.containsKey(requestedPlatform)) {
      print('❌ Platform "$requestedPlatform" is not configured.');
      return;
    }

    print('📊 Weev Full Stats\n');

    // ─────────────────────────────
    // Codeforces
    // ─────────────────────────────
    if (_shouldShow('codeforces', requestedPlatform) &&
        config.platforms.containsKey('codeforces')) {
      final stats = await CodeforcesStatsService.fetch(
        config.platforms['codeforces']!,
      );
      _print(stats, config.platforms['codeforces']!);
    }

    // ─────────────────────────────
    // LeetCode
    // ─────────────────────────────
    if (_shouldShow('leetcode', requestedPlatform) &&
        config.platforms.containsKey('leetcode')) {
      final stats = await LeetCodeStatsService.fetch(
        config.platforms['leetcode']!,
      );
      _print(stats, config.platforms['leetcode']!);
    }

    // ─────────────────────────────
    // GitHub
    // ─────────────────────────────
    if (_shouldShow('github', requestedPlatform) &&
        config.platforms.containsKey('github') &&
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
    if (_shouldShow('gitlab', requestedPlatform) &&
        config.platforms.containsKey('gitlab')) {
      final stats = await GitLabStatsService.fetch(
        config.platforms['gitlab']!,
        token: config.tokens['gitlab'],
      );
      _print(stats, config.platforms['gitlab']!);
    }

    // ─────────────────────────────
    // AtCoder
    // ─────────────────────────────
    if (_shouldShow('atcoder', requestedPlatform) &&
        config.platforms.containsKey('atcoder')) {
      final stats = await AtCoderStatsService.fetch(
        config.platforms['atcoder']!,
      );
      _print(stats, config.platforms['atcoder']!);
    }

    // ─────────────────────────────
    // CodeChef
    // ─────────────────────────────
    if (_shouldShow('codechef', requestedPlatform) &&
        config.platforms.containsKey('codechef')) {
      final stats = await CodeChefStatsService.fetch(
        config.platforms['codechef']!,
      );
      if (stats != null) {
        _print(stats, config.platforms['codechef']!);
      }
    }

    // ─────────────────────────────
    // CSES
    // ─────────────────────────────
    if (_shouldShow('cses', requestedPlatform) &&
        config.platforms.containsKey('cses')) {
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
        // ─────────────────────────────
       // GFG (READ-ONLY)
       // ─────────────────────────────
    if (config.platforms.containsKey('gfg')) {
      final stats = await GfgStatsService.fetch(
        config.platforms['gfg']!,
      );

      if (stats != null) {
        _print(stats, config.platforms['gfg']!);
      } else {
        print('🔷 GFG (${config.platforms['gfg']!})');
        print('Run `weev sync` to fetch GFG data\n');
      }
    }
  }

  static bool _shouldShow(
    String platform,
    String? requested,
  ) {
    return requested == null || requested == platform;
  }

  static void _print(
    PlatformStats stats,
    String username,
  ) {
    print('🔷 ${stats.platform.toUpperCase()} ($username)');

    for (final entry in stats.data.entries) {
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
