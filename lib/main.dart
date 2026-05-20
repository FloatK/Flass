import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:drift/native.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

import 'app.dart';
import 'data/datasources/database.dart';
import 'data/datasources/sample_data.dart';
import 'data/repositories/course_repository_impl.dart';
import 'data/repositories/schedule_repository_impl.dart';
import 'presentation/providers/course_provider.dart';
import 'presentation/providers/schedule_provider.dart';
import 'presentation/providers/semester_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appDir = await getApplicationDocumentsDirectory();
  final dbPath = p.join(appDir.path, 'flwakeup.db');
  final db = AppDatabase(NativeDatabase(File(dbPath)));

  await _initSampleData(db);

  await _ensureDefaultSchedule(db);

  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        courseRepositoryProvider.overrideWithValue(CourseRepositoryImpl(db)),
        scheduleRepositoryProvider
            .overrideWithValue(ScheduleRepositoryImpl(db)),
      ],
      child: const App(),
    ),
  );
}

Future<void> _initSampleData(AppDatabase db) async {
  final count = await (db.select(db.courses)..limit(1)).get();
  if (count.isEmpty) {
    await insertSampleData(db);
  }
}

Future<void> _ensureDefaultSchedule(AppDatabase db) async {
  final existing = await db.getDefaultSchedule();
  if (existing == null) {
    await db.createSchedule(
      SchedulesCompanion(
        id: const Value('default'),
        name: const Value('课表1'),
        isDefault: const Value(true),
        createdAt: Value(DateTime.now()),
      ),
    );
  }
}
