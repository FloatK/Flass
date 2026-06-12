import 'package:freezed_annotation/freezed_annotation.dart';

part 'course.freezed.dart';
part 'course.g.dart';

@freezed
class Course with _$Course {
  const factory Course({
    required String id,
    required String name,
    required String teacher,
    String? location,
    @Default(0xFF2196F3) int color,
    @Default([]) List<TimeDetail> timeDetails,
    /// 扩展元数据字段
    ///
    /// 用于存储未来可能需要的属性，无需数据库迁移。
    /// 例如：credits, category, syllabusUrl, customTags 等。
    @Default({}) Map<String, dynamic> metadata,
  }) = _Course;

  factory Course.fromJson(Map<String, dynamic> json) => _$CourseFromJson(json);
}

@freezed
class TimeDetail with _$TimeDetail {
  const factory TimeDetail({
    required int dayOfWeek,
    required int startPeriod,
    @Default(1) int duration,
    @Default([]) List<int> weeks,
    @Default('all') String singleOrDouble,
  }) = _TimeDetail;

  factory TimeDetail.fromJson(Map<String, dynamic> json) =>
      _$TimeDetailFromJson(json);
}
