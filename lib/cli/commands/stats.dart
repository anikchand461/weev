import '../../services/config_service.dart';
import '../../platforms/codeforces/codeforces_api.dart';

class StatsCommand {
  static Future<void> run() async {
    final config = await ConfigService.load();

    if (!config.platforms.containsKey('codeforces')) {
      print('Codeforces not configured. Run `weev init` first.');
      return;
    }

    final handle = config.platforms['codeforces']!;
    print('Fetching Codeforces stats for $handle...\n');

    final submissions =
        await CodeforcesApi.fetchSubmissions(handle);
    final contests =
        await CodeforcesApi.fetchContests(handle);

    final solved = <String>{};
    final difficulty = <int, int>{};

    for (final s in submissions) {
      if (s['verdict'] != 'OK') continue;

      final p = s['problem'];
      solved.add('${p['contestId']}${p['index']}');

      if (p['rating'] != null) {
        difficulty.update(
          p['rating'],
          (v) => v + 1,
          ifAbsent: () => 1,
        );
      }
    }

    final currentRating =
        contests.isEmpty ? 0 : contests.last['newRating'];

    final maxRating = contests.isEmpty
        ? 0
        : contests
            .map<int>((c) => c['newRating'])
            .reduce((a, b) => a > b ? a : b);

    print('📊 Codeforces Stats');
    print('----------------------');
    print('Handle          : $handle');
    print('Problems Solved : ${solved.length}');
    print('Submissions     : ${submissions.length}');
    print('Contests        : ${contests.length}');
    print('Current Rating  : $currentRating');
    print('Max Rating      : $maxRating');

    if (difficulty.isNotEmpty) {
      print('\n📈 Difficulty Breakdown');
      difficulty.keys.toList()
        ..sort()
        ..forEach((k) {
          print('$k : ${difficulty[k]}');
        });
    }
  }
}

