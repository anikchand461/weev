import 'dart:convert';
import 'dart:io';
import 'dart:async';

class HeadlessRunner {
  static Future<Map<String, dynamic>> run({
    required String script,
    required String username,
    Duration timeout = const Duration(seconds: 30),
  }) async {
    final scriptPath = _resolveHeadlessScriptPath(script);

    final process = await Process.start(
      'node',
      [scriptPath, username],
    );

    final stdoutBuffer = StringBuffer();
    final stderrBuffer = StringBuffer();

    process.stdout.transform(utf8.decoder).listen(stdoutBuffer.write);
    process.stderr.transform(utf8.decoder).listen(stderrBuffer.write);

    try {
      final exitCode = await process.exitCode.timeout(timeout);

      if (exitCode != 0) {
        throw Exception(
          'Node process failed: ${stderrBuffer.toString().trim()}',
        );
      }
    } on TimeoutException {
      process.kill(ProcessSignal.sigkill);
      throw Exception('Headless process timed out');
    }

    final output = stdoutBuffer.toString().trim();

    if (output.isEmpty) {
      throw Exception('Empty output from headless script');
    }

    final decoded = jsonDecode(output);

    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid JSON from headless script');
    }

    return decoded;
  }

  static String _resolveHeadlessScriptPath(String script) {
    final scriptUri = Platform.script;
    final weevRoot = File(scriptUri.toFilePath()).parent.parent;
    return '${weevRoot.path}/headless/$script';
  }
}