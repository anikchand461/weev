import 'dart:io';

class Prompt {
  static String ask(String message) {
    stdout.write('$message: ');
    return stdin.readLineSync() ?? '';
  }
}

