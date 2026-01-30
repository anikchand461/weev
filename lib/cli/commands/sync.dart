import '../../services/config_service.dart';
import '../../headless/headless_runner.dart';
import '../../storage/gfg_store.dart';

class SyncCommand {
  static Future<void> run() async {
    print('Syncing headless platforms...');

    final config = await ConfigService.load();

    // ─────────────────────────────
    // GFG Headless Sync
    // ─────────────────────────────
    if (config.platforms.containsKey('gfg')) {
      final username = config.platforms['gfg']!;

      print('🌐 Syncing GFG (headless)...');

      try {
        final result = await HeadlessRunner.run(
          script: 'gfg.js',
          username: username,
        );

        if (result['success'] == true) {
          final data = result['data'];

          await GfgStore.save(data);

          print('✅ GFG Sync Successful (saved)');
        } else {
          print('⚠️ GFG Sync Failed');
          print('Error: ${result['error']}');
        }
      } catch (e) {
        print('❌ GFG Headless Error');
        print(e.toString());
      }

      print('');
    } else {
      print('GFG not configured — skipping');
    }

    print('Sync complete ✅');
  }
}