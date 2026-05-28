import '../../data/models/course.dart';

/// Intermediate DTO produced by edu system parsers.
/// Caller converts this to [Course] with proper id, color defaults, etc.
class ParsedCourse {
  final String name;
  final String teacher;
  final String location;
  final List<ParsedTimeDetail> timeDetails;

  const ParsedCourse({
    required this.name,
    required this.teacher,
    this.location = '',
    this.timeDetails = const [],
  });

  Course toCourse({
    required String id,
    int color = 0xFF2196F3,
  }) {
    return Course(
      id: id,
      name: name,
      teacher: teacher,
      location: location.isEmpty ? null : location,
      color: color,
      timeDetails: timeDetails
          .map((ptd) => TimeDetail(
                dayOfWeek: ptd.dayOfWeek,
                startPeriod: ptd.startPeriod,
                duration: ptd.duration,
                weeks: ptd.weeks,
                singleOrDouble: ptd.singleOrDouble,
              ))
          .toList(),
    );
  }
}

class ParsedTimeDetail {
  final int dayOfWeek;
  final int startPeriod;
  final int duration;
  final List<int> weeks;
  final String singleOrDouble;

  const ParsedTimeDetail({
    required this.dayOfWeek,
    required this.startPeriod,
    this.duration = 1,
    this.weeks = const [],
    this.singleOrDouble = 'all',
  });
}

/// 教务系统解析器抽象接口。
///
/// 每个教务系统（强智、正方、青果等）实现此接口，
/// 提供 [canParse] 用于自动识别，[parse] 用于解析 HTML。
abstract class EduParser {
  const EduParser();

  /// 人类可读的教务系统名称（如"强智教务系统"）。
  String get systemName;

  /// 判断给定 HTML 是否可以被此解析器解析。
  /// 用于自动识别教务系统类型。
  bool canParse(String html);

  /// 解析 HTML 字符串，返回课程列表。
  /// 解析失败或无课程时返回空列表。
  List<ParsedCourse> parse(String html);
}

/// 教务系统解析器注册表。
///
/// 管理所有已注册的解析器，支持自动识别和手动选择。
class EduParserRegistry {
  EduParserRegistry._();

  static final EduParserRegistry instance = EduParserRegistry._();

  final List<EduParser> _parsers = [];

  /// 注册一个解析器。
  void register(EduParser parser) {
    _parsers.add(parser);
  }

  /// 获取所有已注册的解析器。
  List<EduParser> getAll() => List.unmodifiable(_parsers);

  /// 根据系统名称查找解析器。
  EduParser? findBySystemName(String name) {
    for (final parser in _parsers) {
      if (parser.systemName == name) return parser;
    }
    return null;
  }

  /// 从 HTML 自动识别并返回匹配的解析器。
  ///
  /// 如果有多个解析器匹配，返回第一个匹配的。
  /// 如果没有解析器匹配，返回 null。
  EduParser? detectFromHtml(String html) {
    for (final parser in _parsers) {
      if (parser.canParse(html)) return parser;
    }
    return null;
  }
}
