import 'dart:io';

class WeevPaths {
  static String get baseDir {
    final home = Platform.environment['HOME'] ??
        Platform.environment['USERPROFILE']!;
    return '$home/.weev';
  }

  static String get configFile {
    return '$baseDir/config.json';
  }
}