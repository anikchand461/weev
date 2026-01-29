import 'package:args/args.dart';

import 'commands/init.dart';
import 'commands/stats.dart';
import 'commands/platforms.dart';
import 'commands/reset.dart';
import 'commands/sync.dart';

class WeevCLI {
  static void run(List<String> args) {
    final parser = ArgParser();

    parser.addCommand('init');
    parser.addCommand('stats');
    parser.addCommand('platforms');
    parser.addCommand('reset');
    parser.addCommand('sync'); // 👈 ADD THIS

    final result = parser.parse(args);

    switch (result.command?.name) {
      case 'init':
        InitCommand.run();
        break;
      case 'stats':
        StatsCommand.run();
        break;
      case 'platforms':
        PlatformsCommand.run();
        break;
      case 'reset':
        ResetCommand.run();
        break;
      case 'sync': // 👈 ADD THIS
        SyncCommand.run();
        break;
      default:
        _help();
    }
  }

  static void _help() {
    print('''
Weev — Weaving your coding journey

Commands:
  weev init        One-time setup
  weev stats       Show stats
  weev platforms   Manage platforms
  weev sync        Fetch real-time data
  weev reset       Reset configuration
''');
  }
}

