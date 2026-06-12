// =============================================================================
// 课表 DAO（Data Access Object）
//
// 负责 schedules 表的所有操作。
// =============================================================================

import 'dart:async';
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import 'database.dart';

/// 课表数据访问对象
class ScheduleDao {
  final Database Function() _getDatabase;
  final void Function() _notifyChange;

  ScheduleDao(this._getDatabase, this._notifyChange);

  /// 创建课表
  Future<void> create(SchedulesCompanion schedule) async {
    final db = _getDatabase();
    await db.insert('schedules', {
      'id': schedule.id,
      'name': schedule.name,
      'is_default': (schedule.isDefault ?? false) ? 1 : 0,
      'created_at': (schedule.createdAt ?? DateTime.now()).toIso8601String(),
      'displayed_weekdays':
          schedule.displayedWeekdays ?? jsonEncode([1, 2, 3, 4, 5]),
      'max_courses_per_day': schedule.maxCoursesPerDay ?? 12,
      'start_date': schedule.startDate,
      'total_weeks': schedule.totalWeeks ?? 20,
    });
    _notifyChange();
  }

  /// 获取所有课表
  Future<List<ScheduleData>> getAll() async {
    final db = _getDatabase();
    final rows = await db.query('schedules', orderBy: 'created_at DESC');
    return rows.map((m) => ScheduleData.fromMap(m)).toList();
  }

  /// 获取默认课表
  Future<ScheduleData?> getDefault() async {
    final db = _getDatabase();
    final rows = await db.query(
      'schedules',
      where: 'is_default = ?',
      whereArgs: [1],
      limit: 1,
    );
    return rows.isNotEmpty ? ScheduleData.fromMap(rows.first) : null;
  }

  /// 根据 ID 获取课表
  Future<ScheduleData?> getById(String id) async {
    final db = _getDatabase();
    final rows = await db.query(
      'schedules',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return rows.isNotEmpty ? ScheduleData.fromMap(rows.first) : null;
  }

  /// 重命名课表
  Future<void> rename(String id, String newName) async {
    final db = _getDatabase();
    await db.update(
      'schedules',
      {'name': newName},
      where: 'id = ?',
      whereArgs: [id],
    );
    _notifyChange();
  }

  /// 删除课表
  Future<void> delete(String id) async {
    final db = _getDatabase();
    await db.transaction((txn) async {
      // 删除课表下的所有课程
      await txn.delete(
        'courses',
        where: 'schedule_id = ?',
        whereArgs: [id],
      );
      await txn.delete('schedules', where: 'id = ?', whereArgs: [id]);
    });
    _notifyChange();
  }

  /// 设置默认课表
  Future<void> setDefault(String id) async {
    final db = _getDatabase();
    await db.transaction((txn) async {
      await txn.update('schedules', {'is_default': 0},
          where: 'is_default = ?', whereArgs: [1]);
      await txn.update('schedules', {'is_default': 1},
          where: 'id = ?', whereArgs: [id]);
    });
    _notifyChange();
  }

  /// 更新课表
  Future<void> update(String id, SchedulesCompanion values) async {
    final db = _getDatabase();
    final Map<String, dynamic> updates = {};
    if (values.name != null) updates['name'] = values.name;
    if (values.isDefault != null) {
      updates['is_default'] = values.isDefault! ? 1 : 0;
    }
    if (values.displayedWeekdays != null) {
      updates['displayed_weekdays'] = values.displayedWeekdays;
    }
    if (values.maxCoursesPerDay != null) {
      updates['max_courses_per_day'] = values.maxCoursesPerDay;
    }
    if (values.startDate != null) updates['start_date'] = values.startDate;
    if (values.totalWeeks != null) updates['total_weeks'] = values.totalWeeks;

    if (updates.isNotEmpty) {
      await db.update('schedules', updates, where: 'id = ?', whereArgs: [id]);
    }
    _notifyChange();
  }

  /// 清除所有课表数据
  Future<void> clearAll() async {
    final db = _getDatabase();
    await db.delete('schedules');
  }
}
