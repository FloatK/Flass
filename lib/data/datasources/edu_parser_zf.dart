import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import '../../core/utils/week_utils.dart';
import 'edu_parser.dart';

/// Parser for 正方教务系统 schedule tables.
///
/// 正方系统特征：
/// - 表格 class 包含 "kbcontent"
/// - 单元格使用 div 嵌套，包含课程名、教师、周次、教室等信息
/// - 字段通常使用 <font> 标签或纯文本，以 <br> 分隔
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
class ZhengFangEduParser extends EduParser {
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
    // 按 <br> 分割并提取文本
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

    // 解析 <font> 标签获取结构化信息
    final doc = html_parser.parseFragment(html);
    String teacher = '';
    String weeksStr = '';
    String location = '';

    final fonts = doc.querySelectorAll('font');
    for (final font in fonts) {
      final title = font.attributes['title'] ?? '';
      final text = font.text.trim();
      if (title == '老师' || title == '教师') {
        teacher = text;
      } else if (title.contains('周次') || title.contains('周')) {
        weeksStr = text;
      } else if (title == '教室' || title == '地点') {
        location = text;
      }
    }

    // 课程名称：第一个非代码行
    String name = '';
    for (final line in lines) {
      if (_isCourseCode(line)) continue;
      name = line;
      break;
    }
    if (name.isEmpty) return null;

    // 清理课程名（去除末尾的 P/O 标记）
    name = name.replaceAll(RegExp(r'\s+[PO]$'), '').trim();

    // 解析周次和节次
    int startPeriod = 1;
    int duration = 2;
    List<int> weeks = [];
    String singleOrDouble = 'all';

    if (weeksStr.isNotEmpty) {
      weeks = _parseWeeks(weeksStr);
      singleOrDouble = _parseSingleOrDouble(weeksStr);
      // 尝试提取节次：[XX-YY节] 或 [XX节]
      final periodMatch = RegExp(r'\[(\d+)(?:-(\d+))?节\]').firstMatch(weeksStr);
      if (periodMatch != null) {
        startPeriod = int.tryParse(periodMatch.group(1)!) ?? 1;
        final end = int.tryParse(periodMatch.group(2) ?? '') ?? startPeriod;
        duration = end - startPeriod + 1;
      } else {
        // 使用行位置估算节次
        startPeriod = periodBlock * 2 + 1;
        duration = 2;
      }
    } else {
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
    return RegExp(r'^[A-Za-z0-9]{2,}-[A-Za-z0-9]{2,}$').hasMatch(text) ||
        RegExp(r'^[A-Z]\d{5,}$').hasMatch(text);
  }

  static List<int> _parseWeeks(String weeksStr) {
    // 提取周次部分：括号或方括号之前的内容
    final match = RegExp(r'^([^(\[]+)').firstMatch(weeksStr);
    final weeksOnly = (match?.group(1) ?? weeksStr)
        .replaceAll(RegExp(r'[周单双全\s]'), '');
    return WeekUtils.parseWeeks(weeksOnly);
  }

  static String _parseSingleOrDouble(String weeksStr) {
    return WeekUtils.parseSingleOrDouble(weeksStr);
  }
}
