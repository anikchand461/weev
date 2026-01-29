import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubApi {
  static Future<Map<String, dynamic>> getUser(String username) async {
    final response = await http.get(
      Uri.parse('https://api.github.com/users/$username'),
    );

    if (response.statusCode != 200) {
      throw Exception('GitHub user not found');
    }

    return jsonDecode(response.body);
  }
}

