import '../../services/config_service.dart';
import '../../utils/prompt.dart';
import '../../core/platform_registry.dart';

class InitCommand {
  static Future<void> run() async {
    final config = await ConfigService.load();

    print('Initializing Weev...\n');

    for (final platform in PlatformRegistry.adapters.keys) {
      final username =
          Prompt.ask('Enter username for $platform (leave empty to skip)');
      if (username.isNotEmpty) {
        config.platforms[platform] = username;
      }
    }

    await ConfigService.save(config);
    print('\nWeev setup complete ✅');
  }
}

