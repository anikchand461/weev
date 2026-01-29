import 'dart:convert';
import 'dart:io';

class FileStore {
  static Future<void> writeJson(
      String path, Map<String, dynamic> data) async {
    final file = File(path);
    await file.create(recursive: true);
    await file.writeAsString(jsonEncode(data));
  }

  static Future<Map<String, dynamic>> readJson(String path) async {
    final file = File(path);
    if (!await file.exists()) return {};
    return jsonDecode(await file.readAsString());
  }
}

