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
// SummaryCommand
// ────────────────────────────────────────────────

class SummaryCommand {
  static Future<void> run(List<String> args) async {
    final config = await ConfigService.load();
    final requested = args.isNotEmpty ? args.first.toLowerCase() : null;

    if (requested != null && !config.platforms.containsKey(requested)) {
      print(chalk.red.bold(_center('❌ Platform "$requested" is not configured.')));
      return;
    }

    // ── Collect all fetch operations ────────────────────────────────
    final futures = <Future<void>>[];
    final results = <String, dynamic>{};

    void queue(String platform, Future<PlatformStats?> Function() fetch) {
      if (requested != null && platform != requested) return;
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

    if ((requested == null || requested == 'leetcode') && config.platforms.containsKey('leetcode')) {
      final u = config.platforms['leetcode']!;
      queue('leetcode', () => LeetCodeStatsService.fetch(u));
    }

    if ((requested == null || requested == 'github') &&
        config.platforms.containsKey('github') &&
        config.tokens.containsKey('github')) {
      final u = config.platforms['github']!;
      final t = config.tokens['github']!;
      queue('github', () => GitHubStatsService.fetch(u, t));
    }

    if ((requested == null || requested == 'gitlab') && config.platforms.containsKey('gitlab')) {
      final u = config.platforms['gitlab']!;
      final t = config.tokens['gitlab'];
      if (t != null && t.trim().isNotEmpty) {
        queue('gitlab', () => GitLabStatsService.fetch(u, token: t));
      } else {
        results['gitlab'] = 'GitLab token missing or empty';
      }
    }

    if ((requested == null || requested == 'atcoder') && config.platforms.containsKey('atcoder')) {
      final u = config.platforms['atcoder']!;
      queue('atcoder', () => AtCoderStatsService.fetch(u));
    }

    if ((requested == null || requested == 'codechef') && config.platforms.containsKey('codechef')) {
      final u = config.platforms['codechef']!;
      queue('codechef', () => CodeChefStatsService.fetch(u));
    }

    if ((requested == null || requested == 'cses') && config.platforms.containsKey('cses')) {
      final u = config.platforms['cses']!;
      queue('cses', () => CsesStatsService.fetch(u));
    }

    if (config.platforms.containsKey('gfg')) {
      final u = config.platforms['gfg']!;
      queue('gfg', () => GfgStatsService.fetch(u));
    }

    // ── Fetch with spinner ────────────────────────────────
    if (futures.isNotEmpty) {
      await _withSpinner('Fetching your stats...', () async {
        await Future.wait(futures);
      });
    } else {
      print(chalk.yellow(_center('No platforms configured or requested')));
      return;
    }

    // ── Calculate DSA/CP Stats (exclude GitHub/GitLab) ────────────────────────────────
    int cpProblemsSolved = 0;
    int cpSubmissions = 0;
    int cpContests = 0;

    // ── Calculate Development Stats (only GitHub + GitLab) ────────────────────────────────
    int devContributions = 0;
    int devIssues = 0;
    int devPRs = 0;

    for (final entry in results.entries) {
      final platform = entry.key.toLowerCase();
      final value = entry.value;

      if (value is PlatformStats) {
        final data = value.data;

        final isDevPlatform = platform == 'github' || platform == 'gitlab';
        final isCPPlatform = !isDevPlatform;

        if (isCPPlatform) {
          // Problems Solved
          if (data.containsKey('Problems Solved')) {
            cpProblemsSolved += (data['Problems Solved'] as num?)?.toInt() ?? 0;
          }

          // Submissions
          if (data.containsKey('Submissions')) {
            cpSubmissions += (data['Submissions'] as num?)?.toInt() ?? 0;
          }

          // Contests
          if (data.containsKey('Total Contests')) {
            cpContests += (data['Total Contests'] as num?)?.toInt() ?? 0;
          } else if (data.containsKey('Contests')) {
            cpContests += (data['Contests'] as num?)?.toInt() ?? 0;
          }
        }

        if (isDevPlatform) {
          // GitHub nested maps
          if (platform == 'github') {
            // Lifetime Stats map
            if (data['Lifetime Stats'] is Map) {
              final lifetime = data['Lifetime Stats'] as Map;
              if (lifetime['Pull Requests'] != null) {
                devPRs += (lifetime['Pull Requests'] as num?)?.toInt() ?? 0;
              }
              if (lifetime['Issues Opened'] != null) {
                devIssues += (lifetime['Issues Opened'] as num?)?.toInt() ?? 0;
              }
            }

            // Last 1 Year Activity map
            if (data['Last 1 Year Activity'] is Map) {
              final yearly = data['Last 1 Year Activity'] as Map;
              if (yearly['Total Contributions'] != null) {
                devContributions += (yearly['Total Contributions'] as num?)?.toInt() ?? 0;
              }
            }
          }

          // GitLab top-level
          if (platform == 'gitlab') {
            if (data.containsKey('Events (Recent)')) {
              devContributions += (data['Events (Recent)'] as num?)?.toInt() ?? 0;
            }
          }
        }
      }
    }

    // ── Print the two-section summary ────────────────────────────────
    final w = _terminalWidth.clamp(60, 140);
    final boxWidth = w - 4;

    // DSA & CP Section
    print(chalk.bold.cyan('┌${'─' * boxWidth}┐'));
    print(chalk.bold.cyan('│ DSA & Competitive Programming Stats'.padRight(boxWidth - 1) + '│'));
    print(chalk.cyan('├${'─' * boxWidth}┤'));
    print(chalk.cyan('│ Total Problems Solved   : $cpProblemsSolved'.padRight(boxWidth - 1) + '│'));
    print(chalk.cyan('│ Total Submissions       : $cpSubmissions'.padRight(boxWidth - 1) + '│'));
    print(chalk.cyan('│ Total Contests          : $cpContests'.padRight(boxWidth - 1) + '│'));
    print(chalk.cyan('└${'─' * boxWidth}┘'));
    print('');

    // Development Section
    print(chalk.bold.magenta('┌${'─' * boxWidth}┐'));
    print(chalk.bold.magenta('│ Open Source & Development Stats'.padRight(boxWidth - 1) + '│'));
    print(chalk.magenta('├${'─' * boxWidth}┤'));
    print(chalk.magenta('│ Total Contributions     : $devContributions'.padRight(boxWidth - 1) + '│'));
    print(chalk.magenta('│ Total Issues Opened     : $devIssues'.padRight(boxWidth - 1) + '│'));
    print(chalk.magenta('│ Total Pull Requests     : $devPRs'.padRight(boxWidth - 1) + '│'));
    print(chalk.magenta('└${'─' * boxWidth}┘'));
    print('');
  }
}
