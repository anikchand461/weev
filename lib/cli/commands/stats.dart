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

class StatsCommand {
  // ────────────────────────────────────────────────
  // Terminal helpers
  // ────────────────────────────────────────────────
  static int _getTerminalWidth() {
    try {
      return stdout.hasTerminal ? stdout.terminalColumns : 80;
    } catch (_) {
      return 80;
    }
  }

  static String _center(String text, {int? width}) {
    final w = width ?? _getTerminalWidth();
    final padding = (w - text.length) ~/ 2;
    if (padding <= 0) return text;
    return ' ' * padding + text;
  }

  static String _centerBlock(String text, int lineWidth) {
    final w = _getTerminalWidth();
    final left = (w - lineWidth) ~/ 2;
    return ' ' * left + text;
  }

  // ────────────────────────────────────────────────
  // Header & separators
  // ────────────────────────────────────────────────
  static void _printMainHeader() {
    const title = 'Weev Full Stats';
    final w = _getTerminalWidth();
    final line = '═' * w.clamp(60, 120);

    print(chalk.magenta(line));
    print(chalk.bold.magenta(_center(title)));
    print(chalk.magenta(line));
    print('');
  }

  static void _printPlatformHeader(String platform) {
    final upper = platform.toUpperCase();
    final icon = _getPlatformIcon(platform);
    final text = '$icon $upper';

    print(chalk.cyan.bold(_center('┈┈┈ $text ┈┈┈')));
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

  // ────────────────────────────────────────────────
  // Main run method
  // ────────────────────────────────────────────────
  static Future<void> run(List<String> args) async {
    final config = await ConfigService.load();
    final requested = args.isNotEmpty ? args.first.toLowerCase() : null;

    if (requested != null && !config.platforms.containsKey(requested)) {
      print(chalk.red.bold(_center('❌ Platform "$requested" is not configured.')));
      return;
    }

    _printMainHeader();

    // ── Codeforces ───────────────────────────────────
    if (config.platforms.containsKey('codeforces')) {
      final u = config.platforms['codeforces']!;
      _printPlatformHeader('codeforces');
      try {
        final s = await CodeforcesStatsService.fetch(u);
        _printPanel(s, u);
      } catch (e) {
        _printError('Codeforces', u, 'Failed to fetch', e.toString());
      }
    }

    // ── LeetCode ─────────────────────────────────────
    if (_shouldShow('leetcode', requested) && config.platforms.containsKey('leetcode')) {
      final u = config.platforms['leetcode']!;
      _printPlatformHeader('leetcode');
      try {
        final s = await LeetCodeStatsService.fetch(u);
        _printPanel(s, u);
      } catch (e) {
        _printError('LeetCode', u, 'Failed to fetch', e.toString());
      }
    }

    // ── GitHub ───────────────────────────────────────
    if (_shouldShow('github', requested) &&
        config.platforms.containsKey('github') &&
        config.tokens.containsKey('github')) {
      final u = config.platforms['github']!;
      final t = config.tokens['github']!;
      _printPlatformHeader('github');
      try {
        final s = await GitHubStatsService.fetch(u, t);
        _printPanel(s, u);
      } catch (e) {
        final msg = e.toString().toLowerCase();
        if (msg.contains('not_found') || msg.contains('resolve to a user')) {
          _printError('GitHub', u, 'Username not found', 'https://github.com/$u');
        } else if (msg.contains('401') || msg.contains('bad credentials')) {
          _printError('GitHub', u, 'Invalid/expired token', 'https://github.com/settings/tokens');
        } else {
          _printError('GitHub', u, 'Error', e.toString());
        }
      }
    }

    // ── GitLab ───────────────────────────────────────
    if (_shouldShow('gitlab', requested) && config.platforms.containsKey('gitlab')) {
      final u = config.platforms['gitlab']!;
      final t = config.tokens['gitlab'];
      _printPlatformHeader('gitlab');
      if (t == null || t.trim().isEmpty) {
        _printError('GitLab', u, 'Token missing', 'Add token in config');
      } else {
        try {
          final s = await GitLabStatsService.fetch(u, token: t);
          _printPanel(s, u);
        } catch (e) {
          final msg = e.toString().toLowerCase();
          if (msg.contains('not found') || msg.contains('404')) {
            _printError('GitLab', u, 'Username not found', 'https://gitlab.com/$u');
          } else if (msg.contains('401') || msg.contains('403')) {
            _printError('GitLab', u, 'Invalid token', 'https://gitlab.com/-/profile/personal_access_tokens');
          } else {
            _printError('GitLab', u, 'Error', e.toString());
          }
        }
      }
    }

    // ── AtCoder ──────────────────────────────────────
    if (_shouldShow('atcoder', requested) && config.platforms.containsKey('atcoder')) {
      final u = config.platforms['atcoder']!;
      _printPlatformHeader('atcoder');
      try {
        final s = await AtCoderStatsService.fetch(u);
        _printPanel(s, u);
      } catch (e) {
        _printError('AtCoder', u, 'Failed to fetch', e.toString());
      }
    }

    // ── CodeChef ─────────────────────────────────────
    if (_shouldShow('codechef', requested) && config.platforms.containsKey('codechef')) {
      final u = config.platforms['codechef']!;
      _printPlatformHeader('codechef');
      try {
        final s = await CodeChefStatsService.fetch(u);
        if (s != null) {
          _printPanel(s, u);
        } else {
          print(chalk.yellow(_center('⚠️  No data for CodeChef user "$u"')));
          print('');
        }
      } catch (e) {
        _printError('CodeChef', u, 'Failed to fetch', e.toString());
      }
    }

    // ── CSES ─────────────────────────────────────────
    if (_shouldShow('cses', requested) && config.platforms.containsKey('cses')) {
      final u = config.platforms['cses']!;
      _printPlatformHeader('cses');
      try {
        final s = await CsesStatsService.fetch(u);
        _printPanel(s, u);
      } catch (e) {
        print(chalk.yellow(_center('🔷 CSES ($u)')));
        print(chalk.gray(_center('   Note: Unable to fetch detailed stats')));
        print('');
      }
    }

    // ── GFG ──────────────────────────────────────────
    if (config.platforms.containsKey('gfg')) {
      final u = config.platforms['gfg']!;
      _printPlatformHeader('gfg');
      try {
        final s = await GfgStatsService.fetch(u);
        if (s != null) {
          _printPanel(s, u);
        } else {
          print(chalk.yellow(_center('🔷 GFG ($u)')));
          print(chalk.gray(_center('   Run `weev sync` to fetch data')));
          print('');
        }
      } catch (e) {
        _printError('GFG', u, 'Failed to load', e.toString());
      }
    }
  }

  // ────────────────────────────────────────────────
  // Panel (centered short box)
  // ────────────────────────────────────────────────
  static void _printPanel(PlatformStats stats, String username) {
    final w = _getTerminalWidth().clamp(60, 140);
    final panelWidth = 58; // inner content width
    final leftPad = (w - panelWidth - 2) ~/ 2; // for borders

    final platform = stats.platform.toUpperCase();
    final icon = _getPlatformIcon(stats.platform);
    final title = '$icon $platform ($username)';

    print(chalk.bold.brightCyan(_center(title)));
    print(chalk.gray(_centerBlock('┌${'─' * panelWidth}┐', panelWidth + 2)));

    for (final entry in stats.data.entries) {
      if (entry.key == 'Heatmap' && entry.value is Map<String, int>) {
        print(chalk.gray(_centerBlock('│ Heatmap:'.padRight(panelWidth + 1), panelWidth + 2)));
        // Heatmap usually not centered – keep as is
        GitHubHeatmapRenderer.render(entry.value as Map<String, int>);
        continue;
      }

      String line;
      if (entry.value is Map) {
        line = entry.key;
        print(chalk.gray(_centerBlock('│ $line'.padRight(panelWidth + 1), panelWidth + 2)));
        (entry.value as Map).forEach((k, v) {
          final sub = '  $k : $v';
          print(chalk.gray(_centerBlock('│', panelWidth + 2)) +
              chalk.white(sub.padRight(panelWidth - 1)) +
              chalk.gray('│'));
        });
      } else {
        line = '${entry.key.padRight(20)} : ${entry.value}';
        print(chalk.gray(_centerBlock('│ ', panelWidth + 2)) +
            chalk.white(line.padRight(panelWidth - 1)) +
            chalk.gray('│'));
      }
    }

    print(chalk.gray(_centerBlock('└${'─' * panelWidth}┘', panelWidth + 2)));
    print('');
  }

  // ────────────────────────────────────────────────
  // Error message (centered)
  // ────────────────────────────────────────────────
  static void _printError(String platform, String username, String title, String detail) {
    final icon = _getPlatformIcon(platform.toLowerCase());
    print(chalk.red.bold(_center('❌ $icon $platform ($username)')));
    print(chalk.red(_center('   $title')));
    if (detail.isNotEmpty && !detail.startsWith('Exception')) {
      print(chalk.yellow(_center('   → $detail')));
    }
    print('');
  }

  static bool _shouldShow(String platform, String? requested) {
    return requested == null || requested == platform;
  }
}
