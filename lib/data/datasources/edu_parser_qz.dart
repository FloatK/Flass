import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import 'edu_parser.dart';

/// Parser for 强智教务系统 schedule tables.
///
/// Table has id="kbtable". Each cell contains div.kbcontent with:
///   code<br>name<br><font title="老师">teacher</font><br>
///   <font title="周次(节次)">weeks(周)[periods节]</font><br>
///   [<font title="教室">location</font><br>]
/// Multiple courses in one cell are separated by "---------------------"
class QiangZhiEduParser extends EduParser {
  const QiangZhiEduParser();

  @override
  String get systemName => '强智教务系统';

  @override
  List<ParsedCourse> parse(String html) {
    final document = html_parser.parse(html);
    final courses = <ParsedCourse>[];

    final table = document.querySelector('#kbtable');
    if (table == null) return courses;

    final tbody = table.querySelector('tbody') ?? table;
    final rows = tbody.querySelectorAll('tr');
    if (rows.length < 2) return courses;

    // Skip header row (index 0). Each subsequent row is one "大节" block.
    // Row 1 = 第一大节 → periods roughly (rowIdx-1)*2+1 to (rowIdx-1)*2+2
    for (int rowIdx = 1; rowIdx < rows.length; rowIdx++) {
      final cells = rows[rowIdx].querySelectorAll('td, th');

      for (int colIdx = 0; colIdx < cells.length; colIdx++) {
        // Skip first column (period label th)
        if (colIdx == 0) continue;

        final cell = cells[colIdx];
        // Only match visible kbcontent, skip hidden kbcontent1
        final divs = cell.querySelectorAll('.kbcontent');

        for (final div in divs) {
          final parsed = _parseCell(div, colIdx - 1, rowIdx - 1);
          courses.addAll(parsed);
        }
      }
    }

    return courses;
  }

  List<ParsedCourse> _parseCell(dom.Element div, int dayIndex, int periodBlock) {
    final results = <ParsedCourse>[];

    // Split by multi-course separator
    final blocks = div.innerHtml.split('---------------------');
    for (final block in blocks) {
      final trimmed = block.trim();
      if (trimmed.isEmpty || trimmed == '<br>') continue;

      final course = _parseSingleBlock(trimmed, dayIndex, periodBlock);
      if (course != null) results.add(course);
    }

    return results;
  }

  ParsedCourse? _parseSingleBlock(String html, int dayIndex, int periodBlock) {
    // Split by <br> and strip tags for text content
    final lines = html
        .split(RegExp(r'<br\s*/?>', caseSensitive: false))
        .map((line) => line
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return null;

    // Parse with tag-aware approach for key fields
    final doc = html_parser.parseFragment(html);

    // Extract teacher, weeks/periods, location from font tags
    String teacher = '';
    String weeksStr = '';
    String location = '';

    final fonts = doc.querySelectorAll('font');
    for (final font in fonts) {
      final title = font.attributes['title'] ?? '';
      final text = font.text.trim();
      if (title == '老师') {
        teacher = text;
      } else if (title.contains('周次')) {
        weeksStr = text;
      } else if (title == '教室') {
        location = text;
      }
    }

    // Course name is the first non-code, non-empty line after stripping tags
    String name = '';
    for (int i = 0; i < lines.length; i++) {
      final line = lines[i];
      // Skip lines that look like course codes (e.g., "002976-080345D")
      if (_isCourseCode(line)) continue;
      name = line;
      break;
    }

    if (name.isEmpty) return null;

    // Parse weeks and periods
    int startPeriod = 1;
    int duration = 2;
    List<int> weeks = [];
    String singleOrDouble = 'all';

    if (weeksStr.isNotEmpty) {
      weeks = _parseWeeks(weeksStr);
      singleOrDouble = _parseSingleOrDouble(weeksStr);
      // Try to extract periods from [XX-YY节] or [XX节]
      final periodMatch =
          RegExp(r'\[(\d+)(?:-(\d+))?节\]').firstMatch(weeksStr);
      if (periodMatch != null) {
        startPeriod = int.tryParse(periodMatch.group(1)!) ?? 1;
        final end = int.tryParse(periodMatch.group(2) ?? '') ?? startPeriod;
        duration = end - startPeriod + 1;
      } else {
        // Fallback: use period block position (each block = 2 periods)
        startPeriod = periodBlock * 2 + 1;
        duration = 2;
      }
    } else {
      // No weeks info — use period block position
      startPeriod = periodBlock * 2 + 1;
      duration = 2;
    }

    return ParsedCourse(
      name: name,
      teacher: teacher,
      location: location,
      timeDetails: [
        ParsedTimeDetail(
          dayOfWeek: dayIndex + 1,
          startPeriod: startPeriod,
          duration: duration,
          weeks: weeks,
          singleOrDouble: singleOrDouble,
        ),
      ],
    );
  }

  bool _isCourseCode(String text) {
    // Course codes look like "002976-080345D" or "C12345"
    return RegExp(r'^[A-Za-z0-9]{2,}-[A-Za-z0-9]{2,}$').hasMatch(text) ||
        RegExp(r'^[A-Z]\d{5,}$').hasMatch(text);
  }

  static List<int> _parseWeeks(String weeksStr) {
    final numbers = <int>{};

    // Extract only the weeks portion: everything before '(' or '['
    final match = RegExp(r'^([^(\[]+)').firstMatch(weeksStr);
    final weeksOnly =
        (match?.group(1) ?? weeksStr).replaceAll(RegExp(r'[周单双全\s]'), '');

    if (weeksOnly.isEmpty) return [];

    final parts = weeksOnly.split(',').map((s) => s.trim());
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

  static String _parseSingleOrDouble(String weeksStr) {
    if (weeksStr.contains('单')) return 'single';
    if (weeksStr.contains('双')) return 'double';
    return 'all';
  }
}
