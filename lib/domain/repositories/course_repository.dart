import '../../data/models/course.dart';

abstract class CourseRepository {
  Stream<List<Course>> watchAllCourses({String? scheduleId});
  Future<void> addCourse(Course course, {String? scheduleId});
  Future<void> updateCourse(Course course);
  Future<void> deleteCourse(String id);
  Future<void> deleteAllByScheduleId(String scheduleId);
}
