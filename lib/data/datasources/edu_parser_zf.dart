import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import 'edu_parser.dart';
import 'edu_parser_mixin.dart';

/// Parser for 正方教务系统 schedule tables.
///
/// 正方系统特征：
/// - 表格 class 包含 "kbcontent"
/// - 单元格使用 div 嵌套，包含课程名、教师、周次、教室等信息
/// - 字段通常使用 `<font>` 标签或纯文本，以 `<br>` 分隔
///
/// 常见结构：
/// ```html
/// <table class="kbcontent">
///   <tr>
///     <td>
///       <div>课程名<br>
///         <font>教师</font><br>
///         <font>周次(节次)</font><br>
///         <font>教室</font>
///       </div>
///     </td>
///   </tr>
/// </table>
/// ```
class ZhengFangEduParser extends EduParser with EduParserMixin {
  const ZhengFangEduParser();

  @override
  String get systemName => '正方教务系统';

  @override
  bool canParse(String html) {
    // 正方系统特征：class 包含 "kbcontent"，且有特定的表格结构
    return html.contains('class="kbcontent"') ||
        html.contains("class='kbcontent'") ||
        (html.contains('kbcontent') && html.contains('kbcontent1'));
  }

  @override
  List<ParsedCourse> parse(String html) {
    final document = html_parser.parse(html);
    final courses = <ParsedCourse>[];

    // 查找课表表格 - 正方系统通常使用 class="kbcontent"
    final tables = document.querySelectorAll('table.kbcontent');
    if (tables.isEmpty) {
      // 备选：查找包含 kbcontent 的表格
      final allTables = document.querySelectorAll('table');
      for (final table in allTables) {
        if (table.className.contains('kbcontent')) {
          courses.addAll(_parseTable(table));
        }
      }
      return courses;
    }

    for (final table in tables) {
      courses.addAll(_parseTable(table));
    }
    return courses;
  }

  List<ParsedCourse> _parseTable(dom.Element table) {
    final courses = <ParsedCourse>[];
    final tbody = table.querySelector('tbody') ?? table;
    final rows = tbody.querySelectorAll('tr');
    if (rows.length < 2) return courses;

    // 跳过表头行，每行对应一个时间段
    for (int rowIdx = 1; rowIdx < rows.length; rowIdx++) {
      final cells = rows[rowIdx].querySelectorAll('td, th');
      for (int colIdx = 0; colIdx < cells.length; colIdx++) {
        // 跳过第一列（时间段标签）
        if (colIdx == 0) continue;
        final cell = cells[colIdx];
        final parsed = _parseCell(cell, colIdx - 1, rowIdx - 1);
        courses.addAll(parsed);
      }
    }
    return courses;
  }

  List<ParsedCourse> _parseCell(dom.Element cell, int dayIndex, int periodBlock) {
    final results = <ParsedCourse>[];

    // 正方系统可能在一个单元格中包含多个课程（用分隔线隔开）
    final html = cell.innerHtml;
    final blocks = html.split(RegExp(r'-{5,}|<hr\s*/?>', caseSensitive: false));

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
