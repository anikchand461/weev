import '../../models/platform_stats.dart';
import 'gitlab_api.dart';

class GitLabStatsService {
  static Future<PlatformStats> fetch(
    String username, {
    String? token,
  }) async {
    final userId = await GitLabApi.getUserId(
      username,
      token: token,
    );

    final events = await GitLabApi.fetchEvents(
      userId,
      token: token,
    );

    final activeDays = <String>{};
    final actionCounts = <String, int>{};

    for (final event in events) {
      final createdAt = event['created_at'];
      if (createdAt is String) {
        final date = DateTime.parse(createdAt).toLocal();
        activeDays.add('${date.year}-${date.month}-${date.day}');
      }

      final action = (event['action_name'] as String?) ??
          (event['target_type'] as String?) ??
          'Unknown';
      actionCounts.update(action, (v) => v + 1, ifAbsent: () => 1);
    }

    return PlatformStats(
      platform: 'gitlab',
      data: {
        'Events (Recent)': events.length,
        'Active Days (Recent)': activeDays.length,
        'Activity Breakdown': actionCounts,
      },
    );
  }
}
