// =============================================================================
// 课程 DAO（Data Access Object）
//
// 负责 courses 和 time_details 表的所有操作。
// =============================================================================

import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'database.dart';

/// 课程数据访问对象
class CourseDao {
  final Database Function() _getDatabase;
  final void Function() _notifyChange;

  CourseDao(this._getDatabase, this._notifyChange);

  /// 插入课程及时间段
  Future<void> insertWithDetails(
    String id,
    String name,
    String teacher,
    String? location,
    int color,
    List<TimeDetailsCompanion> details, {
    String? scheduleId,
    String metadata = '{}',
  }) async {
    final db = _getDatabase();
    await db.transaction((txn) async {
      await txn.insert('courses', {
        'id': id,
        'name': name,
        'teacher': teacher,
        'location': location,
        'color': color,
        'schedule_id': scheduleId,
        'metadata': metadata,
      });
      for (final detail in details) {
        await txn.insert('time_details', {
          'course_id': id,
          'day_of_week': detail.dayOfWeek,
          'start_period': detail.startPeriod,
          'duration': detail.duration,
          'weeks': detail.weeks,
          'single_or_double': detail.singleOrDouble ?? 'all',
        });
      }
    });
    _notifyChange();
  }

  /// 更新课程及时间段
  Future<void> updateWithDetails(
    String id,
    String name,
    String teacher,
    String? location,
    int color,
    List<TimeDetailsCompanion> details, {
    String metadata = '{}',
  }) async {
    final db = _getDatabase();
    await db.transaction((txn) async {
      await txn.update(
        'courses',
        {
          'name': name,
          'teacher': teacher,
          'location': location,
          'color': color,
          'metadata': metadata,
        },
        where: 'id = ?',
        whereArgs: [id],
      );
      await txn.delete('time_details', where: 'course_id = ?', whereArgs: [id]);
      for (final detail in details) {
        await txn.insert('time_details', {
          'course_id': id,
          'day_of_week': detail.dayOfWeek,
          'start_period': detail.startPeriod,
          'duration': detail.duration,
          'weeks': detail.weeks,
          'single_or_double': detail.singleOrDouble ?? 'all',
        });
      }
    });
    _notifyChange();
  }

  /// 删除课程
  Future<void> delete(String id) async {
    final db = _getDatabase();
    await db.transaction((txn) async {
      await txn.delete('time_details', where: 'course_id = ?', whereArgs: [id]);
      await txn.delete('courses', where: 'id = ?', whereArgs: [id]);
    });
    _notifyChange();
  }

  /// 删除课表下的所有课程
  Future<void> deleteByScheduleId(String scheduleId) async {
    final db = _getDatabase();
    final ids = await db.query(
      'courses',
      columns: ['id'],
      where: 'schedule_id = ?',
      whereArgs: [scheduleId],
    );
    for (final row in ids) {
      await delete(row['id'] as String);
    }
    _notifyChange();
  }

  /// 监听所有课程变化
  Stream<List<CourseWithDetails>> watchAll(Stream<void> changeStream) {
    final controller = StreamController<List<CourseWithDetails>>();

    // 初始加载
    _getAllWithDetails().then((courses) {
      if (!controller.isClosed) {
        controller.add(courses);
      }
    });

    // 监听后续变更
    final subscription = changeStream.listen((_) async {
      try {
        final courses = await _getAllWithDetails();
        if (!controller.isClosed) {
          controller.add(courses);
        }
      } catch (e) {
        if (!controller.isClosed) {
          controller.addError(e);
        }
      }
    });

    controller.onCancel = () {
      subscription.cancel();
    };

    return controller.stream;
  }

  /// 获取所有课程及时间段
  Future<List<CourseWithDetails>> _getAllWithDetails() async {
    final db = _getDatabase();
    final courses = await db.query('courses');
    final result = <CourseWithDetails>[];

    for (final courseMap in courses) {
      final course = CourseData.fromMap(courseMap);
      final details = await db.query(
        'time_details',
        where: 'course_id = ?',
        whereArgs: [course.id],
      );
      result.add(CourseWithDetails(
        course: course,
        details: details.map((m) => TimeDetailData.fromMap(m)).toList(),
      ));
    }

    return result;
  }

  /// 检查是否有课程数据
  Future<bool> hasAny() async {
    final db = _getDatabase();
    final result = await db.rawQuery('SELECT COUNT(*) as count FROM courses');
    return (result.first['count'] as int) > 0;
  }

  /// 清除所有课程数据
  Future<void> clearAll() async {
    final db = _getDatabase();
    await db.delete('time_details');
    await db.delete('courses');
  }
}
