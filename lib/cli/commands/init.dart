import '../../services/config_service.dart';
import '../../utils/prompt.dart';
import '../../core/platform_registry.dart';

class InitCommand {
  static Future<void> run() async {
    final config = await ConfigService.load();

    print('Initializing Weev...\n');

    // IMPORTANT: iterate supportedPlatforms, not adapters
    for (final platform in PlatformRegistry.supportedPlatforms) {
      final promptText = platform == 'cses'
          ? 'Enter CSES user ID (numeric, leave empty to skip)'
          : 'Enter username for $platform (leave empty to skip)';

      final username = Prompt.ask(promptText);

      if (username.trim().isEmpty) continue;

      config.platforms[platform] = username.trim();

      // 🔑 Tokens only where needed
      if (platform == 'github') {
        final token = Prompt.ask(
          'Enter GitHub token (leave empty to skip)',
        );

        if (token.trim().isNotEmpty) {
          config.tokens['github'] = token.trim();
        }
      }

      if (platform == 'gitlab') {
        final token = Prompt.ask(
          'Enter GitLab token (leave empty to skip)',
        );

        if (token.trim().isNotEmpty) {
          config.tokens['gitlab'] = token.trim();
        }
      }
    }

    await ConfigService.save(config);
    print('\nWeev setup complete ✅');
  }
}

