import '../../services/config_service.dart';

class ConfigCommand {
  static Future<void> run() async {
    final config = await ConfigService.load();
    print(config.toJson());
  }
}

