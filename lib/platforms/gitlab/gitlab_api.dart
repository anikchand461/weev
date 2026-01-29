import 'dart:convert';
import 'package:http/http.dart' as http;

class GitLabApi {
  static const String _baseUrl = 'https://gitlab.com/api/v4';

  static Future<int> getUserId(
    String username, {
    String? token,
  }) async {
    final url = Uri.parse('$_baseUrl/users?username=$username');
    final response = await http.get(
      url,
      headers: _headers(token),
    );

    if (response.statusCode != 200) {
      throw Exception('GitLab API error ${response.statusCode}');
    }

    final data = jsonDecode(response.body);
    if (data is! List || data.isEmpty) {
      throw Exception('GitLab user not found');
    }

    final user = data.first as Map<String, dynamic>;
    return user['id'] as int;
  }

  static Future<List<Map<String, dynamic>>> fetchEvents(
    int userId, {
    String? token,
    int perPage = 100,
    int maxPages = 5,
  }) async {
    final events = <Map<String, dynamic>>[];

    for (var page = 1; page <= maxPages; page++) {
      final url = Uri.parse(
        '$_baseUrl/users/$userId/events?per_page=$perPage&page=$page',
      );

      final response = await http.get(
        url,
        headers: _headers(token),
      );
      if (response.statusCode != 200) {
        throw Exception('GitLab API error ${response.statusCode}');
      }

      final data = jsonDecode(response.body);
      if (data is! List || data.isEmpty) break;

      for (final item in data) {
        if (item is Map<String, dynamic>) {
          events.add(item);
        }
      }
    }

    return events;
  }

  static Map<String, String> _headers(String? token) {
    if (token == null || token.isEmpty) return {};
    return {
      'PRIVATE-TOKEN': token,
    };
  }
}
