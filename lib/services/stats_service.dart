import '../models/activity.dart';
import '../models/stats.dart';

class StatsService {
  static Stats compute(List<Activity> activities) {
    final total =
        activities.fold<int>(0, (sum, a) => sum + a.count);

    return Stats(total);
  }
}

