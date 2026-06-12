import 'dart:async';
import 'dart:convert';

import '../../core/utils/week_utils.dart';
import '../../domain/repositories/course_repository.dart';
import '../datasources/database.dart';
import '../models/course.dart';

class CourseRepositoryImpl implements CourseRepository {
  final AppDatabase _db;

  CourseRepositoryImpl(this._db);

  @override
  Stream<List<Course>> watchAllCourses({String? scheduleId}) {
    return _db.watchAllCourses().map((rows) {
      if (scheduleId != null) {
        rows = rows.where((r) => r.course.scheduleId == scheduleId).toList();
      }
      return _mapToCourses(rows);
    });
  }

  @override
  Future<void> addCourse(Course course, {String? scheduleId}) async {
    try {
      await _db.insertCourseWithDetails(
        course.id,
        course.name,
        course.teacher,
        course.location,
        course.color,
        _timeDetailsToCompanions(course.timeDetails),
        scheduleId: scheduleId,
        metadata: jsonEncode(course.metadata),
      );
    } catch (e) {
      throw CourseRepositoryException('添加课程失败: $e');
    }
  }

  @override
  Future<void> updateCourse(Course course) async {
    try {
      await _db.updateCourseWithDetails(
        course.id,
        course.name,
        course.teacher,
        course.location,
        course.color,
        _timeDetailsToCompanions(course.timeDetails),
        metadata: jsonEncode(course.metadata),
      );
    } catch (e) {
      throw CourseRepositoryException('更新课程失败: $e');
    }
  }

  @override
  Future<void> deleteCourse(String id) async {
    try {
      await _db.deleteCourse(id);
    } catch (e) {
      throw CourseRepositoryException('删除课程失败: $e');
    }
  }

  @override
  Future<void> deleteAllByScheduleId(String scheduleId) async {
    try {
      await _db.deleteCoursesByScheduleId(scheduleId);
    } catch (e) {
      throw CourseRepositoryException('清空课表失败: $e');
    }
  }

  List<Course> _mapToCourses(List<CourseWithDetails> rows) {
    return rows.map((row) {
      // 解析 metadata JSON
      Map<String, dynamic> metadata = {};
      try {
        if (row.course.metadata.isNotEmpty) {
          metadata = jsonDecode(row.course.metadata) as Map<String, dynamic>;
        }
      } catch (e) {
        // JSON 解析失败，使用空 Map
      }

      return Course(
        id: row.course.id,
        name: row.course.name,
        teacher: row.course.teacher,
        location: row.course.location,
        color: row.course.color,
        timeDetails: row.details.map((td) {
          return TimeDetail(
            dayOfWeek: td.dayOfWeek,
            startPeriod: td.startPeriod,
            duration: td.duration,
            weeks: WeekUtils.parseWeeks(td.weeks),
            singleOrDouble: td.singleOrDouble,
          );
        }).toList(),
        metadata: metadata,
      );
    }).toList();
  }

  List<TimeDetailsCompanion> _timeDetailsToCompanions(
      List<TimeDetail> details) {
    return details.map((td) {
      return TimeDetailsCompanion(
        dayOfWeek: td.dayOfWeek,
        startPeriod: td.startPeriod,
        duration: td.duration,
        weeks: td.weeks.join(','),
        singleOrDouble: td.singleOrDouble,
      );
    }).toList();
  }
}

class CourseRepositoryException implements Exception {
  final String message;
  CourseRepositoryException(this.message);

  @override
  String toString() => message;
}
