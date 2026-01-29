import '../platforms/codeforces/codeforces_adapter.dart';
import '../platforms/leetcode/leetcode_adapter.dart';
import '../platforms/github/github_adapter.dart';
import '../platforms/gitlab/gitlab_adapter.dart';
import '../platforms/codechef/codechef_adapter.dart';

class PlatformRegistry {
  /// Platforms shown in `weev init`
  static const List<String> supportedPlatforms = [
    'codeforces',
    'leetcode',
    'github',
    'gitlab',
    'atcoder',
    'codechef', // ✅ ADD THIS
    'cses',
  ];

  /// Platforms that have activity adapters
  static final adapters = {
  'codeforces': CodeforcesAdapter(),
  'leetcode': LeetCodeAdapter(),
  'github': GitHubAdapter(),
  'gitlab': GitLabAdapter(),
  'codechef': CodeChefAdapter(), // ✅ ADD THIS
};
}
