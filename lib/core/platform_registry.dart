import '../platforms/codeforces/codeforces_adapter.dart';
import '../platforms/leetcode/leetcode_adapter.dart';
import '../platforms/github/github_adapter.dart';
import '../platforms/gitlab/gitlab_adapter.dart';

class PlatformRegistry {
  static final adapters = {
    'codeforces': CodeforcesAdapter(),
    'leetcode': LeetCodeAdapter(),
    'github': GitHubAdapter(),
    'gitlab': GitLabAdapter(),
  };
}

