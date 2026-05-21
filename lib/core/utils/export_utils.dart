import 'dart:convert';
import 'dart:io';

import '../../data/models/course.dart';

/// Compact format: short-key JSON → GZip → base64Url (and reverse).
class ExportUtils {
  ExportUtils._();

  static const _courseIdKey = 'a';
  static const _courseNameKey = 'b';
  static const _courseTeacherKey = 'c';
  static const _courseLocationKey = 'd';
  static const _courseColorKey = 'e';
  static const _courseTdKey = 'f';
  static const _tdDayKey = 'a';
  static const _tdStartKey = 'b';
  static const _tdDurationKey = 'c';
  static const _tdWeeksKey = 'd';
  static const _tdSingleKey = 'e';

  // ---------------------------------------------------------------------------
  // Pretty JSON (existing, for human-readable export)
  // ---------------------------------------------------------------------------

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

  // ---------------------------------------------------------------------------
  // Compact format: short keys → GZip → base64Url
  // ---------------------------------------------------------------------------

  /// Encode a list of courses into a compact, single-line, URL-safe string.
  ///
  /// Pipeline: Course objects → short-key JSON → GZip → base64Url.
  /// Decodable via [compactDecode].
  static String compactEncode(List<Course> courses) {
    final list = courses.map(_compactCourse).toList();
    final json = jsonEncode(list);
    final compressed = GZipCodec().encode(utf8.encode(json));
    return base64Url.encode(compressed);
  }

  /// Reverse of [compactEncode]: decode the compact string back to [Course].
  /// Throws [FormatException] if the input is invalid.
  static List<Course> compactDecode(String data) {
    try {
      final compressed = base64Url.decode(data);
      final json = utf8.decode(GZipCodec().decode(compressed));
      final list = jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => _expandCourse(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Invalid compact schedule data: $e');
    }
  }

  /// Check whether a string looks like compact-encoded schedule data.
  static bool isCompactFormat(String data) {
    // URL-safe base64: alphanumeric + '-' + '_' + '=' (padding).
    if (data.isEmpty) return false;
    return RegExp(r'^[A-Za-z0-9\-_=]+$').hasMatch(data);
  }

  // ---- compact internal helpers ---------------------------------------------

  static Map<String, dynamic> _compactCourse(Course c) {
    final map = <String, dynamic>{
      _courseIdKey: c.id,
      _courseNameKey: c.name,
      _courseTeacherKey: c.teacher,
      _courseColorKey: c.color,
      _courseTdKey: c.timeDetails.map(_compactTd).toList(),
    };
    // Omit null location to save bytes
    if (c.location != null) map[_courseLocationKey] = c.location;
    return map;
  }

  static Course _expandCourse(Map<String, dynamic> m) {
    return Course(
      id: m[_courseIdKey] as String,
      name: m[_courseNameKey] as String,
      teacher: m[_courseTeacherKey] as String,
      location: m[_courseLocationKey] as String?,
      color: m[_courseColorKey] as int,
      timeDetails: (m[_courseTdKey] as List<dynamic>)
          .map((td) => _expandTd(td as Map<String, dynamic>))
          .toList(),
    );
  }

  static Map<String, dynamic> _compactTd(TimeDetail td) {
    return {
      _tdDayKey: td.dayOfWeek,
      _tdStartKey: td.startPeriod,
      _tdDurationKey: td.duration,
      _tdWeeksKey: td.weeks,
      _tdSingleKey: td.singleOrDouble,
    };
  }

  static TimeDetail _expandTd(Map<String, dynamic> m) {
    return TimeDetail(
      dayOfWeek: m[_tdDayKey] as int,
      startPeriod: m[_tdStartKey] as int,
      duration: m[_tdDurationKey] as int,
      weeks: (m[_tdWeeksKey] as List<dynamic>).cast<int>(),
      singleOrDouble: m[_tdSingleKey] as String,
    );
  }
}
