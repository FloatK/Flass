import 'dart:convert';
import 'dart:io';

import '../../data/models/course.dart';

/// 导入/导出格式抽象接口
///
/// 实现此接口以添加新的导入/导出格式。
/// 使用 [FormatRegistry] 注册格式实例。
abstract class DataFormat {
  /// 格式名称（用于 UI 显示）
  String get formatName;

  /// 格式文件扩展名（如 'json', 'csv', 'ics'）
  String get fileExtension;

  /// MIME 类型（如 'application/json', 'text/csv'）
  String get mimeType;

  /// 检测数据是否为此格式
  ///
  /// 返回 true 表示数据可能是此格式（用于自动检测）。
  bool canDecode(String data);

  /// 编码课程列表为字符串
  String encode(List<Course> courses);

  /// 解码字符串为课程列表
  ///
  /// 如果格式无效，抛出 [FormatException]。
  List<Course> decode(String data);
}

/// 格式注册表
///
/// 管理所有可用的导入/导出格式。
/// 使用 [FormatRegistry.instance] 获取全局实例。
///
/// 示例：
/// ```dart
/// // 注册新格式
/// FormatRegistry.instance.register(CsvFormat());
///
/// // 自动检测格式并解码
/// final courses = FormatRegistry.instance.decode(data);
///
/// // 获取所有可用格式
/// final formats = FormatRegistry.instance.getAll();
/// ```
class FormatRegistry {
  FormatRegistry._();

  static final FormatRegistry instance = FormatRegistry._();

  final List<DataFormat> _formats = [];

  /// 注册一个新格式
  void register(DataFormat format) {
    _formats.add(format);
  }

  /// 获取所有已注册的格式
  List<DataFormat> getAll() => List.unmodifiable(_formats);

  /// 根据名称查找格式
  DataFormat? findByName(String name) {
    try {
      return _formats.firstWhere((f) => f.formatName == name);
    } catch (_) {
      return null;
    }
  }

  /// 根据文件扩展名查找格式
  DataFormat? findByExtension(String extension) {
    try {
      return _formats.firstWhere(
          (f) => f.fileExtension.toLowerCase() == extension.toLowerCase());
    } catch (_) {
      return null;
    }
  }

  /// 自动检测数据格式并解码
  ///
  /// 按注册顺序尝试每个格式的 [DataFormat.canDecode]。
  /// 返回第一个匹配格式的解码结果，如果没有匹配格式返回 null。
  List<Course>? decode(String data) {
    for (final format in _formats) {
      if (format.canDecode(data)) {
        try {
          return format.decode(data);
        } catch (e) {
          // 此格式解码失败，继续尝试下一个
          continue;
        }
      }
    }
    return null;
  }

  /// 使用指定格式编码
  String encode(String formatName, List<Course> courses) {
    final format = findByName(formatName);
    if (format == null) {
      throw ArgumentError('Unknown format: $formatName');
    }
    return format.encode(courses);
  }
}

/// 紧凑码格式（short-key JSON → GZip → base64Url）
class CompactFormat implements DataFormat {
  @override
  String get formatName => 'compact';

  @override
  String get fileExtension => 'txt';

  @override
  String get mimeType => 'text/plain';

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

  @override
  bool canDecode(String data) {
    if (data.isEmpty) return false;
    // URL-safe base64: alphanumeric + '-' + '_' + '=' (padding)
    return RegExp(r'^[A-Za-z0-9\-_=]+$').hasMatch(data);
  }

  @override
  String encode(List<Course> courses) {
    final list = courses.map(_compactCourse).toList();
    final json = _jsonEncode(list);
    final compressed = _gzipEncode(utf8.encode(json));
    return base64Url.encode(compressed);
  }

  @override
  List<Course> decode(String data) {
    try {
      final compressed = base64Url.decode(data);
      final json = utf8.decode(_gzipDecode(compressed));
      final list = _jsonDecode(json) as List<dynamic>;
      return list
          .map((e) => _expandCourse(e as Map<String, dynamic>))
          .toList();
    } on FormatException {
      rethrow;
    } catch (e) {
      throw FormatException('Invalid compact schedule data: $e');
    }
  }

  Map<String, dynamic> _compactCourse(Course c) {
    final map = <String, dynamic>{
      _courseIdKey: c.id,
      _courseNameKey: c.name,
      _courseTeacherKey: c.teacher,
      _courseColorKey: c.color,
      _courseTdKey: c.timeDetails.map(_compactTd).toList(),
    };
    if (c.location != null) map[_courseLocationKey] = c.location;
    return map;
  }

  Course _expandCourse(Map<String, dynamic> m) {
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

  Map<String, dynamic> _compactTd(TimeDetail td) {
    return {
      _tdDayKey: td.dayOfWeek,
      _tdStartKey: td.startPeriod,
      _tdDurationKey: td.duration,
      _tdWeeksKey: td.weeks,
      _tdSingleKey: td.singleOrDouble,
    };
  }

  TimeDetail _expandTd(Map<String, dynamic> m) {
    return TimeDetail(
      dayOfWeek: m[_tdDayKey] as int,
      startPeriod: m[_tdStartKey] as int,
      duration: m[_tdDurationKey] as int,
      weeks: (m[_tdWeeksKey] as List<dynamic>).cast<int>(),
      singleOrDouble: m[_tdSingleKey] as String,
    );
  }

  // JSON/GZip 实现
  static String _jsonEncode(Object? object) {
    return jsonEncode(object);
  }

  static dynamic _jsonDecode(String json) {
    return jsonDecode(json);
  }

  static List<int> _gzipEncode(List<int> bytes) {
    return GZipCodec().encode(bytes);
  }

  static List<int> _gzipDecode(List<int> bytes) {
    return GZipCodec().decode(bytes);
  }
}

/// 标准 JSON 格式
class JsonFormat implements DataFormat {
  @override
  String get formatName => 'json';

  @override
  String get fileExtension => 'json';

  @override
  String get mimeType => 'application/json';

  @override
  bool canDecode(String data) {
    try {
      final list = _jsonDecode(data) as List<dynamic>;
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

  @override
  String encode(List<Course> courses) {
    final list = courses.map((c) => c.toJson()).toList();
    return _jsonEncodePretty(list);
  }

  @override
  List<Course> decode(String data) {
    final List<dynamic> list = _jsonDecode(data) as List<dynamic>;
    return list
        .map((e) => Course.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  static dynamic _jsonDecode(String json) {
    return jsonDecode(json);
  }

  static String _jsonEncodePretty(Object? object) {
    return const JsonEncoder.withIndent('  ').convert(object);
  }
}

/// 初始化默认格式
///
/// 在应用启动时调用，注册所有内置格式。
void initDefaultFormats() {
  final registry = FormatRegistry.instance;
  registry.register(CompactFormat());
  registry.register(JsonFormat());
}
