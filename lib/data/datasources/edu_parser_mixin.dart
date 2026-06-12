import 'package:html/parser.dart' as html_parser;

import '../../core/utils/week_utils.dart';

/// Mixin providing shared HTML parsing utilities for edu system parsers.
///
/// This mixin extracts common patterns found across QiangZhi, QingGuo,
/// and ZhengFang parsers to reduce code duplication.
mixin EduParserMixin {
  /// Extract text lines from HTML by splitting on <br> and stripping tags.
  ///
  /// Returns a list of non-empty, trimmed text lines.
  List<String> extractTextLines(String html) {
    return html
        .split(RegExp(r'<br\s*/?>|</?p>|</?div>', caseSensitive: false))
        .map((line) => line
            .replaceAll(RegExp(r'<[^>]*>'), '')
            .replaceAll('&nbsp;', ' ')
            .replaceAll(RegExp(r'\s+'), ' ')
            .trim())
        .where((line) => line.isNotEmpty)
        .toList();
  }

  /// Extract structured data from `<font>` tags with title attributes.
  ///
  /// Returns a map with keys: 'teacher', 'weeks', 'location'.
  Map<String, String> parseFontTags(String html) {
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

    return {
      'teacher': teacher,
      'weeks': weeksStr,
      'location': location,
    };
  }

  /// Check if text looks like a course code (e.g., "002976-080345D" or "C12345").
  bool isCourseCode(String text) {
    return RegExp(r'^[A-Za-z0-9]{2,}-[A-Za-z0-9]{2,}$').hasMatch(text) ||
        RegExp(r'^[A-Z]\d{5,}$').hasMatch(text);
  }

  /// Clean course name by removing trailing P/O markers and extra whitespace.
  String cleanCourseName(String name) {
    return name.replaceAll(RegExp(r'\s+[PO]$'), '').trim();
  }

  /// Parse weeks string into a list of week numbers.
  ///
  /// Handles formats like "1-16周", "1,3,5周", "单周", "双周".
  List<int> parseWeeks(String weeksStr) {
    // Extract only the weeks portion: everything before '(' or '['
    final match = RegExp(r'^([^(\[]+)').firstMatch(weeksStr);
    final weeksOnly =
        (match?.group(1) ?? weeksStr).replaceAll(RegExp(r'[周单双全\s]'), '');
    return WeekUtils.parseWeeks(weeksOnly);
  }

  /// Parse single/double week indicator from weeks string.
  ///
  /// Returns 'single', 'double', or 'all'.
  String parseSingleOrDouble(String weeksStr) {
    return WeekUtils.parseSingleOrDouble(weeksStr);
  }

  /// Extract period range from string like "[1-2节]" or "[3节]".
  ///
  /// Returns a (startPeriod, duration) tuple, or null if not found.
  (int, int)? extractPeriods(String text) {
    final periodMatch =
        RegExp(r'\[(\d+)(?:-(\d+))?节\]').firstMatch(text);
    if (periodMatch != null) {
      final start = int.tryParse(periodMatch.group(1)!) ?? 1;
      final end = int.tryParse(periodMatch.group(2) ?? '') ?? start;
      return (start, end - start + 1);
    }
    return null;
  }

  /// Split cell HTML into multiple course blocks.
  ///
  /// Handles various separators: long dashes, <hr>, multiple <br>.
  List<String> splitCellBlocks(String html) {
    final blocks = <String>[];
    final parts = html.split(
        RegExp(r'-{5,}|<hr\s*/?>|(<br\s*/?>){2,}', caseSensitive: false));

    for (final part in parts) {
      final trimmed = part.trim();
      if (trimmed.isNotEmpty && trimmed != '<br>') {
        blocks.add(trimmed);
      }
    }
    return blocks;
  }

  /// Find course name from text lines, skipping course codes.
  ///
  /// Returns the first non-code line, or empty string if none found.
  String findCourseName(List<String> lines) {
    for (final line in lines) {
      if (isCourseCode(line)) continue;
      return cleanCourseName(line);
    }
    return '';
  }

  /// Calculate period from row index (each row = 2 periods).
  int periodFromRowIndex(int rowIndex) {
    return rowIndex * 2 + 1;
  }
}
