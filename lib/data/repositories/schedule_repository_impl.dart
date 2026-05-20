import 'dart:convert';

import 'package:drift/drift.dart' as drift;

import '../../domain/repositories/schedule_repository.dart';
import '../datasources/database.dart' hide Schedule;
import '../models/schedule.dart';

class ScheduleRepositoryImpl implements ScheduleRepository {
  final AppDatabase _db;

  ScheduleRepositoryImpl(this._db);

  @override
  Future<List<Schedule>> getAllSchedules() async {
    try {
      final rows = await _db.getAllSchedules();
      return rows.map(_mapToModel).toList();
    } catch (e) {
      throw ScheduleRepositoryException('获取课表列表失败: $e');
    }
  }

  @override
  Future<Schedule?> getDefaultSchedule() async {
    try {
      final row = await _db.getDefaultSchedule();
      return row != null ? _mapToModel(row) : null;
    } catch (e) {
      throw ScheduleRepositoryException('获取默认课表失败: $e');
    }
  }

  @override
  Future<void> createSchedule(Schedule schedule) async {
    try {
      await _db.createSchedule(
        SchedulesCompanion(
          id: drift.Value(schedule.id),
          name: drift.Value(schedule.name),
          isDefault: drift.Value(schedule.isDefault),
          createdAt: drift.Value(schedule.createdAt),
          displayedWeekdays:
              drift.Value(jsonEncode(schedule.displayedWeekdays)),
          maxCoursesPerDay: drift.Value(schedule.maxCoursesPerDay),
        ),
      );
    } catch (e) {
      throw ScheduleRepositoryException('创建课表失败: $e');
    }
  }

  @override
  Future<void> renameSchedule(String id, String newName) async {
    try {
      await _db.renameSchedule(id, newName);
    } catch (e) {
      throw ScheduleRepositoryException('重命名课表失败: $e');
    }
  }

  @override
  Future<void> updateSchedule(Schedule schedule) async {
    try {
      await _db.updateSchedule(
        schedule.id,
        SchedulesCompanion(
          name: drift.Value(schedule.name),
          displayedWeekdays:
              drift.Value(jsonEncode(schedule.displayedWeekdays)),
          maxCoursesPerDay: drift.Value(schedule.maxCoursesPerDay),
        ),
      );
    } catch (e) {
      throw ScheduleRepositoryException('更新课表失败: $e');
    }
  }

  @override
  Future<void> deleteSchedule(String id) async {
    try {
      final schedules = await getAllSchedules();
      if (schedules.length <= 1) {
        throw ScheduleRepositoryException('至少保留一个课表');
      }
      final schedule = schedules.firstWhere((s) => s.id == id);
      if (schedule.isDefault) {
        throw ScheduleRepositoryException('默认课表不可删除');
      }
      await _db.deleteSchedule(id);
    } catch (e) {
      if (e is ScheduleRepositoryException) rethrow;
      throw ScheduleRepositoryException('删除课表失败: $e');
    }
  }

  @override
  Future<void> setDefaultSchedule(String id) async {
    try {
      await _db.setDefaultSchedule(id);
    } catch (e) {
      throw ScheduleRepositoryException('设置默认课表失败: $e');
    }
  }

  Schedule _mapToModel(ScheduleData row) {
    return Schedule(
      id: row.id,
      name: row.name,
      isDefault: row.isDefault,
      createdAt: row.createdAt,
      displayedWeekdays: _parseWeekdays(row.displayedWeekdays),
      maxCoursesPerDay: row.maxCoursesPerDay ?? 12,
    );
  }

  List<int> _parseWeekdays(String? json) {
    if (json == null || json.isEmpty) return [1, 2, 3, 4, 5];
    try {
      final list = (jsonDecode(json) as List).cast<int>();
      return list.isEmpty ? [1, 2, 3, 4, 5] : list;
    } catch (_) {
      return [1, 2, 3, 4, 5];
    }
  }
}

class ScheduleRepositoryException implements Exception {
  final String message;
  ScheduleRepositoryException(this.message);

  @override
  String toString() => message;
}
