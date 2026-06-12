import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import 'edu_parser.dart';
import 'edu_parser_mixin.dart';

/// Parser for 强智教务系统 schedule tables.
///
/// Table has id="kbtable". Each cell contains div.kbcontent with:
///   code`<br>`name`<br>``<font title="老师">`teacher`</font>``<br>`
///   `<font title="周次(节次)">`weeks(周)[periods节]`</font>``<br>`
///   [`<font title="教室">`location`</font>``<br>`]
/// Multiple courses in one cell are separated by "---------------------"
class QiangZhiEduParser extends EduParser with EduParserMixin {
  const QiangZhiEduParser();

  @override
  String get systemName => '强智教务系统';

  @override
  bool canParse(String html) {
    // 强智系统特征：表格 id="kbtable"，单元格包含 div.kbcontent
    return html.contains('id="kbtable"') || html.contains("id='kbtable'");
  }

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
    final lines = extractTextLines(html);
    if (lines.isEmpty) return null;

    // Extract structured data from font tags
    final fontData = parseFontTags(html);
    final teacher = fontData['teacher'] ?? '';
    final weeksStr = fontData['weeks'] ?? '';
    final location = fontData['location'] ?? '';

    // Find course name (skip course codes)
    final name = findCourseName(lines);
    if (name.isEmpty) return null;

    // Parse weeks and periods
    int startPeriod = 1;
    int duration = 2;
    List<int> weeks = [];
    String singleOrDouble = 'all';

    if (weeksStr.isNotEmpty) {
      weeks = parseWeeks(weeksStr);
      singleOrDouble = parseSingleOrDouble(weeksStr);
      // Try to extract periods from [XX-YY节] or [XX节]
      final periods = extractPeriods(weeksStr);
      if (periods != null) {
        startPeriod = periods.$1;
        duration = periods.$2;
      } else {
        // Fallback: use period block position
        startPeriod = periodFromRowIndex(periodBlock);
        duration = 2;
      }
    } else {
      startPeriod = periodFromRowIndex(periodBlock);
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
}
