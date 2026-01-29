import '../../services/config_service.dart';

class PlatformsCommand {
  static Future<void> run() async {
    final config = await ConfigService.load();

    print('Current platforms:\n');
    config.platforms.forEach((k, v) {
      print('- $k: $v');
    });
  }
}

