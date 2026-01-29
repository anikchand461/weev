import 'dart:convert';
import 'package:http/http.dart' as http;

import '../../models/platform_stats.dart';
import 'github_graphql_api.dart';

class GitHubStatsService {
  static Future<PlatformStats> fetch(
    String username,
    String token,
  ) async {
    // ===============================
    // 1️⃣ GraphQL: Last 1 year activity
    // ===============================
    const graphQuery = r'''
      query ($login: String!) {
        user(login: $login) {
          createdAt
          contributionsCollection {
            contributionCalendar {
              totalContributions
              weeks {
                contributionDays {
                  date
                  contributionCount
                }
              }
            }
          }
        }
      }
    ''';

    final graphData = await GitHubGraphQLApi.query(
      token,
      graphQuery,
      {'login': username},
    );

    final user = graphData['user'];
    final calendar =
        user['contributionsCollection']['contributionCalendar'];

    final int totalContributions =
        calendar['totalContributions'];

    int activeDays = 0;
    for (final week in calendar['weeks']) {
      for (final day in week['contributionDays']) {
        if (day['contributionCount'] > 0) {
          activeDays++;
        }
      }
    }

    // ===============================
    // 2️⃣ REST API: Lifetime PRs & Issues
    // ===============================
    Future<int> searchCount(String q) async {
      final res = await http.get(
        Uri.parse(
          'https://api.github.com/search/issues?q=$q',
        ),
        headers: {
          'Authorization': 'Bearer $token',
          'Accept': 'application/vnd.github+json',
        },
      );
      return jsonDecode(res.body)['total_count'];
    }

    final pullRequests =
        await searchCount('type:pr author:$username');
    final issues =
        await searchCount('type:issue author:$username');

    // ===============================
    // 3️⃣ REST API: Lifetime Stars
    // ===============================
    final reposRes = await http.get(
      Uri.parse(
        'https://api.github.com/users/$username/repos?per_page=100',
      ),
      headers: {
        'Authorization': 'Bearer $token',
        'Accept': 'application/vnd.github+json',
      },
    );

    final repos = jsonDecode(reposRes.body) as List;
    final stars = repos.fold<int>(
      0,
      (sum, r) => sum + (r['stargazers_count'] as int),
    );

    // ===============================
    // ✅ FINAL CLEAN OUTPUT (Codolio-style)
    // ===============================
    return PlatformStats(
      platform: 'github',
      data: {
        'Member Since': user['createdAt'].substring(0, 10),

        'Lifetime Stats': {
          'Stars': stars,
          'Pull Requests': pullRequests,
          'Issues Opened': issues,
        },

        'Last 1 Year Activity': {
          'Active Days': activeDays,
          'Total Contributions': totalContributions,
        },
      },
    );
  }
}
