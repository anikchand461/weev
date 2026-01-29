import 'dart:math';

class HeatmapRenderer {
  static void render(Map<String, int> data) {
    final entries = data.entries
        .map((e) => MapEntry(DateTime.parse(e.key), e.value))
        .toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    String symbol(int count) {
      if (count == 0) return ' ';
      if (count <= 3) return '░';
      if (count <= 7) return '▒';
      if (count <= 15) return '▓';
      return '█';
    }

    print('\n   Mon Tue Wed Thu Fri Sat Sun');

    DateTime? weekStart;
    final week = List.filled(7, ' ');

    for (final entry in entries) {
      final d = entry.key;
      final idx = d.weekday - 1;

      week[idx] = symbol(entry.value);

      weekStart ??= d.subtract(Duration(days: idx));

      if (d.weekday == DateTime.sunday) {
        print(
          '${weekStart!.month.toString().padLeft(2, '0')}/'
          '${weekStart!.day.toString().padLeft(2, '0')} '
          '${week.join('   ')}',
        );
        week.fillRange(0, 7, ' ');
        weekStart = null;
      }
    }
  }
}

