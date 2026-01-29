import '../../models/activity.dart';

abstract class PlatformAdapter {
  String get name;

  /// Fetch unified activity data for the user
  Future<List<Activity>> fetchActivity(String username);
}

