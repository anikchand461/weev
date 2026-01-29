import '../../models/platform_stats.dart';
import 'leetcode_api.dart';

class LeetCodeStatsService {
  static Future<PlatformStats> fetch(String username) async {
    // -------------------------------
    // Solved + difficulty
    // -------------------------------
    final solved = await LeetCodeApi.fetchSolved(username);

    // -------------------------------
    // Calendar → active days
    // -------------------------------
    final calendar = await LeetCodeApi.fetchCalendar(username);
    final activeDays = calendar.length;

    // -------------------------------
    // Profile + contest stats
    // -------------------------------
    const profileQuery = r'''
      query getUserProfile($username: String!) {
        matchedUser(username: $username) {
          submitStatsGlobal {
            totalSubmissionNum {
              difficulty
              count
            }
          }
        }
        userContestRanking(username: $username) {
          rating
          attendedContestsCount
        }
        userContestRankingHistory(username: $username) {
          rating
        }
      }
    ''';

    /// 🔥 FIX IS HERE — USE postRaw(), NOT _post()
    final data = await LeetCodeApi.postRaw(
      profileQuery,
      {'username': username},
    );

    final matchedUser = data['data']?['matchedUser'];
    final contest = data['data']?['userContestRanking'];
    final history = data['data']?['userContestRankingHistory'];

    // -------------------------------
    // Total submissions
    // -------------------------------
    int totalSubmissions = 0;
    final totalSubsList =
        matchedUser?['submitStatsGlobal']?['totalSubmissionNum'];

    if (totalSubsList is List) {
      for (final e in totalSubsList) {
        if (e['difficulty'] == 'All') {
          totalSubmissions = e['count'] ?? 0;
        }
      }
    }

    // -------------------------------
    // Contest stats
    // -------------------------------
    final int totalContests =
        contest?['attendedContestsCount'] ?? 0;

    final double? currentRating =
        (contest?['rating'] as num?)?.toDouble();

    double? maxRating;
    if (history is List && history.isNotEmpty) {
      maxRating = history
          .map<double>((e) => (e['rating'] as num?)?.toDouble() ?? 0)
          .reduce((a, b) => a > b ? a : b);
    }

    // -------------------------------
    // Return stats
    // -------------------------------
    return PlatformStats(
      platform: 'leetcode',
      data: {
        'Problems Solved': solved['All'] ?? 0,
        'Submissions': totalSubmissions,
        'Active Days': activeDays,
        'Current Rating': currentRating?.toInt(),
        'Highest Rating': maxRating?.toInt(),
        'Total Contests': totalContests,
        'Difficulty': {
          'Easy': solved['Easy'] ?? 0,
          'Medium': solved['Medium'] ?? 0,
          'Hard': solved['Hard'] ?? 0,
        },
      },
    );
  }
}

