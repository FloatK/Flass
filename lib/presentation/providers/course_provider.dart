import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/course.dart';
import '../../domain/repositories/course_repository.dart';
import 'schedule_provider.dart';

part 'course_provider.g.dart';

@Riverpod(keepAlive: true)
CourseRepository courseRepository(CourseRepositoryRef ref) {
  throw UnimplementedError('Must be overridden with database instance');
}

@riverpod
class CourseList extends _$CourseList {
  @override
  Stream<List<Course>> build() {
    final repo = ref.watch(courseRepositoryProvider);
    final scheduleAsync = ref.watch(currentScheduleProvider);
    return scheduleAsync.when(
      data: (schedule) => repo.watchAllCourses(scheduleId: schedule.id),
      loading: () => repo.watchAllCourses(),
      error: (_, __) => repo.watchAllCourses(),
    );
  }

  Future<void> addCourse(Course course) async {
    final repo = ref.read(courseRepositoryProvider);
    final schedule = ref.read(currentScheduleProvider).valueOrNull;
    await repo.addCourse(course, scheduleId: schedule?.id);
  }

  Future<void> updateCourse(Course course) async {
    final repo = ref.read(courseRepositoryProvider);
    await repo.updateCourse(course);
  }

  Future<void> deleteCourse(String id) async {
    final repo = ref.read(courseRepositoryProvider);
    await repo.deleteCourse(id);
  }

  Future<void> deleteAllByScheduleId(String scheduleId) async {
    final repo = ref.read(courseRepositoryProvider);
    await repo.deleteAllByScheduleId(scheduleId);
  }
}
