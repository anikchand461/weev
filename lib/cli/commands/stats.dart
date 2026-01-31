import 'dart:async';
import 'dart:io' show stdout;

import 'package:chalkdart/chalk.dart';

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

// ────────────────────────────────────────────────
// Terminal helpers
// ────────────────────────────────────────────────

int get _terminalWidth {
  try {
    return stdout.hasTerminal ? stdout.terminalColumns : 80;
  } catch (_) {
    return 80;
  }
}

String _center(String text) {
  final w = _terminalWidth;
  final pad = (w - text.length) ~/ 2;
  return pad > 0 ? ' ' * pad + text : text;
}

// ────────────────────────────────────────────────
// Spinner
// ────────────────────────────────────────────────

const _frames = ['⠋', '⠙', '⠹', '⠸', '⠼', '⠴', '⠦', '⠧', '⠇', '⠏'];
const _intervalMs = 80;

Future<void> _withSpinner(String message, Future<void> Function() action) async {
  int frame = 0;
  final timer = Timer.periodic(Duration(milliseconds: _intervalMs), (_) {
    stdout.write('\r${_frames[frame % _frames.length]} $message');
    frame++;
  });

  try {
    await action();
  } finally {
    timer.cancel();
    stdout.write('\r${' ' * (message.length + 5)}\r');
  }
}

// ────────────────────────────────────────────────
// StatsCommand
// ────────────────────────────────────────────────

class StatsCommand {
  static Future<void> run(List<String> args) async {
    final config = await ConfigService.load();
    final requested = args.isNotEmpty ? args.first.toLowerCase() : null;

    if (requested != null && !config.platforms.containsKey(requested)) {
      print(chalk.red.bold(_center('❌ Platform "$requested" is not configured.')));
      return;
    }

    // ── Collect all fetch operations ────────────────────────────────
    final futures = <Future<void>>[];
    final results = <String, dynamic>{}; // platform → stats | error message

    void queue(String platform, Future<PlatformStats?> Function() fetch) {
      if (!_shouldShow(platform, requested)) return;
      if (!config.platforms.containsKey(platform)) return;

      futures.add(
        fetch()
            .then((stats) {
              if (stats != null) {
                results[platform] = stats;
              } else {
                results[platform] = 'No data returned (null)';
              }
            })
            .catchError((e) {
              results[platform] = e.toString();
            }),
      );
    }

    // Register all platforms
    if (config.platforms.containsKey('codeforces')) {
      final u = config.platforms['codeforces']!;
      queue('codeforces', () => CodeforcesStatsService.fetch(u));
    }

    if (_shouldShow('leetcode', requested) && config.platforms.containsKey('leetcode')) {
      final u = config.platforms['leetcode']!;
      queue('leetcode', () => LeetCodeStatsService.fetch(u));
    }

    if (_shouldShow('github', requested) &&
        config.platforms.containsKey('github') &&
        config.tokens.containsKey('github')) {
      final u = config.platforms['github']!;
      final t = config.tokens['github']!;
      queue('github', () => GitHubStatsService.fetch(u, t));
    }

    if (_shouldShow('gitlab', requested) && config.platforms.containsKey('gitlab')) {
      final u = config.platforms['gitlab']!;
      final t = config.tokens['gitlab'];
      if (t != null && t.trim().isNotEmpty) {
        queue('gitlab', () => GitLabStatsService.fetch(u, token: t));
      } else {
        results['gitlab'] = 'GitLab token missing or empty';
      }
    }

    if (_shouldShow('atcoder', requested) && config.platforms.containsKey('atcoder')) {
      final u = config.platforms['atcoder']!;
      queue('atcoder', () => AtCoderStatsService.fetch(u));
    }

    if (_shouldShow('codechef', requested) && config.platforms.containsKey('codechef')) {
      final u = config.platforms['codechef']!;
      queue('codechef', () => CodeChefStatsService.fetch(u));
    }

    if (_shouldShow('cses', requested) && config.platforms.containsKey('cses')) {
      final u = config.platforms['cses']!;
      queue('cses', () => CsesStatsService.fetch(u));
    }

    if (config.platforms.containsKey('gfg')) {
      final u = config.platforms['gfg']!;
      queue('gfg', () => GfgStatsService.fetch(u));
    }

    // ── Fetch everything with spinner ────────────────────────────────
    if (futures.isNotEmpty) {
      await _withSpinner('Fetching your stats...', () async {
        await Future.wait(futures);
      });
    } else {
      print(chalk.yellow(_center('No platforms configured or requested')));
      return;
    }

    // ── Print vertical dashboard with boxes ────────────────────────────────
    print('\n${chalk.bold.magenta('Weev Dashboard ────────────────────────────────────────────────')}');
    print('');

    for (final entry in results.entries) {
      final platform = entry.key;
      final value = entry.value;
      final username = config.platforms[platform] ?? 'unknown';
      final icon = _getPlatformIcon(platform);
      final color = _getPlatformColor(platform);

      if (value is PlatformStats) {
        _printDashboardCard(icon, platform.toUpperCase(), username, value, color);
      } else {
        final msg = value is String ? value : value.toString();
        _printErrorCard(icon, platform.toUpperCase(), username, msg, color);
      }
      print(''); // space between each card
    }
  }

  // ────────────────────────────────────────────────
  // Vertical colorful boxed card for success (improved map display)
  // ────────────────────────────────────────────────
  static void _printDashboardCard(String icon, String platform, String username, PlatformStats stats, Chalk color) {
    final w = _terminalWidth.clamp(60, 140);
    final cardWidth = w - 4;

    print(color('┌${'─' * cardWidth}┐'));

    final title = '$icon $platform ($username)';
    print(color('│ ${title.padRight(cardWidth - 2)} │'));

    print(color('├${'─' * cardWidth}┤'));

    for (final entry in stats.data.entries) {
      // Skip Heatmap for non-GitHub platforms
      if (entry.key == 'Heatmap' && platform.toLowerCase() != 'github') continue;

      if (entry.value is Map) {
        // Special handling for maps: show as indented bullet list
        print(color('│ ${entry.key.padRight(cardWidth - 2)} │'));
        final map = entry.value as Map;
        for (final subEntry in map.entries) {
          String subKey = subEntry.key.toString();
          String subValue = subEntry.value.toString();

          // Make keys prettier
          subKey = subKey[0].toUpperCase() + subKey.substring(1);

          // Truncate long values
          if (subValue.length > cardWidth - 20) {
            subValue = subValue.substring(0, cardWidth - 23) + '...';
          }

          final subLine = '  • $subKey: $subValue'.padRight(cardWidth - 4);
          print(color('│ ') + chalk.white(subLine) + color(' │'));
        }
      } else {
        // Normal key-value pair
        String displayKey = entry.key;
        String valueStr = entry.value.toString();

        // Make GitHub/GitLab keys more readable
        if (platform.toLowerCase() == 'github' || platform.toLowerCase() == 'gitlab') {
          if (displayKey == 'Total Contributions') displayKey = 'Contributions';
          if (displayKey == 'Pull Requests') displayKey = 'PRs';
          if (displayKey == 'Issues Opened') displayKey = 'Issues';
          if (displayKey == 'Events (Recent)') displayKey = 'Recent Events';
        }

        // Truncate long values
        if (valueStr.length > cardWidth - 30) {
          valueStr = valueStr.substring(0, cardWidth - 33) + '...';
        }

        final line = '${displayKey.padRight(22)} : $valueStr'.padRight(cardWidth - 4);
        print(color('│ ') + chalk.white(line) + color(' │'));
      }
    }

    print(color('└${'─' * cardWidth}┘'));
    print('');
  }

  // ────────────────────────────────────────────────
  // Vertical boxed card for error
  // ────────────────────────────────────────────────
  static void _printErrorCard(String icon, String platform, String username, String? message, Chalk color) {
    final w = _terminalWidth.clamp(60, 140);
    final cardWidth = w - 4;
    final safeMsg = message ?? 'Unknown error';

    print(chalk.red('┌${'─' * cardWidth}┐'));
    print(chalk.red('│ ❌ $icon $platform ($username)'.padRight(cardWidth - 1) + ' │'));
    print(chalk.red('├${'─' * cardWidth}┤'));
    print(chalk.red('│ $safeMsg'.padRight(cardWidth - 1) + ' │'));
    print(chalk.red('└${'─' * cardWidth}┘'));
    print('');
  }

  static String _getPlatformIcon(String platform) {
    switch (platform.toLowerCase()) {
      case 'codeforces': return '🟥';
      case 'leetcode':   return '🟢';
      case 'github':     return '🐙';
      case 'gitlab':     return '🦊';
      case 'atcoder':    return '🟠';
      case 'codechef':   return '🍴';
      case 'cses':       return '🔵';
      case 'gfg':        return '📗';
      default:           return '🔷';
    }
  }

  static Chalk _getPlatformColor(String platform) {
    switch (platform.toLowerCase()) {
      case 'codeforces': return chalk.blue.bold;
      case 'leetcode':   return chalk.yellow.bold;
      case 'github':     return chalk.white.bold;
      case 'gitlab':     return chalk.magenta.bold;
      case 'atcoder':    return chalk.orange.bold;
      case 'codechef':   return chalk.green.bold;
      case 'cses':       return chalk.cyan.bold;
      case 'gfg':        return chalk.greenBright.bold;
      default:           return chalk.cyan.bold;
    }
  }

  static bool _shouldShow(String platform, String? requested) {
    return requested == null || requested == platform;
  }
}
