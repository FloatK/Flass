import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import 'edu_parser.dart';

/// Parser for 强智教务系统 schedule tables.
///
/// The table typically has id="kbtable" and cells contain div.kbcontent
/// with course info separated by <br> tags:
///   Line 0: Course name
///   Line 1: Teacher name
///   Line 2: Location
///   Line 3: Weeks (e.g. "1-16周全周" or "1,3,5,7周单周")
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

    final rows = table.querySelectorAll('tr');
    if (rows.length < 2) return courses;

    final headerCells = rows.first.querySelectorAll('td, th');
    if (headerCells.isNotEmpty) {
      // Ensure we have expected columns
    }

    for (int rowIdx = 1; rowIdx < rows.length; rowIdx++) {
      final cells = rows[rowIdx].querySelectorAll('td, th');
      final actualCols = cells.length;

      for (int colIdx = 0; colIdx < actualCols; colIdx++) {
        // Skip the first column (period label, e.g. "第1节")
        if (colIdx == 0) continue;

        final cell = cells[colIdx];
        final courseDivs = cell.querySelectorAll('.kbcontent');

        for (final div in courseDivs) {
          final course = _parseCourseCell(div, colIdx - 1, rowIdx);
          if (course != null) {
            courses.add(course);
          }
        }
      }
    }

    return courses;
  }

  ParsedCourse? _parseCourseCell(
      dom.Element div, int dayIndex, int periodRow) {
    final html = div.innerHtml;
    final lines = html
        .split(RegExp(r'<br\s*/?>', caseSensitive: false))
        .map((line) => line
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty || lines.first.isEmpty) return null;

    final name = lines.isNotEmpty ? lines[0] : '';
    final teacher = lines.length > 1 ? lines[1] : '';
    final location = lines.length > 2 ? lines[2] : '';
    final weeksStr = lines.length > 3 ? lines[3] : '';

    final parsedWeeks = _parseWeeks(weeksStr);
    final singleOrDouble = _parseSingleOrDouble(weeksStr);

    return ParsedCourse(
      name: name,
      teacher: teacher,
      location: location,
      timeDetails: [
        ParsedTimeDetail(
          dayOfWeek: dayIndex + 1,
          startPeriod: periodRow + 1,
          duration: 1,
          weeks: parsedWeeks,
          singleOrDouble: singleOrDouble,
        ),
      ],
    );
  }

  static List<int> _parseWeeks(String weeksStr) {
    final numbers = <int>{};
    // Remove common suffixes and spaces
    final cleaned = weeksStr
        .replaceAll(RegExp(r'[周单双全\s]'), '')
        .replaceAll('，', ',');
    if (cleaned.isEmpty) return [];

    final parts = cleaned.split(',');
    for (final part in parts) {
      if (part.contains('-')) {
        final range = part.split('-');
        final start = int.tryParse(range[0]);
        final end = int.tryParse(range[1]);
        if (start != null && end != null) {
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
