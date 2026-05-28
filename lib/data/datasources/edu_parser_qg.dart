import 'package:html/parser.dart' as html_parser;
import 'package:html/dom.dart' as dom;

import '../../core/utils/week_utils.dart';
import 'edu_parser.dart';

/// Parser for 青果教务系统 schedule tables.
///
/// 青果系统特征：
/// - 表格使用 <tr> 行结构，第一列是时间段（如"第一节"）
/// - 课程信息在 <td> 单元格内，使用 <p> 或 <div> 标签
/// - 每个课程通常包含：课程名、教师、教室（分行显示）
/// - 周次使用 "周" 后缀，如 "1-16周"、"单周"、"双周"
///
/// 常见结构：
/// ```html
/// <table>
///   <tr>
///     <td>第一节</td>
///     <td>
///       <p>课程名</p>
///       <p>教师</p>
///       <p>1-16周</p>
///       <p>教室</p>
///     </td>
///   </tr>
/// </table>
/// ```
class QingGuoEduParser extends EduParser {
  const QingGuoEduParser();

  @override
  String get systemName => '青果教务系统';

  @override
  bool canParse(String html) {
    // 青果系统特征：
    // 1. 包含 "第X节" 格式的时间段标签
    // 2. 表格结构中课程信息使用 <p> 标签分隔
    // 3. 可能包含 "青果" 字样或特定的 class 名
    final hasPeriodLabel = RegExp(r'第[一二三四五六七八九十\d]+节').hasMatch(html);
    final hasQingGuoMark = html.contains('青果') ||
        html.contains('qingguo') ||
        html.contains('KG');
    final hasPTagStructure = html.contains('<p>') &&
        RegExp(r'周').hasMatch(html);

    // 需要同时满足时间段标签和周次信息
    return (hasPeriodLabel && hasPTagStructure) || hasQingGuoMark;
  }

  @override
  List<ParsedCourse> parse(String html) {
    final document = html_parser.parse(html);
    final courses = <ParsedCourse>[];

    // 查找课表表格
    final tables = document.querySelectorAll('table');
    for (final table in tables) {
      final parsed = _parseTable(table);
      if (parsed.isNotEmpty) {
        courses.addAll(parsed);
        break; // 找到课表表格后停止
      }
    }
    return courses;
  }

  List<ParsedCourse> _parseTable(dom.Element table) {
    final courses = <ParsedCourse>[];
    final tbody = table.querySelector('tbody') ?? table;
    final rows = tbody.querySelectorAll('tr');

    if (rows.length < 2) return courses;

    // 遍历每一行（跳过可能的表头）
    for (int rowIdx = 0; rowIdx < rows.length; rowIdx++) {
      final cells = rows[rowIdx].querySelectorAll('td, th');
      if (cells.length < 2) continue;

      // 第一列是时间段标签（如"第一节"），后续列是周一到周日
      for (int colIdx = 1; colIdx < cells.length; colIdx++) {
        final cell = cells[colIdx];
        final parsed = _parseCell(cell, colIdx - 1, rowIdx);
        courses.addAll(parsed);
      }
    }
    return courses;
  }

  List<ParsedCourse> _parseCell(dom.Element cell, int dayIndex, int rowIndex) {
    final results = <ParsedCourse>[];

    // 青果系统中，一个单元格可能包含多个课程（用分隔线或空行隔开）
    final blocks = _splitCellBlocks(cell.innerHtml);

    for (final block in blocks) {
      final course = _parseSingleBlock(block, dayIndex, rowIndex);
      if (course != null) results.add(course);
    }
    return results;
  }

  List<String> _splitCellBlocks(String html) {
    // 按分隔线或多个 <br> 分割
    final blocks = <String>[];
    final parts = html.split(RegExp(r'-{5,}|<hr\s*/?>|(<br\s*/?>){2,}',
        caseSensitive: false));

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && trimmed != '<br>') {
        blocks.add(trimmed);
      }
    }
    return blocks;
  }

  ParsedCourse? _parseSingleBlock(String html, int dayIndex, int rowIndex) {
    // 按 <br> 或 <p> 分割
    final lines = html
        .split(RegExp(r'<br\s*/?>|</?p>|</?div>', caseSensitive: false))
        .map((line) => line
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim())
        .where((line) => line.isNotEmpty)
        .toList();

    if (lines.isEmpty) return null;

    // 解析字段
    String name = '';
    String teacher = '';
    String location = '';
    String weeksStr = '';

    for (final line in lines) {
      if (_isWeekInfo(line)) {
        weeksStr = line;
      } else if (_isTeacher(line, name)) {
        teacher = line;
      } else if (_isLocation(line)) {
        location = line;
      } else if (name.isEmpty) {
        name = line;
      }
    }

    if (name.isEmpty) return null;

    // 解析周次
    int startPeriod = _getPeriodFromRowIndex(rowIndex);
    int duration = 1;
    List<int> weeks = [];
    String singleOrDouble = 'all';

    if (weeksStr.isNotEmpty) {
      weeks = _parseWeeks(weeksStr);
      singleOrDouble = _parseSingleOrDouble(weeksStr);
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

  bool _isWeekInfo(String text) {
    // 匹配 "1-16周"、"单周"、"双周"、"1,3,5周" 等格式
    return RegExp(r'^\d[\d,\-~]+周$').hasMatch(text) ||
        RegExp(r'^[单双]周$').hasMatch(text) ||
        RegExp(r'^第?\d[\d,\-~]+周$').hasMatch(text);
  }

  bool _isTeacher(String text, String courseName) {
    // 教师通常是2-4个汉字，且不是课程名
    if (text == courseName) return false;
    return RegExp(r'^[\u4e00-\u9fa5]{2,4}$').hasMatch(text) &&
        !_isWeekInfo(text) &&
        !_isLocation(text);
  }

  bool _isLocation(String text) {
    // 教室通常包含楼、室、号等关键字
    return RegExp(r'[楼室号楼栋]|[\d]{3,}|[A-Z]\d{3}').hasMatch(text);
  }

  int _getPeriodFromRowIndex(int rowIndex) {
    // 根据行索引估算节次（青果系统通常每行对应一个时间段）
    return rowIndex + 1;
  }

  static List<int> _parseWeeks(String weeksStr) {
    // 清理周次字符串
    final cleaned = weeksStr
        .replaceAll(RegExp(r'[周第\s]'), '')
        .replaceAll('单', '')
        .replaceAll('双', '');
    return WeekUtils.parseWeeks(cleaned);
  }

  static String _parseSingleOrDouble(String weeksStr) {
    if (weeksStr.contains('单')) return 'single';
    if (weeksStr.contains('双')) return 'double';
    return 'all';
  }
}
