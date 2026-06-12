/// 周次相关的解析与格式化工具。
class WeekUtils {
  WeekUtils._();

  /// 将逗号分隔的周次字符串解析为列表。
  /// 支持格式: "1,2,3,4,5" 或 "1-5,7,9-12"
  static List<int> parseWeeks(String weeksStr) {
    if (weeksStr.isEmpty) return [];
    final numbers = <int>{};
    final parts = weeksStr.split(',').map((s) => s.trim());
    for (final part in parts) {
      if (part.isEmpty) continue;
      if (part.contains('-')) {
        final range = part.split('-');
        final start = int.tryParse(range[0]);
        final end = int.tryParse(range[1]);
        if (start != null && end != null && start <= end) {
          for (int i = start; i <= end; i++) {
            numbers.add(i);
          }
        }
      } else {
        final n = int.tryParse(part);
        if (n != null) numbers.add(n);
      }
    }
    return numbers.toList()..sort();
  }

  /// 将周次列表格式化为可读字符串。
  /// 例: [1,2,3,5,7,8,9] → "第1-3, 5, 7-9周"
  ///
  /// [everyWeekLabel] 用于空列表时的显示，默认为 '每周'。
  static String formatWeeks(List<int> weeks, {String everyWeekLabel = '每周'}) {
    if (weeks.isEmpty) return everyWeekLabel;
    final sorted = List<int>.from(weeks)..sort();
    final ranges = <String>[];
    int start = sorted.first;
    int end = sorted.first;
    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == end + 1) {
        end = sorted[i];
      } else {
        ranges.add(start == end ? '$start' : '$start-$end');
        start = sorted[i];
        end = sorted[i];
      }
    }
    ranges.add(start == end ? '$start' : '$start-$end');
    return '第${ranges.join(', ')}周';
  }

  /// 从周次字符串中提取单双周标记。
  /// 返回 'single' / 'double' / 'all'
  static String parseSingleOrDouble(String weeksStr) {
    if (weeksStr.contains('单')) return 'single';
    if (weeksStr.contains('双')) return 'double';
    return 'all';
  }
}
