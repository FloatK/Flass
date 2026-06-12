import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'app.dart';
import 'core/config/action_item.dart';
import 'core/utils/edu_system_webview_controller.dart';
import 'core/utils/format_registry.dart';
import 'data/datasources/database.dart';
import 'data/datasources/sample_data.dart';
import 'data/repositories/course_repository_impl.dart';
import 'data/repositories/schedule_repository_impl.dart';
import 'presentation/providers/course_provider.dart';
import 'presentation/providers/schedule_provider.dart';
import 'presentation/providers/semester_provider.dart';
import 'presentation/providers/theme_provider.dart';
import 'presentation/widgets/export_import_dialogs.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 初始化教务系统解析器注册表
  EduSystemWebViewController.initParserRegistry();

  // 初始化导入/导出格式注册表
  initDefaultFormats();

  // 初始化动作项注册表
  _initActionItems();

  // 使用 sqflite 数据库（跨平台，支持 OHOS）
  final db = AppDatabase();
  await db.init();

  await _initSampleData(db);
  await _ensureDefaultSchedule(db);

  final themeSettings = await loadThemeSettings();

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        courseRepositoryProvider.overrideWithValue(CourseRepositoryImpl(db)),
        scheduleRepositoryProvider
            .overrideWithValue(ScheduleRepositoryImpl(db)),
        themeSettingsProvider.overrideWith((ref) => themeSettings),
      ],
      child: const App(),
    ),
  );
}

void _initActionItems() {
  initDefaultActionItems(
    onImportTimetable: (context) => context.push('/import'),
    onExportTimetable: (context) {
      // 需要从 Provider 获取课程列表，这里使用空列表作为占位
      // 实际使用时会在 week_schedule_page.dart 中处理
    },
    onImportJson: (context) => ImportFromTextDialog.show(context),
    onPreviousWeek: (context) {
      // 由 week_schedule_page.dart 处理
    },
    onNextWeek: (context) {
      // 由 week_schedule_page.dart 处理
    },
    onGoToCurrentWeek: (context) {
      // 由 week_schedule_page.dart 处理
    },
    onSelectTimetable: (context) => context.push('/schedules'),
    onThemeSettings: (context) {
      // 由 week_schedule_page.dart 处理
    },
    onSwapCourse: (context) {
      // 由 week_schedule_page.dart 处理
    },
  );
}

Future<void> _initSampleData(AppDatabase db) async {
  final hasCourses = await db.hasCourses();
  if (!hasCourses) {
    await insertSampleData(db);
  }
}

Future<void> _ensureDefaultSchedule(AppDatabase db) async {
  final existing = await db.getDefaultSchedule();
  if (existing == null) {
    await db.createSchedule(
      SchedulesCompanion(
        id: 'default',
        name: '课表1',
        isDefault: true,
        createdAt: DateTime.now(),
      ),
    );
  }
}
