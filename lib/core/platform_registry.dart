import '../platforms/codeforces/codeforces_adapter.dart';
import '../platforms/leetcode/leetcode_adapter.dart';

class PlatformRegistry {
  static final adapters = {
    'codeforces': CodeforcesAdapter(),
    'leetcode': LeetCodeAdapter(),
  };
}

