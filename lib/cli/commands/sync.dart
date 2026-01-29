import '../../services/sync_service.dart';

class SyncCommand {
  static Future<void> run() async {
    print('Syncing data...');
    await SyncService.syncAll();
    print('Sync complete ✅');
  }
}

