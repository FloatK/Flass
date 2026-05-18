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

abstract class EduParser {
  const EduParser();

  /// Parse an HTML string from the edu system into a list of parsed courses.
  /// Returns empty list if parsing fails or no courses found.
  List<ParsedCourse> parse(String html);

  String get systemName;
}
