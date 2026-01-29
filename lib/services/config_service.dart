import 'dart:convert';
import 'dart:io';
import '../models/user_profile.dart';
import '../storage/paths.dart';

class ConfigService {
  static Future<UserProfile> load() async {
    final file = File(WeevPaths.configFile);
    if (!await file.exists()) return UserProfile.empty();

    final json = jsonDecode(await file.readAsString());
    return UserProfile.fromJson(json);
  }

  static Future<void> save(UserProfile profile) async {
    final file = File(WeevPaths.configFile);
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(profile.toJson()));
  }

  static Future<void> reset() async {
    final file = File(WeevPaths.configFile);
    if (await file.exists()) await file.delete();
  }
}

