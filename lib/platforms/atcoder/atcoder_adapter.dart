import '../base/platform_adapter.dart';
import '../../models/activity.dart';

class AtCoderAdapter extends PlatformAdapter {
  @override
  String get name => 'atcoder';

  @override
  Future<List<Activity>> fetchActivity(String username) async {
    // Scraping / unofficial API later
    return [];
  }
}

