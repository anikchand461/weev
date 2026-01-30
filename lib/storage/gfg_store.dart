import 'dart:convert';
import 'dart:io';
import 'paths.dart';

class GfgStore {
  static File get _file {
    final dir = Directory('${WeevPaths.baseDir}/data');
    if (!dir.existsSync()) {
      dir.createSync(recursive: true);
    }
    return File('${dir.path}/gfg.json');
  }

  static Future<void> save(Map<String, dynamic> data) async {
    await _file.writeAsString(jsonEncode(data));
  }

  static Future<Map<String, dynamic>?> load() async {
    if (!await _file.exists()) return null;
    return jsonDecode(await _file.readAsString());
  }
}