import 'dart:convert';
import 'package:http/http.dart' as http;

class GitHubGraphQLApi {
  static const _endpoint = 'https://api.github.com/graphql';

  static Future<Map<String, dynamic>> query(
    String token,
    String query,
    Map<String, dynamic> variables,
  ) async {
    final res = await http.post(
      Uri.parse(_endpoint),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'query': query,
        'variables': variables,
      }),
    );

    final data = jsonDecode(res.body);

    if (data['errors'] != null) {
      throw Exception(data['errors']);
    }

    return data['data'];
  }
}

