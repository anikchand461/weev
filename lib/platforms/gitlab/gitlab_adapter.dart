import '../base/platform_adapter.dart';
import '../../models/activity.dart';
import 'gitlab_api.dart';

class GitLabAdapter extends PlatformAdapter {
  @override
  String get name => 'gitlab';

  @override
  Future<List<Activity>> fetchActivity(String username) async {
    final userId = await GitLabApi.getUserId(username);
    final events = await GitLabApi.fetchEvents(userId);

    final Map<DateTime, int> daily = {};

    for (final event in events) {
      final createdAt = event['created_at'];
      if (createdAt is! String) continue;

      final date = DateTime.parse(createdAt).toLocal();
      final day = DateTime(date.year, date.month, date.day);

      daily.update(day, (v) => v + 1, ifAbsent: () => 1);
    }

    return daily.entries
        .map((e) => Activity(e.key, 'gitlab', e.value))
        .toList();
  }
}
