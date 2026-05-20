import 'package:drift/drift.dart';

part 'database.g.dart';

class Courses extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  TextColumn get teacher => text()();
  TextColumn get location => text().nullable()();
  IntColumn get color => integer()();
  TextColumn get scheduleId => text().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class TimeDetails extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get courseId =>
      text().references(Courses, #id, onDelete: KeyAction.cascade)();
  IntColumn get dayOfWeek => integer()();
  IntColumn get startPeriod => integer()();
  IntColumn get duration => integer()();
  TextColumn get weeks => text()();
  TextColumn get singleOrDouble => text()();
}

class Schedules extends Table {
  TextColumn get id => text()();
  TextColumn get name => text()();
  BoolColumn get isDefault => boolean()();
  DateTimeColumn get createdAt => dateTime()();
  TextColumn get displayedWeekdays => text().nullable()();
  IntColumn get maxCoursesPerDay => integer().nullable()();

  @override
  Set<Column> get primaryKey => {id};
}

class SemesterConfigs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get startDate => text()();
  IntColumn get totalWeeks => integer()();
  IntColumn get isActive => integer()();
}

@DriftDatabase(tables: [Courses, TimeDetails, Schedules, SemesterConfigs])
class AppDatabase extends _$AppDatabase {
  AppDatabase(super.e);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (m, from, to) async {
          if (from < 2) {
            await m.createTable(schedules);
            await m.addColumn(courses, courses.scheduleId);
          }
          if (from < 3) {
            await m.addColumn(schedules, schedules.displayedWeekdays);
            await m.addColumn(schedules, schedules.maxCoursesPerDay);
          }
        },
      );

  Future<void> insertCourseWithDetails(
    String id,
    String name,
    String teacher,
    String? location,
    int color,
    List<TimeDetailsCompanion> details, {
    String? scheduleId,
  }) async {
    await transaction(() async {
      await into(courses).insert(
        CoursesCompanion(
          id: Value(id),
          name: Value(name),
          teacher: Value(teacher),
          location: Value(location),
          color: Value(color),
          scheduleId: Value(scheduleId),
        ),
      );
      for (final detail in details) {
        await into(timeDetails).insert(
          detail.copyWith(courseId: Value(id)),
        );
      }
    });
  }

  Future<void> updateCourseWithDetails(
    String id,
    String name,
    String teacher,
    String? location,
    int color,
    List<TimeDetailsCompanion> details,
  ) async {
    await transaction(() async {
      await (update(courses)..where((t) => t.id.equals(id))).write(
        CoursesCompanion(
          name: Value(name),
          teacher: Value(teacher),
          location: Value(location),
          color: Value(color),
        ),
      );
      await (delete(timeDetails)..where((t) => t.courseId.equals(id))).go();
      for (final detail in details) {
        await into(timeDetails).insert(
          detail.copyWith(courseId: Value(id)),
        );
      }
    });
  }

  Future<void> deleteCourse(String id) async {
    await transaction(() async {
      await (delete(timeDetails)..where((t) => t.courseId.equals(id))).go();
      await (delete(courses)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> deleteCoursesByScheduleId(String scheduleId) async {
    final ids = await (selectOnly(courses)
          ..addColumns([courses.id])
          ..where(courses.scheduleId.equals(scheduleId)))
        .map((row) => row.read(courses.id))
        .get();
    for (final id in ids) {
      await deleteCourse(id!);
    }
  }

  Stream<List<CourseWithDetails>> watchAllCourses() {
    final query = select(courses).join([
      leftOuterJoin(timeDetails, timeDetails.courseId.equalsExp(courses.id)),
    ]);

    return query.watch().map((rows) {
      final Map<String, CourseWithDetails> grouped = {};
      for (final row in rows) {
        final course = row.readTable(courses);
        final detail = row.readTableOrNull(timeDetails);
        grouped.putIfAbsent(course.id, () => CourseWithDetails(course: course));
        if (detail != null) {
          grouped[course.id]!.details.add(detail);
        }
      }
      return grouped.values.toList();
    });
  }

  Future<SemesterConfigData?> getActiveSemester() {
    return (select(semesterConfigs)
          ..where((t) => t.isActive.equals(1))
          ..limit(1))
        .getSingleOrNull();
  }

  Future<void> setSemesterConfig(SemesterConfigsCompanion config) async {
    await transaction(() async {
      await (update(semesterConfigs)..where((t) => t.isActive.equals(1)))
          .write(const SemesterConfigsCompanion(isActive: Value(0)));
      await into(semesterConfigs).insert(
        config.copyWith(isActive: const Value(1)),
      );
    });
  }

  // ---- Schedule operations ----

  Future<void> createSchedule(SchedulesCompanion schedule) async {
    await into(schedules).insert(schedule);
  }

  Future<List<ScheduleData>> getAllSchedules() {
    return select(schedules).get();
  }

  Future<ScheduleData?> getDefaultSchedule() {
    return (select(schedules)..where((t) => t.isDefault.equals(true)))
        .getSingleOrNull();
  }

  Future<void> renameSchedule(String id, String newName) {
    return (update(schedules)..where((t) => t.id.equals(id)))
        .write(SchedulesCompanion(name: Value(newName)));
  }

  Future<void> deleteSchedule(String id) async {
    await transaction(() async {
      await (update(courses)..where((t) => t.scheduleId.equals(id)))
          .write(const CoursesCompanion(scheduleId: Value(null)));
      await (delete(schedules)..where((t) => t.id.equals(id))).go();
    });
  }

  Future<void> setDefaultSchedule(String id) async {
    await transaction(() async {
      await (update(schedules)..where((t) => t.isDefault.equals(true)))
          .write(const SchedulesCompanion(isDefault: Value(false)));
      await (update(schedules)..where((t) => t.id.equals(id)))
          .write(const SchedulesCompanion(isDefault: Value(true)));
    });
  }

  Future<void> updateSchedule(String id, SchedulesCompanion values) async {
    await (update(schedules)..where((t) => t.id.equals(id))).write(values);
  }
}

class CourseWithDetails {
  final Course course;
  final List<TimeDetail> details;

  CourseWithDetails({required this.course, List<TimeDetail>? details})
      : details = details ?? [];
}

// Extend the generated Course class name to avoid conflict with freezed
typedef CourseData = Course;
typedef TimeDetailData = TimeDetail;
typedef SemesterConfigData = SemesterConfig;
typedef ScheduleData = Schedule;
