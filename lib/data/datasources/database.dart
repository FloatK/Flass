// =============================================================================
// Flass 跨平台数据库实现（基于 sqflite）
//
// 支持：Android, iOS, Windows, Linux, macOS, HarmonyOS (OHOS)
//
// 使用 DAO 模式将数据库操作拆分为独立的表级访问对象：
// - [CourseDao] - 课程和时间段操作
// - [ScheduleDao] - 课表操作
// - [SemesterConfigDao] - 学期配置操作
// =============================================================================

import 'dart:async';

import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:sqflite/sqflite.dart';

import 'course_dao.dart';
import 'schedule_dao.dart';
import 'semester_config_dao.dart';

// 重新导出数据类型和 DAO
export 'course_dao.dart';
export 'schedule_dao.dart';
export 'semester_config_dao.dart';

// =============================================================================
// 数据类型定义
// =============================================================================

/// 课程数据
class CourseData {
  final String id;
  final String name;
  final String teacher;
  final String? location;
  final int color;
  final String? scheduleId;
  final String metadata; // JSON 字符串

  CourseData({
    required this.id,
    required this.name,
    required this.teacher,
    this.location,
    required this.color,
    this.scheduleId,
    this.metadata = '{}',
  });

  factory CourseData.fromMap(Map<String, dynamic> map) {
    return CourseData(
      id: map['id'] as String,
      name: map['name'] as String,
      teacher: map['teacher'] as String,
      location: map['location'] as String?,
      color: map['color'] as int,
      scheduleId: map['schedule_id'] as String?,
      metadata: map['metadata'] as String? ?? '{}',
    );
  }
}

/// 时间段数据
class TimeDetailData {
  final int? id;
  final String courseId;
  final int dayOfWeek;
  final int startPeriod;
  final int duration;
  final String weeks; // 存储为逗号分隔的字符串
  final String singleOrDouble;

  TimeDetailData({
    this.id,
    required this.courseId,
    required this.dayOfWeek,
    required this.startPeriod,
    required this.duration,
    required this.weeks,
    required this.singleOrDouble,
  });

  factory TimeDetailData.fromMap(Map<String, dynamic> map) {
    return TimeDetailData(
      id: map['id'] as int?,
      courseId: map['course_id'] as String,
      dayOfWeek: map['day_of_week'] as int,
      startPeriod: map['start_period'] as int,
      duration: map['duration'] as int,
      weeks: map['weeks'] as String,
      singleOrDouble: map['single_or_double'] as String,
    );
  }
}

/// 课程 + 时间段
class CourseWithDetails {
  final CourseData course;
  final List<TimeDetailData> details;

  CourseWithDetails({required this.course, List<TimeDetailData>? details})
      : details = details ?? [];
}

/// 课表数据
class ScheduleData {
  final String id;
  final String name;
  final bool isDefault;
  final DateTime createdAt;
  final String? displayedWeekdays; // JSON 字符串
  final int? maxCoursesPerDay;
  final String? startDate;
  final int? totalWeeks;

  ScheduleData({
    required this.id,
    required this.name,
    required this.isDefault,
    required this.createdAt,
    this.displayedWeekdays,
    this.maxCoursesPerDay,
    this.startDate,
    this.totalWeeks,
  });

  factory ScheduleData.fromMap(Map<String, dynamic> map) {
    return ScheduleData(
      id: map['id'] as String,
      name: map['name'] as String,
      isDefault: (map['is_default'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      displayedWeekdays: map['displayed_weekdays'] as String?,
      maxCoursesPerDay: map['max_courses_per_day'] as int?,
      startDate: map['start_date'] as String?,
      totalWeeks: map['total_weeks'] as int?,
    );
  }
}

/// 学期配置数据
class SemesterConfigData {
  final int? id;
  final String name;
  final String startDate;
  final int totalWeeks;
  final int isActive;

  SemesterConfigData({
    this.id,
    required this.name,
    required this.startDate,
    required this.totalWeeks,
    required this.isActive,
  });

  factory SemesterConfigData.fromMap(Map<String, dynamic> map) {
    return SemesterConfigData(
      id: map['id'] as int?,
      name: map['name'] as String,
      startDate: map['start_date'] as String,
      totalWeeks: map['total_weeks'] as int,
      isActive: map['is_active'] as int,
    );
  }
}

// =============================================================================
// Companion 类型（用于插入/更新）
// =============================================================================

class CoursesCompanion {
  final String? id;
  final String? name;
  final String? teacher;
  final String? location;
  final int? color;
  final String? scheduleId;

  CoursesCompanion({
    this.id,
    this.name,
    this.teacher,
    this.location,
    this.color,
    this.scheduleId,
  });
}

class TimeDetailsCompanion {
  final int? id;
  final String? courseId;
  final int? dayOfWeek;
  final int? startPeriod;
  final int? duration;
  final String? weeks;
  final String? singleOrDouble;

  TimeDetailsCompanion({
    this.id,
    this.courseId,
    this.dayOfWeek,
    this.startPeriod,
    this.duration,
    this.weeks,
    this.singleOrDouble,
  });
}

class SchedulesCompanion {
  final String? id;
  final String? name;
  final bool? isDefault;
  final DateTime? createdAt;
  final String? displayedWeekdays;
  final int? maxCoursesPerDay;
  final String? startDate;
  final int? totalWeeks;

  SchedulesCompanion({
    this.id,
    this.name,
    this.isDefault,
    this.createdAt,
    this.displayedWeekdays,
    this.maxCoursesPerDay,
    this.startDate,
    this.totalWeeks,
  });
}

class SemesterConfigsCompanion {
  final int? id;
  final String? name;
  final String? startDate;
  final int? totalWeeks;
  final int? isActive;

  SemesterConfigsCompanion({
    this.id,
    this.name,
    this.startDate,
    this.totalWeeks,
    this.isActive,
  });
}

// =============================================================================
// 数据库实现
// =============================================================================

/// sqflite 跨平台数据库实现
///
/// 使用 DAO 模式将数据库操作拆分为独立的表级访问对象。
/// 通过 [courses]、[schedules]、[semesterConfigs] 访问各表操作。
class AppDatabase {
  static Database? _database;
  static const String _dbName = 'flass.db';
  static const int _dbVersion = 5;

  /// 数据变更通知器
  final StreamController<void> _changeNotifier =
      StreamController<void>.broadcast();

  /// 课程 DAO
  late final CourseDao courses;

  /// 课表 DAO
  late final ScheduleDao schedules;

  /// 学期配置 DAO
  late final SemesterConfigDao semesterConfigs;

  AppDatabase() {
    courses = CourseDao(() => _getDbBlocking(), _notifyChange);
    schedules = ScheduleDao(() => _getDbBlocking(), _notifyChange);
    semesterConfigs = SemesterConfigDao(() => _getDbBlocking());
  }

  /// 获取数据库实例（同步版本，假设已初始化）
  Database _getDbBlocking() {
    if (_database == null) {
      throw StateError('Database not initialized. Call init() first.');
    }
    return _database!;
  }

  /// 获取数据变更流
  Stream<void> get changeStream => _changeNotifier.stream;

  /// 通知数据变更
  void _notifyChange() {
    if (!_changeNotifier.isClosed) {
      _changeNotifier.add(null);
    }
  }

  /// 初始化数据库
  Future<void> init() async {
    if (_database != null) return;
    final documentsDir = await getApplicationDocumentsDirectory();
    final path = p.join(documentsDir.path, _dbName);

    _database = await openDatabase(
      path,
      version: _dbVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// 创建数据库表
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE courses (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        teacher TEXT NOT NULL,
        location TEXT,
        color INTEGER NOT NULL,
        schedule_id TEXT,
        metadata TEXT DEFAULT '{}'
      )
    ''');

    await db.execute('''
      CREATE TABLE time_details (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        course_id TEXT NOT NULL,
        day_of_week INTEGER NOT NULL,
        start_period INTEGER NOT NULL,
        duration INTEGER NOT NULL DEFAULT 1,
        weeks TEXT NOT NULL,
        single_or_double TEXT NOT NULL DEFAULT 'all',
        FOREIGN KEY (course_id) REFERENCES courses(id) ON DELETE CASCADE
      )
    ''');

    await db.execute('''
      CREATE TABLE schedules (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        displayed_weekdays TEXT DEFAULT '[1,2,3,4,5]',
        max_courses_per_day INTEGER DEFAULT 12,
        start_date TEXT,
        total_weeks INTEGER DEFAULT 20
      )
    ''');

    await db.execute('''
      CREATE TABLE semester_configs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        start_date TEXT NOT NULL,
        total_weeks INTEGER NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 0
      )
    ''');

    // 创建索引
    await db.execute(
        'CREATE INDEX idx_courses_schedule_id ON courses(schedule_id)');
    await db.execute(
        'CREATE INDEX idx_time_details_course_id ON time_details(course_id)');
    await db.execute(
        'CREATE INDEX idx_schedules_is_default ON schedules(is_default)');
  }

  /// 数据库升级
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE IF NOT EXISTS schedules (
          id TEXT PRIMARY KEY,
          name TEXT NOT NULL,
          is_default INTEGER NOT NULL DEFAULT 0,
          created_at TEXT NOT NULL
        )
      ''');
      try {
        await db.execute('ALTER TABLE courses ADD COLUMN schedule_id TEXT');
      } catch (e) {
        // Column might already exist
      }
    }
    if (oldVersion < 3) {
      try {
        await db.execute(
            'ALTER TABLE schedules ADD COLUMN displayed_weekdays TEXT DEFAULT "[1,2,3,4,5]"');
      } catch (e) {
        // Column might already exist
      }
      try {
        await db.execute(
            'ALTER TABLE schedules ADD COLUMN max_courses_per_day INTEGER DEFAULT 12');
      } catch (e) {
        // Column might already exist
      }
    }
    if (oldVersion < 4) {
      try {
        await db.execute('ALTER TABLE schedules ADD COLUMN start_date TEXT');
      } catch (e) {
        // Column might already exist
      }
      try {
        await db.execute(
            'ALTER TABLE schedules ADD COLUMN total_weeks INTEGER DEFAULT 20');
      } catch (e) {
        // Column might already exist
      }
    }
    if (oldVersion < 5) {
      // 添加课程元数据字段，支持未来扩展
      try {
        await db.execute(
            'ALTER TABLE courses ADD COLUMN metadata TEXT DEFAULT "{}"');
      } catch (e) {
        // Column might already exist
      }
    }
  }

  // ===========================================================================
  // 便捷方法（委托给 DAO）
  // ===========================================================================

  /// 监听所有课程变化
  Stream<List<CourseWithDetails>> watchAllCourses() {
    return courses.watchAll(changeStream);
  }

  /// 插入课程及时间段（便捷方法）
  Future<void> insertCourseWithDetails(
    String id,
    String name,
    String teacher,
    String? location,
    int color,
    List<TimeDetailsCompanion> details, {
    String? scheduleId,
    String metadata = '{}',
  }) async {
    await courses.insertWithDetails(
      id, name, teacher, location, color, details,
      scheduleId: scheduleId, metadata: metadata,
    );
  }

  /// 更新课程及时间段（便捷方法）
  Future<void> updateCourseWithDetails(
    String id,
    String name,
    String teacher,
    String? location,
    int color,
    List<TimeDetailsCompanion> details, {
    String metadata = '{}',
  }) async {
    await courses.updateWithDetails(
      id, name, teacher, location, color, details,
      metadata: metadata,
    );
  }

  /// 删除课程（便捷方法）
  Future<void> deleteCourse(String id) async {
    await courses.delete(id);
  }

  /// 删除课表下的所有课程（便捷方法）
  Future<void> deleteCoursesByScheduleId(String scheduleId) async {
    await courses.deleteByScheduleId(scheduleId);
  }

  /// 创建课表（便捷方法）
  Future<void> createSchedule(SchedulesCompanion schedule) async {
    await schedules.create(schedule);
  }

  /// 获取所有课表（便捷方法）
  Future<List<ScheduleData>> getAllSchedules() async {
    return schedules.getAll();
  }

  /// 获取默认课表（便捷方法）
  Future<ScheduleData?> getDefaultSchedule() async {
    return schedules.getDefault();
  }

  /// 重命名课表（便捷方法）
  Future<void> renameSchedule(String id, String newName) async {
    await schedules.rename(id, newName);
  }

  /// 删除课表（便捷方法）
  Future<void> deleteSchedule(String id) async {
    await schedules.delete(id);
  }

  /// 设置默认课表（便捷方法）
  Future<void> setDefaultSchedule(String id) async {
    await schedules.setDefault(id);
  }

  /// 更新课表（便捷方法）
  Future<void> updateSchedule(String id, SchedulesCompanion values) async {
    await schedules.update(id, values);
  }

  /// 获取活跃学期配置（便捷方法）
  Future<SemesterConfigData?> getActiveSemester() async {
    return semesterConfigs.getActive();
  }

  /// 设置学期配置（便捷方法）
  Future<void> setSemesterConfig(SemesterConfigsCompanion config) async {
    await semesterConfigs.set(config);
  }

  /// 检查是否有课程数据（便捷方法）
  Future<bool> hasCourses() async {
    return courses.hasAny();
  }

  // ===========================================================================
  // 工具方法
  // ===========================================================================

  /// 关闭数据库
  Future<void> close() async {
    await _changeNotifier.close();
    if (_database != null) {
      await _database!.close();
      _database = null;
    }
  }

  /// 清除所有数据
  Future<void> clearAll() async {
    final db = _getDbBlocking();
    await db.delete('time_details');
    await db.delete('courses');
    await db.delete('schedules');
    await db.delete('semester_configs');
  }
}
