import '../../services/config_service.dart';
import '../../utils/prompt.dart';
import '../../core/platform_registry.dart';

class InitCommand {
  static Future<void> run() async {
    final config = await ConfigService.load();

    print('Initializing Weev...\n');

    for (final platform in PlatformRegistry.adapters.keys) {
      final username = Prompt.ask(
        'Enter username for $platform (leave empty to skip)',
      );

      if (username.isEmpty) continue;

      config.platforms[platform] = username;

      // 🔑 Ask token ONLY for GitHub
      if (platform == 'github') {
        final token = Prompt.ask(
          'Enter GitHub token (leave empty to skip)',
        );

        if (token.isNotEmpty) {
          config.tokens['github'] = token;
        }
      }

      if (platform == 'gitlab') {
        final token = Prompt.ask(
          'Enter GitLab token (leave empty to skip)',
        );

        if (token.isNotEmpty) {
          config.tokens['gitlab'] = token;
        }
      }
    }

    await ConfigService.save(config);
    print('\nWeev setup complete ✅');
  }
}

