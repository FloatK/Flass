import 'dart:convert';

import '../../data/models/course.dart';

class ExportUtils {
  ExportUtils._();

  static String exportToJson(List<Course> courses) {
    final list = courses.map((c) => c.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(list);
  }

  static List<Course> importFromJson(String json) {
    final List<dynamic> list = jsonDecode(json) as List<dynamic>;
    return list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static bool isValidScheduleJson(String json) {
    try {
      final List<dynamic> list = jsonDecode(json) as List<dynamic>;
      if (list.isEmpty) return true;
      final first = list.first;
      if (first is! Map<String, dynamic>) return false;
      return first.containsKey('id') &&
          first.containsKey('name') &&
          first.containsKey('teacher');
    } catch (_) {
      return false;
    }
  }
}
