import '../services/config_service.dart';
import '../platforms/codeforces/codeforces_adapter.dart';

class SyncService {
  static Future<void> syncAll() async {
    final config = await ConfigService.load();

    if (!config.platforms.containsKey('codeforces')) {
      print('Codeforces not configured — skipping');
      return;
    }

    final username = config.platforms['codeforces']!;
    final adapter = CodeforcesAdapter();

    print('Fetching Codeforces data for $username...');

    final activities =
        await adapter.fetchActivity(username);

    print(
      'Fetched ${activities.length} days of activity from Codeforces',
    );

    // NEXT STEP:
    // Save activities to cache / DB
  }
}

