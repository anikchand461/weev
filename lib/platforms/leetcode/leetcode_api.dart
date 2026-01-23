import 'dart:convert';
import 'package:http/http.dart' as http;

class LeetCodeApi {
  static const _url = 'https://leetcode.com/graphql';

  static Future<Map<String, dynamic>> _post(
      String query, Map<String, dynamic> variables) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    return jsonDecode(response.body);
  }

  /// Total solved + difficulty breakdown
  static Future<Map<String, int>> fetchSolved(String username) async {
    const query = '''
      query getUserProfile(\$username: String!) {
        matchedUser(username: \$username) {
          submitStats {
            acSubmissionNum {
              difficulty
              count
            }
          }
        }
      }
    ''';

    final data = await _post(query, {'username': username});
    final list =
        data['data']['matchedUser']['submitStats']['acSubmissionNum'];

    return {
      for (final d in list)
        d['difficulty'] as String: d['count'] as int
    };
  }

  /// Daily activity (for heatmap / stats)
  static Future<Map<DateTime, int>> fetchCalendar(
      String username) async {
    const query = '''
      query submissionCalendar(\$username: String!) {
        matchedUser(username: \$username) {
          submissionCalendar
        }
      }
    ''';

    final data = await _post(query, {'username': username});

    // 🔥 IMPORTANT: this is a STRING, not a map
    final rawCalendar =
        data['data']['matchedUser']['submissionCalendar'];

    // Decode string → Map
    final decoded =
        jsonDecode(rawCalendar) as Map<String, dynamic>;

    return decoded.map<DateTime, int>((k, v) {
      final date = DateTime.fromMillisecondsSinceEpoch(
          int.parse(k) * 1000);

      return MapEntry(
        DateTime(date.year, date.month, date.day),
        v as int,
      );
    });
  }
}

