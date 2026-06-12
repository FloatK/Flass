import 'package:uuid/uuid.dart';

import 'database.dart';

Future<void> insertSampleData(AppDatabase db) async {
  const uuid = Uuid();

  final semesterStart = DateTime(2026, 2, 17);
  await db.setSemesterConfig(
    SemesterConfigsCompanion(
      name: '2025-2026 第二学期',
      startDate: semesterStart.toIso8601String(),
      totalWeeks: 20,
      isActive: 1,
    ),
  );

  await db.insertCourseWithDetails(
    uuid.v4(),
    '高等数学',
    '张教授',
    '教一 301',
    0xFF2196F3,
    [
      TimeDetailsCompanion(
        dayOfWeek: 1,
        startPeriod: 1,
        duration: 2,
        weeks: '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16',
        singleOrDouble: 'all',
      ),
      TimeDetailsCompanion(
        dayOfWeek: 3,
        startPeriod: 3,
        duration: 2,
        weeks: '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16',
        singleOrDouble: 'all',
      ),
    ],
  );

  await db.insertCourseWithDetails(
    uuid.v4(),
    '大学英语',
    '李老师',
    '教二 205',
    0xFF4CAF50,
    [
      TimeDetailsCompanion(
        dayOfWeek: 2,
        startPeriod: 1,
        duration: 2,
        weeks: '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16',
        singleOrDouble: 'all',
      ),
      TimeDetailsCompanion(
        dayOfWeek: 4,
        startPeriod: 1,
        duration: 2,
        weeks: '1,3,5,7,9,11,13,15',
        singleOrDouble: 'single',
      ),
    ],
  );

  await db.insertCourseWithDetails(
    uuid.v4(),
    '数据结构',
    '王教授',
    '教三 102',
    0xFFFF9800,
    [
      TimeDetailsCompanion(
        dayOfWeek: 1,
        startPeriod: 5,
        duration: 2,
        weeks: '1,2,3,4,5,6,7,8,9,10,11,12',
        singleOrDouble: 'all',
      ),
      TimeDetailsCompanion(
        dayOfWeek: 5,
        startPeriod: 3,
        duration: 3,
        weeks: '1,2,3,4,5,6,7,8,9,10,11,12',
        singleOrDouble: 'all',
      ),
    ],
  );

  await db.insertCourseWithDetails(
    uuid.v4(),
    '体育',
    '赵教练',
    '体育馆',
    0xFFE91E63,
    [
      TimeDetailsCompanion(
        dayOfWeek: 3,
        startPeriod: 7,
        duration: 2,
        weeks: '2,4,6,8,10,12,14,16',
        singleOrDouble: 'double',
      ),
    ],
  );

  await db.insertCourseWithDetails(
    uuid.v4(),
    '马克思主义原理',
    '陈教授',
    '教一 201',
    0xFF9C27B0,
    [
      TimeDetailsCompanion(
        dayOfWeek: 2,
        startPeriod: 5,
        duration: 2,
        weeks: '1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16',
        singleOrDouble: 'all',
      ),
    ],
  );
}
