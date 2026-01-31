import 'package:args/args.dart';

import 'commands/init.dart';
import 'commands/stats.dart';
import 'commands/platforms.dart';
import 'commands/reset.dart';
import 'commands/sync.dart';
import 'commands/summary.dart';

class WeevCLI {
  static Future<void> run(List<String> args) async {  // ← Changed to async Future<void>
    final parser = ArgParser();
    parser.addCommand('init');
    parser.addCommand('stats');
    parser.addCommand('platforms');
    parser.addCommand('reset');
    parser.addCommand('sync');
    parser.addCommand('summary');

    final result = parser.parse(args);
    final commandName = result.command?.name?.toLowerCase();

    switch (commandName) {
      case 'init':
        InitCommand.run();
        break;
      case 'stats':
        await StatsCommand.run(result.command?.arguments ?? []);
        break;
      case 'platforms':
        PlatformsCommand.run();
        break;
      case 'reset':
        ResetCommand.run();
        break;
      case 'sync':
        await SyncCommand.run();
        break;
      case 'summary':
        await SummaryCommand.run(result.command?.arguments ?? []);
        break;
      default:
        _help();
    }
  }

  static void _help() {
    print('''
Weev — Weaving your coding journey
Commands:
  weev init       One-time setup
  weev stats      Show detailed stats for each platform
  weev summary    Overall summary of all platforms
  weev platforms  Manage platforms
  weev sync       Fetch real-time data
  weev reset      Reset configuration
''');
  }
}
