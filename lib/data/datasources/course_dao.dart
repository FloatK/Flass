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

  /// 删除课表下的所有课程（批量 SQL，避免 N+1）
  Future<void> deleteByScheduleId(String scheduleId) async {
    final db = _getDatabase();
    await db.transaction((txn) async {
      await txn.rawDelete(
        'DELETE FROM time_details WHERE course_id IN '
        '(SELECT id FROM courses WHERE schedule_id = ?)',
        [scheduleId],
      );
      await txn.delete('courses',
          where: 'schedule_id = ?', whereArgs: [scheduleId]);
    });
    _notifyChange();
  }

  /// 批量更新同名课程的颜色
  Future<void> updateColorByName(String name, int color) async {
    final db = _getDatabase();
    await db.update(
      'courses',
      {'color': color},
      where: 'name = ? AND color != ?',
      whereArgs: [name, color],
    );
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

  /// 获取所有课程及时间段（单次 JOIN 查询，避免 N+1）
  Future<List<CourseWithDetails>> _getAllWithDetails() async {
    final db = _getDatabase();
    final rows = await db.rawQuery('''
      SELECT c.id, c.name, c.teacher, c.location, c.color,
             c.schedule_id, c.metadata,
             td.id as td_id, td.course_id,
             td.day_of_week, td.start_period,
             td.duration, td.weeks, td.single_or_double
      FROM courses c
      LEFT JOIN time_details td ON td.course_id = c.id
      ORDER BY c.id
    ''');

    // Group flat rows by course
    final courseMap = <String, CourseWithDetails>{};
    for (final row in rows) {
      final courseId = row['id'] as String;
      final entry = courseMap.putIfAbsent(
        courseId,
        () => CourseWithDetails(
          course: CourseData(
            id: courseId,
            name: row['name'] as String,
            teacher: row['teacher'] as String,
            location: row['location'] as String?,
            color: row['color'] as int,
            scheduleId: row['schedule_id'] as String?,
            metadata: row['metadata'] as String? ?? '{}',
          ),
        ),
      );

      // time_details may be NULL for courses with no time details
      if (row['td_id'] != null) {
        entry.details.add(TimeDetailData(
          id: row['td_id'] as int,
          courseId: row['course_id'] as String,
          dayOfWeek: row['day_of_week'] as int,
          startPeriod: row['start_period'] as int,
          duration: row['duration'] as int,
          weeks: row['weeks'] as String,
          singleOrDouble: row['single_or_double'] as String,
        ));
      }
    }

    return courseMap.values.toList();
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
