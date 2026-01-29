import '../../services/config_service.dart';

class ResetCommand {
  static Future<void> run() async {
    await ConfigService.reset();
    print('Weev configuration reset 🧹');
  }
}

