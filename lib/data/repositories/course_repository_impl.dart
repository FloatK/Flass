import 'dart:async';

import 'package:drift/drift.dart' as drift;

import '../../domain/repositories/course_repository.dart';
import '../datasources/database.dart' hide Course, TimeDetail;
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

  List<Course> _mapToCourses(List<CourseWithDetails> rows) {
    return rows.map((row) {
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
            weeks: _parseWeeks(td.weeks),
            singleOrDouble: td.singleOrDouble,
          );
        }).toList(),
      );
    }).toList();
  }

  List<TimeDetailsCompanion> _timeDetailsToCompanions(
      List<TimeDetail> details) {
    return details.map((td) {
      return TimeDetailsCompanion(
        dayOfWeek: drift.Value(td.dayOfWeek),
        startPeriod: drift.Value(td.startPeriod),
        duration: drift.Value(td.duration),
        weeks: drift.Value(td.weeks.join(',')),
        singleOrDouble: drift.Value(td.singleOrDouble),
      );
    }).toList();
  }

  List<int> _parseWeeks(String weeksStr) {
    if (weeksStr.isEmpty) return [];
    return weeksStr.split(',').map(int.parse).toList();
  }
}

class CourseRepositoryException implements Exception {
  final String message;
  CourseRepositoryException(this.message);

  @override
  String toString() => message;
}
