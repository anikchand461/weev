import 'dart:io';

class StorageService {
  static Future<void> ensureDir(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }
}

