import 'dart:convert';
import 'package:http/http.dart' as http;

class Code360Api {
  static const String _baseUrl = 'https://www.codingninjas.com/api/v3';

  /// Fetch user profile stats
  static Future<Map<String, dynamic>> fetchProfile(String username) async {
    final url = Uri.parse(
      '$_baseUrl/public_profile/$username',
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch Code360 profile');
    }

    return json.decode(res.body)['data'];
  }

  /// Fetch submission list
  static Future<List<dynamic>> fetchSubmissions(String username) async {
    final url = Uri.parse(
      '$_baseUrl/public_profile/$username/submissions',
    );

    final res = await http.get(url);

    if (res.statusCode != 200) {
      throw Exception('Failed to fetch Code360 submissions');
    }

    return json.decode(res.body)['data']['submissions'];
  }
}

