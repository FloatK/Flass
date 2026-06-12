// =============================================================================
// 学期配置 DAO（Data Access Object）
//
// 负责 semester_configs 表的所有操作。
// =============================================================================

import 'dart:async';

import 'package:sqflite/sqflite.dart';

import 'database.dart';

/// 学期配置数据访问对象
class SemesterConfigDao {
  final Database Function() _getDatabase;

  SemesterConfigDao(this._getDatabase);

  /// 获取活跃学期配置
  Future<SemesterConfigData?> getActive() async {
    final db = _getDatabase();
    final rows = await db.query(
      'semester_configs',
      where: 'is_active = ?',
      whereArgs: [1],
      limit: 1,
    );
    return rows.isNotEmpty ? SemesterConfigData.fromMap(rows.first) : null;
  }

  /// 设置学期配置
  Future<void> set(SemesterConfigsCompanion config) async {
    final db = _getDatabase();
    await db.transaction((txn) async {
      await txn.update('semester_configs', {'is_active': 0},
          where: 'is_active = ?', whereArgs: [1]);
      await txn.insert('semester_configs', {
        'name': config.name,
        'start_date': config.startDate,
        'total_weeks': config.totalWeeks,
        'is_active': config.isActive ?? 1,
      });
    });
  }

  /// 清除所有学期配置数据
  Future<void> clearAll() async {
    final db = _getDatabase();
    await db.delete('semester_configs');
  }
}
