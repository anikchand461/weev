import '../base/platform_adapter.dart';
import '../../models/activity.dart';
import 'leetcode_api.dart';

class LeetCodeAdapter extends PlatformAdapter {
  @override
  String get name => 'leetcode';

  @override
  Future<List<Activity>> fetchActivity(String username) async {
    final calendar =
        await LeetCodeApi.fetchCalendar(username);

    return calendar.entries
        .map(
          (e) => Activity(
            DateTime(e.key.year, e.key.month, e.key.day),
            'leetcode',
            e.value,
          ),
        )
        .toList();
  }
}

