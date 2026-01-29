import 'dart:convert';
import 'package:http/http.dart' as http;

class CodeforcesApi {
  static const String _baseUrl = 'https://codeforces.com/api';

  static Future<List<dynamic>> fetchSubmissions(String handle) async {
    final url = Uri.parse('$_baseUrl/user.status?handle=$handle');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['status'] != 'OK') {
      throw Exception(data['comment'] ?? 'Codeforces API error');
    }

    return data['result'];
  }

  static Future<List<dynamic>> fetchContests(String handle) async {
    final url = Uri.parse('$_baseUrl/user.rating?handle=$handle');

    final response = await http.get(url);
    final data = jsonDecode(response.body);

    if (data['status'] != 'OK') {
      throw Exception(data['comment'] ?? 'Codeforces API error');
    }

    return data['result'];
  }
}

