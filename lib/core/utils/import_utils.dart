import 'package:uuid/uuid.dart';

import '../../data/models/course.dart';
import 'format_registry.dart';

/// 纯 Dart 课表导入工具类，不依赖 UI 上下文或 Riverpod ref。
///
/// 使用 [FormatRegistry] 进行格式检测和解码。
/// 添加新格式只需在 [FormatRegistry] 中注册即可。
class ImportUtils {
  ImportUtils._();

  /// 解析导入数据，返回课程列表。
  ///
  /// 自动检测格式并解码。
  /// 返回 null 表示格式无效。
  static List<Course>? parseImportData(String text) {
    if (text.isEmpty) return null;

    try {
      return FormatRegistry.instance.decode(text);
    } catch (e) {
      rethrow;
    }
  }

  /// 从文本中提取紧凑码。
  ///
  /// 支持从 `「...」` 格式的消息中提取。
  static String extractCompactCode(String text) {
    text = text.trim();
    // Extract compact code from 「…」
    final match = RegExp(r'「(.+?)」').firstMatch(text);
    if (match != null) return match.group(1)!;
    return text;
  }

  /// 为课程分配新的 UUID，避免数据库 UNIQUE 约束冲突。
  static List<Course> assignFreshIds(List<Course> courses) {
    final uuid = const Uuid();
    return courses.map((c) => c.copyWith(id: uuid.v4())).toList();
  }

  /// 完整的导入解析流程：提取紧凑码 → 解析 → 分配新 ID。
  ///
  /// 返回解析后的课程列表，如果格式无效返回 null。
  /// 如果解析失败会抛出异常。
  static List<Course>? parseAndPrepareImport(String rawText) {
    final extracted = extractCompactCode(rawText);
    final courses = parseImportData(extracted);
    if (courses == null) return null;
    return assignFreshIds(courses);
  }

  /// 获取所有可用的导入格式
  static List<DataFormat> getAvailableFormats() {
    return FormatRegistry.instance.getAll();
  }

  /// 使用指定格式编码课程
  static String encodeWithFormat(String formatName, List<Course> courses) {
    return FormatRegistry.instance.encode(formatName, courses);
  }
}
