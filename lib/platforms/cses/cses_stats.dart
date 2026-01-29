import 'package:http/http.dart' as http;
import 'package:html/parser.dart';
import '../../models/platform_stats.dart';

class CsesStatsService {
  static Future<PlatformStats> fetch(String userId) async {
    final url = Uri.parse(
      'https://cses.fi/user/$userId',
    );

    final res = await http.get(
      url,
      headers: {
        'User-Agent': 'Mozilla/5.0',
      },
    );

    if (res.statusCode != 200) {
      throw Exception('CSES user not found');
    }

    final document = parse(res.body);

    int submissions = 0;

    for (final row in document.querySelectorAll('tr')) {
      final cells = row.querySelectorAll('td');
      if (cells.length == 2 &&
          cells[0].text.trim() == 'Submission count:') {
        submissions =
            int.tryParse(cells[1].text.trim()) ?? 0;
        break;
      }
    }


    const totalProblems = 400;

    return PlatformStats(
      platform: 'cses',
      data: {
        'Submissions': submissions,
        'Note': 'CSES does not expose solved-problem count',
      },
    );

  }
}

