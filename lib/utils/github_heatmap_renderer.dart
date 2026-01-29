class GitHubHeatmapRenderer {
  static void render(Map<String, int> heatmap) {
    final entries = heatmap.entries
        .map((e) => MapEntry(DateTime.parse(e.key), e.value))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    String cell(int c) {
      if (c == 0) return ' ';
      if (c <= 2) return '░';
      if (c <= 5) return '▒';
      if (c <= 10) return '▓';
      return '█';
    }

    print('\n    Mon Tue Wed Thu Fri Sat Sun');

    DateTime? weekStart;
    final row = List.filled(7, ' ');

    for (final e in entries) {
      final d = e.key;
      final idx = d.weekday - 1;

      if (weekStart == null) {
        weekStart = d.subtract(Duration(days: idx));
      }

      row[idx] = cell(e.value);

      if (d.weekday == DateTime.sunday) {
        final label =
            '${weekStart!.month.toString().padLeft(2, '0')}/${weekStart!.day.toString().padLeft(2, '0')}';
        print('$label  ${row.join('   ')}');
        row.fillRange(0, 7, ' ');
        weekStart = null;
      }
    }
  }
}

