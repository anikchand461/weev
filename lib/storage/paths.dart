import 'dart:io';

class WeevPaths {
  static String get configFile {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE']!;
    return '$home/.weev/config.json';
  }
}

