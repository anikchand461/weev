import '../base/platform_adapter.dart';
import '../../models/activity.dart';
import 'codeforces_api.dart';

class CodeforcesAdapter extends PlatformAdapter {
  @override
  String get name => 'codeforces';

  @override
  Future<List<Activity>> fetchActivity(String username) async {
    final submissions =
        await CodeforcesApi.fetchSubmissions(username);

    final Map<DateTime, int> daily = {};

    for (final s in submissions) {
      if (s['verdict'] != 'OK') continue;

      final ts = s['creationTimeSeconds'] * 1000;
      final date =
          DateTime.fromMillisecondsSinceEpoch(ts);
      final day = DateTime(date.year, date.month, date.day);

      daily.update(day, (v) => v + 1, ifAbsent: () => 1);
    }

    return daily.entries
        .map((e) => Activity(e.key, 'codeforces', e.value))
        .toList();
  }
}

