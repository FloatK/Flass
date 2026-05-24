import 'package:uuid/uuid.dart';

import '../../data/models/course.dart';
import 'export_utils.dart';

/// 纯 Dart 课表导入工具类，不依赖 UI 上下文或 Riverpod ref。
class ImportUtils {
  ImportUtils._();

  /// 解析紧凑码或 JSON 字符串，返回课程列表。
  ///
  /// 支持两种格式：
  /// 1. 紧凑码（Base64 + GZip 压缩）
  /// 2. 标准 JSON 数组
  ///
  /// 返回 null 表示格式无效。
  static List<Course>? parseImportData(String text) {
    if (text.isEmpty) return null;

    try {
      if (ExportUtils.isCompactFormat(text)) {
        return ExportUtils.compactDecode(text);
      } else if (ExportUtils.isValidScheduleJson(text)) {
        return ExportUtils.importFromJson(text);
      }
      return null;
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
}
