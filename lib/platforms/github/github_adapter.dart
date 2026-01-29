import '../base/platform_adapter.dart';
import '../../models/activity.dart';

class GitHubAdapter extends PlatformAdapter {
  @override
  String get name => 'github';

  @override
  Future<List<Activity>> fetchActivity(String username) async {
    // For now stats are handled separately
    return [];
  }
}

