import '../entities/course_entities.dart';

abstract class CourseRepository {
  Stream<List<Course>> watchAllCourses({String? scheduleId});
  Future<void> addCourse(Course course, {String? scheduleId});
  Future<void> updateCourse(Course course);
  Future<void> deleteCourse(String id);
  Future<void> deleteAllByScheduleId(String scheduleId);
  /// 批量更新同名课程的颜色（单次 SQL，避免 N+1）
  Future<void> updateColorByName(String name, int color);
}
