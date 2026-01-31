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
    // Codeforces (SAFE)
    // ─────────────────────────────
    if (config.platforms.containsKey('codeforces')) {
      final username = config.platforms['codeforces']!;
      try {
        final stats =
            await CodeforcesStatsService.fetch(username);
        _print(stats, username);
      } catch (e) {
        print('🔷 CODEFORCES ($username)');
        print('Error: The username is not available\n');
      }
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
      
      final username = config.platforms['github']!;
      final token = config.tokens['github']!;

      try {
        final stats = await GitHubStatsService.fetch(username, token);
        _print(stats, username);
      } catch (e) {
        // ─── Handle different kinds of failures ────────────────────────
        
        if (e.toString().contains('NOT_FOUND') || 
            e.toString().contains('Could not resolve to a User')) {
          print('❌ GitHub username not found: "$username"');
          print('   → Please check the spelling or if the account exists.');
          print('');
          // continue to next platform (don't rethrow)
        }
        
        else if (e.toString().contains('401') || 
                e.toString().contains('Bad credentials') ||
                e.toString().contains('INVALID_TOKEN') ||
                e.toString().contains('TOKEN') && e.toString().contains('invalid')) {
          print('❌ Invalid or expired GitHub token');
          print('   → Please generate a new Personal Access Token at:');
          print('     https://github.com/settings/tokens');
          print('   → Make sure it has "read:user" scope (and others you need)');
          print('');
          // continue or exit(1) depending on your CLI philosophy
        }
        
        else {
          // Unknown / unexpected error — let developer see the stack trace
          print('❌ Failed to fetch GitHub stats for "$username"');
          print('   Error: $e');
          // Optionally: rethrow; if you want to halt on unknown errors
          print('');
        }
      }
    }

    // ─────────────────────────────
    // GitLab
    // ─────────────────────────────
    if (_shouldShow('gitlab', requestedPlatform) &&
        config.platforms.containsKey('gitlab')) {
      
      final username = config.platforms['gitlab']!;
      final token = config.tokens['gitlab'];  // may be null → handle below

      if (token == null || token.isEmpty) {
        print('❌ GitLab token missing or empty');
        print('   → Add a valid token in your config for platform "gitlab"');
        print('');
        // continue or return;
      } else {
        try {
          final stats = await GitLabStatsService.fetch(
            username,
            token: token,
          );
          _print(stats, username);
        } catch (e, stack) {
          // ─── Differentiate common failure modes ────────────────────────
          
          final errorStr = e.toString().toLowerCase();

          if (errorStr.contains('not found') || 
              errorStr.contains('404') ||
              errorStr.contains('user not found')) {
            print('❌ GitLab username not found: "$username"');
            print('   → Double-check spelling/case (GitLab usernames are case-sensitive)');
            print('   → Or confirm the user exists at https://gitlab.com/$username (or your self-hosted instance)');
            print('');
          }
          
          else if (errorStr.contains('401') || 
                  errorStr.contains('unauthorized') ||
                  errorStr.contains('bad credentials') ||
                  errorStr.contains('forbidden') && errorStr.contains('403')) {
            print('❌ GitLab token invalid, expired, or lacks permissions');
            print('   → Generate a new Personal Access Token at:');
            print('     https://gitlab.com/-/profile/personal_access_tokens');
            print('   → Required scopes: at minimum "read_user", "api" (for broader stats)');
            print('   → For self-hosted GitLab, use the equivalent URL');
            print('');
          }
          
          else {
            // Fallback for unexpected errors – show details
            print('❌ Failed to fetch GitLab stats for "$username"');
            print('   Error: $e');
            print('');
            // Optionally: print(stack); if you want full trace for debugging
          }
        }
      }
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
