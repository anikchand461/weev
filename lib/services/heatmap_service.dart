import '../models/activity.dart';

class HeatmapService {
  static Map<DateTime, int> build(List<Activity> activities) {
    final map = <DateTime, int>{};

    for (final activity in activities) {
      map.update(
        activity.date,
        (v) => v + activity.count,
        ifAbsent: () => activity.count,
      );
    }

    return map;
  }
}

