import 'package:freezed_annotation/freezed_annotation.dart';

part 'schedule.freezed.dart';
part 'schedule.g.dart';

@freezed
class Schedule with _$Schedule {
  const factory Schedule({
    required String id,
    required String name,
    @Default(false) bool isDefault,
    required DateTime createdAt,
    @Default([1, 2, 3, 4, 5]) List<int> displayedWeekdays,
    @Default(12) int maxCoursesPerDay,
  }) = _Schedule;

  factory Schedule.fromJson(Map<String, dynamic> json) =>
      _$ScheduleFromJson(json);
}
