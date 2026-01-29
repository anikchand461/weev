import 'dart:convert';
import 'package:http/http.dart' as http;

class LeetCodeApi {
  static const String _url = 'https://leetcode.com/graphql';

  /// Internal HTTP helper (private)
  static Future<Map<String, dynamic>> _post(
    String query,
    Map<String, dynamic> variables,
  ) async {
    final response = await http.post(
      Uri.parse(_url),
      headers: const {
        'Content-Type': 'application/json',
        'Referer': 'https://leetcode.com',
      },
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception(
        'LeetCode API error ${response.statusCode}: ${response.body}',
      );
    }

    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Invalid LeetCode API response');
    }

    return decoded;
  }

  /// ✅ PUBLIC raw GraphQL access (used by stats service)
  static Future<Map<String, dynamic>> postRaw(
    String query,
    Map<String, dynamic> variables,
  ) {
    return _post(query, variables);
  }

  /// ✅ Total solved + difficulty breakdown
  static Future<Map<String, int>> fetchSolved(String username) async {
    const query = r'''
      query getUserProfile($username: String!) {
        matchedUser(username: $username) {
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

    final list = data['data']?['matchedUser']?['submitStats']
        ?['acSubmissionNum'] as List?;

    if (list == null) return {};

    return {
      for (final d in list)
        d['difficulty'] as String: d['count'] as int,
    };
  }

  /// ✅ Daily activity calendar (used for Active Days)
  static Future<Map<DateTime, int>> fetchCalendar(String username) async {
    const query = r'''
      query submissionCalendar($username: String!) {
        matchedUser(username: $username) {
          submissionCalendar
        }
      }
    ''';

    final data = await _post(query, {'username': username});

    final rawCalendar =
        data['data']?['matchedUser']?['submissionCalendar'];

    if (rawCalendar == null || rawCalendar is! String) {
      return {};
    }

    final decoded = jsonDecode(rawCalendar) as Map<String, dynamic>;

    return decoded.map<DateTime, int>((k, v) {
      final date = DateTime.fromMillisecondsSinceEpoch(
        int.parse(k) * 1000,
      );
      return MapEntry(
        DateTime(date.year, date.month, date.day),
        v as int,
      );
    });
  }
}

