import '../../models/platform_stats.dart';
import '../../storage/gfg_store.dart';

class GfgStatsService {
  static Future<PlatformStats?> fetch(String username) async {
    final data = await GfgStore.load();
    if (data == null) return null;

    return PlatformStats(
      platform: 'gfg',
      data: {
        'Problems Solved': data['problemsSolved'],
        'Coding Score': data['codingScore'],
      },
    );
  }
}