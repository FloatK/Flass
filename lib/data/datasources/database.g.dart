// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $CoursesTable extends Courses with TableInfo<$CoursesTable, Course> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $CoursesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _teacherMeta =
      const VerificationMeta('teacher');
  @override
  late final GeneratedColumn<String> teacher = GeneratedColumn<String>(
      'teacher', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _locationMeta =
      const VerificationMeta('location');
  @override
  late final GeneratedColumn<String> location = GeneratedColumn<String>(
      'location', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _colorMeta = const VerificationMeta('color');
  @override
  late final GeneratedColumn<int> color = GeneratedColumn<int>(
      'color', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _scheduleIdMeta =
      const VerificationMeta('scheduleId');
  @override
  late final GeneratedColumn<String> scheduleId = GeneratedColumn<String>(
      'schedule_id', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, teacher, location, color, scheduleId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'courses';
  @override
  VerificationContext validateIntegrity(Insertable<Course> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('teacher')) {
      context.handle(_teacherMeta,
          teacher.isAcceptableOrUnknown(data['teacher']!, _teacherMeta));
    } else if (isInserting) {
      context.missing(_teacherMeta);
    }
    if (data.containsKey('location')) {
      context.handle(_locationMeta,
          location.isAcceptableOrUnknown(data['location']!, _locationMeta));
    }
    if (data.containsKey('color')) {
      context.handle(
          _colorMeta, color.isAcceptableOrUnknown(data['color']!, _colorMeta));
    } else if (isInserting) {
      context.missing(_colorMeta);
    }
    if (data.containsKey('schedule_id')) {
      context.handle(
          _scheduleIdMeta,
          scheduleId.isAcceptableOrUnknown(
              data['schedule_id']!, _scheduleIdMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Course map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Course(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      teacher: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}teacher'])!,
      location: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}location']),
      color: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}color'])!,
      scheduleId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}schedule_id']),
    );
  }

  @override
  $CoursesTable createAlias(String alias) {
    return $CoursesTable(attachedDatabase, alias);
  }
}

class Course extends DataClass implements Insertable<Course> {
  final String id;
  final String name;
  final String teacher;
  final String? location;
  final int color;
  final String? scheduleId;
  const Course(
      {required this.id,
      required this.name,
      required this.teacher,
      this.location,
      required this.color,
      this.scheduleId});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['teacher'] = Variable<String>(teacher);
    if (!nullToAbsent || location != null) {
      map['location'] = Variable<String>(location);
    }
    map['color'] = Variable<int>(color);
    if (!nullToAbsent || scheduleId != null) {
      map['schedule_id'] = Variable<String>(scheduleId);
    }
    return map;
  }

  factory Course.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Course(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      teacher: serializer.fromJson<String>(json['teacher']),
      location: serializer.fromJson<String?>(json['location']),
      color: serializer.fromJson<int>(json['color']),
      scheduleId: serializer.fromJson<String?>(json['scheduleId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'teacher': serializer.toJson<String>(teacher),
      'location': serializer.toJson<String?>(location),
      'color': serializer.toJson<int>(color),
      'scheduleId': serializer.toJson<String?>(scheduleId),
    };
  }

  Course copyWith(
          {String? id,
          String? name,
          String? teacher,
          Value<String?> location = const Value.absent(),
          int? color,
          Value<String?> scheduleId = const Value.absent()}) =>
      Course(
        id: id ?? this.id,
        name: name ?? this.name,
        teacher: teacher ?? this.teacher,
        location: location.present ? location.value : this.location,
        color: color ?? this.color,
        scheduleId: scheduleId.present ? scheduleId.value : this.scheduleId,
      );
  Course copyWithCompanion(CoursesCompanion data) {
    return Course(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      teacher: data.teacher.present ? data.teacher.value : this.teacher,
      location: data.location.present ? data.location.value : this.location,
      color: data.color.present ? data.color.value : this.color,
      scheduleId:
          data.scheduleId.present ? data.scheduleId.value : this.scheduleId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Course(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('location: $location, ')
          ..write('color: $color, ')
          ..write('scheduleId: $scheduleId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, teacher, location, color, scheduleId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Course &&
          other.id == this.id &&
          other.name == this.name &&
          other.teacher == this.teacher &&
          other.location == this.location &&
          other.color == this.color &&
          other.scheduleId == this.scheduleId);
}

class CoursesCompanion extends UpdateCompanion<Course> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> teacher;
  final Value<String?> location;
  final Value<int> color;
  final Value<String?> scheduleId;
  final Value<int> rowid;
  const CoursesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.teacher = const Value.absent(),
    this.location = const Value.absent(),
    this.color = const Value.absent(),
    this.scheduleId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  CoursesCompanion.insert({
    required String id,
    required String name,
    required String teacher,
    this.location = const Value.absent(),
    required int color,
    this.scheduleId = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        teacher = Value(teacher),
        color = Value(color);
  static Insertable<Course> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? teacher,
    Expression<String>? location,
    Expression<int>? color,
    Expression<String>? scheduleId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (teacher != null) 'teacher': teacher,
      if (location != null) 'location': location,
      if (color != null) 'color': color,
      if (scheduleId != null) 'schedule_id': scheduleId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  CoursesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? teacher,
      Value<String?>? location,
      Value<int>? color,
      Value<String?>? scheduleId,
      Value<int>? rowid}) {
    return CoursesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      teacher: teacher ?? this.teacher,
      location: location ?? this.location,
      color: color ?? this.color,
      scheduleId: scheduleId ?? this.scheduleId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (teacher.present) {
      map['teacher'] = Variable<String>(teacher.value);
    }
    if (location.present) {
      map['location'] = Variable<String>(location.value);
    }
    if (color.present) {
      map['color'] = Variable<int>(color.value);
    }
    if (scheduleId.present) {
      map['schedule_id'] = Variable<String>(scheduleId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('CoursesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('teacher: $teacher, ')
          ..write('location: $location, ')
          ..write('color: $color, ')
          ..write('scheduleId: $scheduleId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TimeDetailsTable extends TimeDetails
    with TableInfo<$TimeDetailsTable, TimeDetail> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TimeDetailsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _courseIdMeta =
      const VerificationMeta('courseId');
  @override
  late final GeneratedColumn<String> courseId = GeneratedColumn<String>(
      'course_id', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: true,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'REFERENCES courses (id) ON DELETE CASCADE'));
  static const VerificationMeta _dayOfWeekMeta =
      const VerificationMeta('dayOfWeek');
  @override
  late final GeneratedColumn<int> dayOfWeek = GeneratedColumn<int>(
      'day_of_week', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _startPeriodMeta =
      const VerificationMeta('startPeriod');
  @override
  late final GeneratedColumn<int> startPeriod = GeneratedColumn<int>(
      'start_period', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _durationMeta =
      const VerificationMeta('duration');
  @override
  late final GeneratedColumn<int> duration = GeneratedColumn<int>(
      'duration', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _weeksMeta = const VerificationMeta('weeks');
  @override
  late final GeneratedColumn<String> weeks = GeneratedColumn<String>(
      'weeks', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _singleOrDoubleMeta =
      const VerificationMeta('singleOrDouble');
  @override
  late final GeneratedColumn<String> singleOrDouble = GeneratedColumn<String>(
      'single_or_double', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, courseId, dayOfWeek, startPeriod, duration, weeks, singleOrDouble];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'time_details';
  @override
  VerificationContext validateIntegrity(Insertable<TimeDetail> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('course_id')) {
      context.handle(_courseIdMeta,
          courseId.isAcceptableOrUnknown(data['course_id']!, _courseIdMeta));
    } else if (isInserting) {
      context.missing(_courseIdMeta);
    }
    if (data.containsKey('day_of_week')) {
      context.handle(
          _dayOfWeekMeta,
          dayOfWeek.isAcceptableOrUnknown(
              data['day_of_week']!, _dayOfWeekMeta));
    } else if (isInserting) {
      context.missing(_dayOfWeekMeta);
    }
    if (data.containsKey('start_period')) {
      context.handle(
          _startPeriodMeta,
          startPeriod.isAcceptableOrUnknown(
              data['start_period']!, _startPeriodMeta));
    } else if (isInserting) {
      context.missing(_startPeriodMeta);
    }
    if (data.containsKey('duration')) {
      context.handle(_durationMeta,
          duration.isAcceptableOrUnknown(data['duration']!, _durationMeta));
    } else if (isInserting) {
      context.missing(_durationMeta);
    }
    if (data.containsKey('weeks')) {
      context.handle(
          _weeksMeta, weeks.isAcceptableOrUnknown(data['weeks']!, _weeksMeta));
    } else if (isInserting) {
      context.missing(_weeksMeta);
    }
    if (data.containsKey('single_or_double')) {
      context.handle(
          _singleOrDoubleMeta,
          singleOrDouble.isAcceptableOrUnknown(
              data['single_or_double']!, _singleOrDoubleMeta));
    } else if (isInserting) {
      context.missing(_singleOrDoubleMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TimeDetail map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TimeDetail(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      courseId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}course_id'])!,
      dayOfWeek: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}day_of_week'])!,
      startPeriod: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}start_period'])!,
      duration: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}duration'])!,
      weeks: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}weeks'])!,
      singleOrDouble: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}single_or_double'])!,
    );
  }

  @override
  $TimeDetailsTable createAlias(String alias) {
    return $TimeDetailsTable(attachedDatabase, alias);
  }
}

class TimeDetail extends DataClass implements Insertable<TimeDetail> {
  final int id;
  final String courseId;
  final int dayOfWeek;
  final int startPeriod;
  final int duration;
  final String weeks;
  final String singleOrDouble;
  const TimeDetail(
      {required this.id,
      required this.courseId,
      required this.dayOfWeek,
      required this.startPeriod,
      required this.duration,
      required this.weeks,
      required this.singleOrDouble});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['course_id'] = Variable<String>(courseId);
    map['day_of_week'] = Variable<int>(dayOfWeek);
    map['start_period'] = Variable<int>(startPeriod);
    map['duration'] = Variable<int>(duration);
    map['weeks'] = Variable<String>(weeks);
    map['single_or_double'] = Variable<String>(singleOrDouble);
    return map;
  }

  factory TimeDetail.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TimeDetail(
      id: serializer.fromJson<int>(json['id']),
      courseId: serializer.fromJson<String>(json['courseId']),
      dayOfWeek: serializer.fromJson<int>(json['dayOfWeek']),
      startPeriod: serializer.fromJson<int>(json['startPeriod']),
      duration: serializer.fromJson<int>(json['duration']),
      weeks: serializer.fromJson<String>(json['weeks']),
      singleOrDouble: serializer.fromJson<String>(json['singleOrDouble']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'courseId': serializer.toJson<String>(courseId),
      'dayOfWeek': serializer.toJson<int>(dayOfWeek),
      'startPeriod': serializer.toJson<int>(startPeriod),
      'duration': serializer.toJson<int>(duration),
      'weeks': serializer.toJson<String>(weeks),
      'singleOrDouble': serializer.toJson<String>(singleOrDouble),
    };
  }

  TimeDetail copyWith(
          {int? id,
          String? courseId,
          int? dayOfWeek,
          int? startPeriod,
          int? duration,
          String? weeks,
          String? singleOrDouble}) =>
      TimeDetail(
        id: id ?? this.id,
        courseId: courseId ?? this.courseId,
        dayOfWeek: dayOfWeek ?? this.dayOfWeek,
        startPeriod: startPeriod ?? this.startPeriod,
        duration: duration ?? this.duration,
        weeks: weeks ?? this.weeks,
        singleOrDouble: singleOrDouble ?? this.singleOrDouble,
      );
  TimeDetail copyWithCompanion(TimeDetailsCompanion data) {
    return TimeDetail(
      id: data.id.present ? data.id.value : this.id,
      courseId: data.courseId.present ? data.courseId.value : this.courseId,
      dayOfWeek: data.dayOfWeek.present ? data.dayOfWeek.value : this.dayOfWeek,
      startPeriod:
          data.startPeriod.present ? data.startPeriod.value : this.startPeriod,
      duration: data.duration.present ? data.duration.value : this.duration,
      weeks: data.weeks.present ? data.weeks.value : this.weeks,
      singleOrDouble: data.singleOrDouble.present
          ? data.singleOrDouble.value
          : this.singleOrDouble,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TimeDetail(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('duration: $duration, ')
          ..write('weeks: $weeks, ')
          ..write('singleOrDouble: $singleOrDouble')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, courseId, dayOfWeek, startPeriod, duration, weeks, singleOrDouble);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TimeDetail &&
          other.id == this.id &&
          other.courseId == this.courseId &&
          other.dayOfWeek == this.dayOfWeek &&
          other.startPeriod == this.startPeriod &&
          other.duration == this.duration &&
          other.weeks == this.weeks &&
          other.singleOrDouble == this.singleOrDouble);
}

class TimeDetailsCompanion extends UpdateCompanion<TimeDetail> {
  final Value<int> id;
  final Value<String> courseId;
  final Value<int> dayOfWeek;
  final Value<int> startPeriod;
  final Value<int> duration;
  final Value<String> weeks;
  final Value<String> singleOrDouble;
  const TimeDetailsCompanion({
    this.id = const Value.absent(),
    this.courseId = const Value.absent(),
    this.dayOfWeek = const Value.absent(),
    this.startPeriod = const Value.absent(),
    this.duration = const Value.absent(),
    this.weeks = const Value.absent(),
    this.singleOrDouble = const Value.absent(),
  });
  TimeDetailsCompanion.insert({
    this.id = const Value.absent(),
    required String courseId,
    required int dayOfWeek,
    required int startPeriod,
    required int duration,
    required String weeks,
    required String singleOrDouble,
  })  : courseId = Value(courseId),
        dayOfWeek = Value(dayOfWeek),
        startPeriod = Value(startPeriod),
        duration = Value(duration),
        weeks = Value(weeks),
        singleOrDouble = Value(singleOrDouble);
  static Insertable<TimeDetail> custom({
    Expression<int>? id,
    Expression<String>? courseId,
    Expression<int>? dayOfWeek,
    Expression<int>? startPeriod,
    Expression<int>? duration,
    Expression<String>? weeks,
    Expression<String>? singleOrDouble,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (courseId != null) 'course_id': courseId,
      if (dayOfWeek != null) 'day_of_week': dayOfWeek,
      if (startPeriod != null) 'start_period': startPeriod,
      if (duration != null) 'duration': duration,
      if (weeks != null) 'weeks': weeks,
      if (singleOrDouble != null) 'single_or_double': singleOrDouble,
    });
  }

  TimeDetailsCompanion copyWith(
      {Value<int>? id,
      Value<String>? courseId,
      Value<int>? dayOfWeek,
      Value<int>? startPeriod,
      Value<int>? duration,
      Value<String>? weeks,
      Value<String>? singleOrDouble}) {
    return TimeDetailsCompanion(
      id: id ?? this.id,
      courseId: courseId ?? this.courseId,
      dayOfWeek: dayOfWeek ?? this.dayOfWeek,
      startPeriod: startPeriod ?? this.startPeriod,
      duration: duration ?? this.duration,
      weeks: weeks ?? this.weeks,
      singleOrDouble: singleOrDouble ?? this.singleOrDouble,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (courseId.present) {
      map['course_id'] = Variable<String>(courseId.value);
    }
    if (dayOfWeek.present) {
      map['day_of_week'] = Variable<int>(dayOfWeek.value);
    }
    if (startPeriod.present) {
      map['start_period'] = Variable<int>(startPeriod.value);
    }
    if (duration.present) {
      map['duration'] = Variable<int>(duration.value);
    }
    if (weeks.present) {
      map['weeks'] = Variable<String>(weeks.value);
    }
    if (singleOrDouble.present) {
      map['single_or_double'] = Variable<String>(singleOrDouble.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TimeDetailsCompanion(')
          ..write('id: $id, ')
          ..write('courseId: $courseId, ')
          ..write('dayOfWeek: $dayOfWeek, ')
          ..write('startPeriod: $startPeriod, ')
          ..write('duration: $duration, ')
          ..write('weeks: $weeks, ')
          ..write('singleOrDouble: $singleOrDouble')
          ..write(')'))
        .toString();
  }
}

class $SchedulesTable extends Schedules
    with TableInfo<$SchedulesTable, Schedule> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchedulesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _displayedWeekdaysMeta =
      const VerificationMeta('displayedWeekdays');
  @override
  late final GeneratedColumn<String> displayedWeekdays =
      GeneratedColumn<String>('displayed_weekdays', aliasedName, true,
          type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _maxCoursesPerDayMeta =
      const VerificationMeta('maxCoursesPerDay');
  @override
  late final GeneratedColumn<int> maxCoursesPerDay = GeneratedColumn<int>(
      'max_courses_per_day', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, isDefault, createdAt, displayedWeekdays, maxCoursesPerDay];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schedules';
  @override
  VerificationContext validateIntegrity(Insertable<Schedule> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    } else if (isInserting) {
      context.missing(_isDefaultMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('displayed_weekdays')) {
      context.handle(
          _displayedWeekdaysMeta,
          displayedWeekdays.isAcceptableOrUnknown(
              data['displayed_weekdays']!, _displayedWeekdaysMeta));
    }
    if (data.containsKey('max_courses_per_day')) {
      context.handle(
          _maxCoursesPerDayMeta,
          maxCoursesPerDay.isAcceptableOrUnknown(
              data['max_courses_per_day']!, _maxCoursesPerDayMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Schedule map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Schedule(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
      displayedWeekdays: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}displayed_weekdays']),
      maxCoursesPerDay: attachedDatabase.typeMapping.read(
          DriftSqlType.int, data['${effectivePrefix}max_courses_per_day']),
    );
  }

  @override
  $SchedulesTable createAlias(String alias) {
    return $SchedulesTable(attachedDatabase, alias);
  }
}

class Schedule extends DataClass implements Insertable<Schedule> {
  final String id;
  final String name;
  final bool isDefault;
  final DateTime createdAt;
  final String? displayedWeekdays;
  final int? maxCoursesPerDay;
  const Schedule(
      {required this.id,
      required this.name,
      required this.isDefault,
      required this.createdAt,
      this.displayedWeekdays,
      this.maxCoursesPerDay});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['is_default'] = Variable<bool>(isDefault);
    map['created_at'] = Variable<DateTime>(createdAt);
    if (!nullToAbsent || displayedWeekdays != null) {
      map['displayed_weekdays'] = Variable<String>(displayedWeekdays);
    }
    if (!nullToAbsent || maxCoursesPerDay != null) {
      map['max_courses_per_day'] = Variable<int>(maxCoursesPerDay);
    }
    return map;
  }

  factory Schedule.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Schedule(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      displayedWeekdays:
          serializer.fromJson<String?>(json['displayedWeekdays']),
      maxCoursesPerDay: serializer.fromJson<int?>(json['maxCoursesPerDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'isDefault': serializer.toJson<bool>(isDefault),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'displayedWeekdays': serializer.toJson<String?>(displayedWeekdays),
      'maxCoursesPerDay': serializer.toJson<int?>(maxCoursesPerDay),
    };
  }

  Schedule copyWith(
          {String? id,
          String? name,
          bool? isDefault,
          DateTime? createdAt,
          Value<String?> displayedWeekdays = const Value.absent(),
          Value<int?> maxCoursesPerDay = const Value.absent()}) =>
      Schedule(
        id: id ?? this.id,
        name: name ?? this.name,
        isDefault: isDefault ?? this.isDefault,
        createdAt: createdAt ?? this.createdAt,
        displayedWeekdays: displayedWeekdays.present
            ? displayedWeekdays.value
            : this.displayedWeekdays,
        maxCoursesPerDay: maxCoursesPerDay.present
            ? maxCoursesPerDay.value
            : this.maxCoursesPerDay,
      );
  Schedule copyWithCompanion(SchedulesCompanion data) {
    return Schedule(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      displayedWeekdays: data.displayedWeekdays.present
          ? data.displayedWeekdays.value
          : this.displayedWeekdays,
      maxCoursesPerDay: data.maxCoursesPerDay.present
          ? data.maxCoursesPerDay.value
          : this.maxCoursesPerDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Schedule(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('displayedWeekdays: $displayedWeekdays, ')
          ..write('maxCoursesPerDay: $maxCoursesPerDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, isDefault, createdAt, displayedWeekdays, maxCoursesPerDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Schedule &&
          other.id == this.id &&
          other.name == this.name &&
          other.isDefault == this.isDefault &&
          other.createdAt == this.createdAt &&
          other.displayedWeekdays == this.displayedWeekdays &&
          other.maxCoursesPerDay == this.maxCoursesPerDay);
}

class SchedulesCompanion extends UpdateCompanion<Schedule> {
  final Value<String> id;
  final Value<String> name;
  final Value<bool> isDefault;
  final Value<DateTime> createdAt;
  final Value<String?> displayedWeekdays;
  final Value<int?> maxCoursesPerDay;
  final Value<int> rowid;
  const SchedulesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.displayedWeekdays = const Value.absent(),
    this.maxCoursesPerDay = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchedulesCompanion.insert({
    required String id,
    required String name,
    required bool isDefault,
    required DateTime createdAt,
    this.displayedWeekdays = const Value.absent(),
    this.maxCoursesPerDay = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        isDefault = Value(isDefault),
        createdAt = Value(createdAt);
  static Insertable<Schedule> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<bool>? isDefault,
    Expression<DateTime>? createdAt,
    Expression<String>? displayedWeekdays,
    Expression<int>? maxCoursesPerDay,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (isDefault != null) 'is_default': isDefault,
      if (createdAt != null) 'created_at': createdAt,
      if (displayedWeekdays != null) 'displayed_weekdays': displayedWeekdays,
      if (maxCoursesPerDay != null) 'max_courses_per_day': maxCoursesPerDay,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchedulesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<bool>? isDefault,
      Value<DateTime>? createdAt,
      Value<String?>? displayedWeekdays,
      Value<int?>? maxCoursesPerDay,
      Value<int>? rowid}) {
    return SchedulesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      displayedWeekdays: displayedWeekdays ?? this.displayedWeekdays,
      maxCoursesPerDay: maxCoursesPerDay ?? this.maxCoursesPerDay,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (displayedWeekdays.present) {
      map['displayed_weekdays'] = Variable<String>(displayedWeekdays.value);
    }
    if (maxCoursesPerDay.present) {
      map['max_courses_per_day'] = Variable<int>(maxCoursesPerDay.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchedulesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('isDefault: $isDefault, ')
          ..write('createdAt: $createdAt, ')
          ..write('displayedWeekdays: $displayedWeekdays, ')
          ..write('maxCoursesPerDay: $maxCoursesPerDay, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SemesterConfigsTable extends SemesterConfigs
    with TableInfo<$SemesterConfigsTable, SemesterConfig> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SemesterConfigsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _startDateMeta =
      const VerificationMeta('startDate');
  @override
  late final GeneratedColumn<String> startDate = GeneratedColumn<String>(
      'start_date', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _totalWeeksMeta =
      const VerificationMeta('totalWeeks');
  @override
  late final GeneratedColumn<int> totalWeeks = GeneratedColumn<int>(
      'total_weeks', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  static const VerificationMeta _isActiveMeta =
      const VerificationMeta('isActive');
  @override
  late final GeneratedColumn<int> isActive = GeneratedColumn<int>(
      'is_active', aliasedName, false,
      type: DriftSqlType.int, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, startDate, totalWeeks, isActive];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'semester_configs';
  @override
  VerificationContext validateIntegrity(Insertable<SemesterConfig> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('start_date')) {
      context.handle(_startDateMeta,
          startDate.isAcceptableOrUnknown(data['start_date']!, _startDateMeta));
    } else if (isInserting) {
      context.missing(_startDateMeta);
    }
    if (data.containsKey('total_weeks')) {
      context.handle(
          _totalWeeksMeta,
          totalWeeks.isAcceptableOrUnknown(
              data['total_weeks']!, _totalWeeksMeta));
    } else if (isInserting) {
      context.missing(_totalWeeksMeta);
    }
    if (data.containsKey('is_active')) {
      context.handle(_isActiveMeta,
          isActive.isAcceptableOrUnknown(data['is_active']!, _isActiveMeta));
    } else if (isInserting) {
      context.missing(_isActiveMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SemesterConfig map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SemesterConfig(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      startDate: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}start_date'])!,
      totalWeeks: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}total_weeks'])!,
      isActive: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}is_active'])!,
    );
  }

  @override
  $SemesterConfigsTable createAlias(String alias) {
    return $SemesterConfigsTable(attachedDatabase, alias);
  }
}

class SemesterConfig extends DataClass implements Insertable<SemesterConfig> {
  final int id;
  final String name;
  final String startDate;
  final int totalWeeks;
  final int isActive;
  const SemesterConfig(
      {required this.id,
      required this.name,
      required this.startDate,
      required this.totalWeeks,
      required this.isActive});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['start_date'] = Variable<String>(startDate);
    map['total_weeks'] = Variable<int>(totalWeeks);
    map['is_active'] = Variable<int>(isActive);
    return map;
  }

  factory SemesterConfig.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SemesterConfig(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      startDate: serializer.fromJson<String>(json['startDate']),
      totalWeeks: serializer.fromJson<int>(json['totalWeeks']),
      isActive: serializer.fromJson<int>(json['isActive']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'startDate': serializer.toJson<String>(startDate),
      'totalWeeks': serializer.toJson<int>(totalWeeks),
      'isActive': serializer.toJson<int>(isActive),
    };
  }

  SemesterConfig copyWith(
          {int? id,
          String? name,
          String? startDate,
          int? totalWeeks,
          int? isActive}) =>
      SemesterConfig(
        id: id ?? this.id,
        name: name ?? this.name,
        startDate: startDate ?? this.startDate,
        totalWeeks: totalWeeks ?? this.totalWeeks,
        isActive: isActive ?? this.isActive,
      );
  SemesterConfig copyWithCompanion(SemesterConfigsCompanion data) {
    return SemesterConfig(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      startDate: data.startDate.present ? data.startDate.value : this.startDate,
      totalWeeks:
          data.totalWeeks.present ? data.totalWeeks.value : this.totalWeeks,
      isActive: data.isActive.present ? data.isActive.value : this.isActive,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SemesterConfig(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('totalWeeks: $totalWeeks, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, startDate, totalWeeks, isActive);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SemesterConfig &&
          other.id == this.id &&
          other.name == this.name &&
          other.startDate == this.startDate &&
          other.totalWeeks == this.totalWeeks &&
          other.isActive == this.isActive);
}

class SemesterConfigsCompanion extends UpdateCompanion<SemesterConfig> {
  final Value<int> id;
  final Value<String> name;
  final Value<String> startDate;
  final Value<int> totalWeeks;
  final Value<int> isActive;
  const SemesterConfigsCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.startDate = const Value.absent(),
    this.totalWeeks = const Value.absent(),
    this.isActive = const Value.absent(),
  });
  SemesterConfigsCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required String startDate,
    required int totalWeeks,
    required int isActive,
  })  : name = Value(name),
        startDate = Value(startDate),
        totalWeeks = Value(totalWeeks),
        isActive = Value(isActive);
  static Insertable<SemesterConfig> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? startDate,
    Expression<int>? totalWeeks,
    Expression<int>? isActive,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (startDate != null) 'start_date': startDate,
      if (totalWeeks != null) 'total_weeks': totalWeeks,
      if (isActive != null) 'is_active': isActive,
    });
  }

  SemesterConfigsCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<String>? startDate,
      Value<int>? totalWeeks,
      Value<int>? isActive}) {
    return SemesterConfigsCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      startDate: startDate ?? this.startDate,
      totalWeeks: totalWeeks ?? this.totalWeeks,
      isActive: isActive ?? this.isActive,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (startDate.present) {
      map['start_date'] = Variable<String>(startDate.value);
    }
    if (totalWeeks.present) {
      map['total_weeks'] = Variable<int>(totalWeeks.value);
    }
    if (isActive.present) {
      map['is_active'] = Variable<int>(isActive.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SemesterConfigsCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('startDate: $startDate, ')
          ..write('totalWeeks: $totalWeeks, ')
          ..write('isActive: $isActive')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $CoursesTable courses = $CoursesTable(this);
  late final $TimeDetailsTable timeDetails = $TimeDetailsTable(this);
  late final $SchedulesTable schedules = $SchedulesTable(this);
  late final $SemesterConfigsTable semesterConfigs =
      $SemesterConfigsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [courses, timeDetails, schedules, semesterConfigs];
  @override
  StreamQueryUpdateRules get streamUpdateRules => const StreamQueryUpdateRules(
        [
          WritePropagation(
            on: TableUpdateQuery.onTableName('courses',
                limitUpdateKind: UpdateKind.delete),
            result: [
              TableUpdate('time_details', kind: UpdateKind.delete),
            ],
          ),
        ],
      );
  @override
  DriftDatabaseOptions get options =>
      const DriftDatabaseOptions(storeDateTimeAsText: true);
}

typedef $$CoursesTableCreateCompanionBuilder = CoursesCompanion Function({
  required String id,
  required String name,
  required String teacher,
  Value<String?> location,
  required int color,
  Value<String?> scheduleId,
  Value<int> rowid,
});
typedef $$CoursesTableUpdateCompanionBuilder = CoursesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> teacher,
  Value<String?> location,
  Value<int> color,
  Value<String?> scheduleId,
  Value<int> rowid,
});

class $$CoursesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $CoursesTable,
    Course,
    $$CoursesTableFilterComposer,
    $$CoursesTableOrderingComposer,
    $$CoursesTableCreateCompanionBuilder,
    $$CoursesTableUpdateCompanionBuilder> {
  $$CoursesTableTableManager(_$AppDatabase db, $CoursesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$CoursesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$CoursesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> teacher = const Value.absent(),
            Value<String?> location = const Value.absent(),
            Value<int> color = const Value.absent(),
            Value<String?> scheduleId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CoursesCompanion(
            id: id,
            name: name,
            teacher: teacher,
            location: location,
            color: color,
            scheduleId: scheduleId,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String teacher,
            Value<String?> location = const Value.absent(),
            required int color,
            Value<String?> scheduleId = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              CoursesCompanion.insert(
            id: id,
            name: name,
            teacher: teacher,
            location: location,
            color: color,
            scheduleId: scheduleId,
            rowid: rowid,
          ),
        ));
}

class $$CoursesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get teacher => $state.composableBuilder(
      column: $state.table.teacher,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get location => $state.composableBuilder(
      column: $state.table.location,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get scheduleId => $state.composableBuilder(
      column: $state.table.scheduleId,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ComposableFilter timeDetailsRefs(
      ComposableFilter Function($$TimeDetailsTableFilterComposer f) f) {
    final $$TimeDetailsTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $state.db.timeDetails,
        getReferencedColumn: (t) => t.courseId,
        builder: (joinBuilder, parentComposers) =>
            $$TimeDetailsTableFilterComposer(ComposerState($state.db,
                $state.db.timeDetails, joinBuilder, parentComposers)));
    return f(composer);
  }
}

class $$CoursesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $CoursesTable> {
  $$CoursesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get teacher => $state.composableBuilder(
      column: $state.table.teacher,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get location => $state.composableBuilder(
      column: $state.table.location,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get color => $state.composableBuilder(
      column: $state.table.color,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get scheduleId => $state.composableBuilder(
      column: $state.table.scheduleId,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$TimeDetailsTableCreateCompanionBuilder = TimeDetailsCompanion
    Function({
  Value<int> id,
  required String courseId,
  required int dayOfWeek,
  required int startPeriod,
  required int duration,
  required String weeks,
  required String singleOrDouble,
});
typedef $$TimeDetailsTableUpdateCompanionBuilder = TimeDetailsCompanion
    Function({
  Value<int> id,
  Value<String> courseId,
  Value<int> dayOfWeek,
  Value<int> startPeriod,
  Value<int> duration,
  Value<String> weeks,
  Value<String> singleOrDouble,
});

class $$TimeDetailsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $TimeDetailsTable,
    TimeDetail,
    $$TimeDetailsTableFilterComposer,
    $$TimeDetailsTableOrderingComposer,
    $$TimeDetailsTableCreateCompanionBuilder,
    $$TimeDetailsTableUpdateCompanionBuilder> {
  $$TimeDetailsTableTableManager(_$AppDatabase db, $TimeDetailsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$TimeDetailsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$TimeDetailsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> courseId = const Value.absent(),
            Value<int> dayOfWeek = const Value.absent(),
            Value<int> startPeriod = const Value.absent(),
            Value<int> duration = const Value.absent(),
            Value<String> weeks = const Value.absent(),
            Value<String> singleOrDouble = const Value.absent(),
          }) =>
              TimeDetailsCompanion(
            id: id,
            courseId: courseId,
            dayOfWeek: dayOfWeek,
            startPeriod: startPeriod,
            duration: duration,
            weeks: weeks,
            singleOrDouble: singleOrDouble,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String courseId,
            required int dayOfWeek,
            required int startPeriod,
            required int duration,
            required String weeks,
            required String singleOrDouble,
          }) =>
              TimeDetailsCompanion.insert(
            id: id,
            courseId: courseId,
            dayOfWeek: dayOfWeek,
            startPeriod: startPeriod,
            duration: duration,
            weeks: weeks,
            singleOrDouble: singleOrDouble,
          ),
        ));
}

class $$TimeDetailsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $TimeDetailsTable> {
  $$TimeDetailsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get dayOfWeek => $state.composableBuilder(
      column: $state.table.dayOfWeek,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get startPeriod => $state.composableBuilder(
      column: $state.table.startPeriod,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get duration => $state.composableBuilder(
      column: $state.table.duration,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get weeks => $state.composableBuilder(
      column: $state.table.weeks,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get singleOrDouble => $state.composableBuilder(
      column: $state.table.singleOrDouble,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  $$CoursesTableFilterComposer get courseId {
    final $$CoursesTableFilterComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.courseId,
        referencedTable: $state.db.courses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) => $$CoursesTableFilterComposer(
            ComposerState(
                $state.db, $state.db.courses, joinBuilder, parentComposers)));
    return composer;
  }
}

class $$TimeDetailsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $TimeDetailsTable> {
  $$TimeDetailsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get dayOfWeek => $state.composableBuilder(
      column: $state.table.dayOfWeek,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get startPeriod => $state.composableBuilder(
      column: $state.table.startPeriod,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get duration => $state.composableBuilder(
      column: $state.table.duration,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get weeks => $state.composableBuilder(
      column: $state.table.weeks,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get singleOrDouble => $state.composableBuilder(
      column: $state.table.singleOrDouble,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  $$CoursesTableOrderingComposer get courseId {
    final $$CoursesTableOrderingComposer composer = $state.composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.courseId,
        referencedTable: $state.db.courses,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder, parentComposers) =>
            $$CoursesTableOrderingComposer(ComposerState(
                $state.db, $state.db.courses, joinBuilder, parentComposers)));
    return composer;
  }
}

typedef $$SchedulesTableCreateCompanionBuilder = SchedulesCompanion Function({
  required String id,
  required String name,
  required bool isDefault,
  required DateTime createdAt,
  Value<String?> displayedWeekdays,
  Value<int?> maxCoursesPerDay,
  Value<int> rowid,
});
typedef $$SchedulesTableUpdateCompanionBuilder = SchedulesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<bool> isDefault,
  Value<DateTime> createdAt,
  Value<String?> displayedWeekdays,
  Value<int?> maxCoursesPerDay,
  Value<int> rowid,
});

class $$SchedulesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SchedulesTable,
    Schedule,
    $$SchedulesTableFilterComposer,
    $$SchedulesTableOrderingComposer,
    $$SchedulesTableCreateCompanionBuilder,
    $$SchedulesTableUpdateCompanionBuilder> {
  $$SchedulesTableTableManager(_$AppDatabase db, $SchedulesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SchedulesTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SchedulesTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<String?> displayedWeekdays = const Value.absent(),
            Value<int?> maxCoursesPerDay = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SchedulesCompanion(
            id: id,
            name: name,
            isDefault: isDefault,
            createdAt: createdAt,
            displayedWeekdays: displayedWeekdays,
            maxCoursesPerDay: maxCoursesPerDay,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required bool isDefault,
            required DateTime createdAt,
            Value<String?> displayedWeekdays = const Value.absent(),
            Value<int?> maxCoursesPerDay = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SchedulesCompanion.insert(
            id: id,
            name: name,
            isDefault: isDefault,
            createdAt: createdAt,
            displayedWeekdays: displayedWeekdays,
            maxCoursesPerDay: maxCoursesPerDay,
            rowid: rowid,
          ),
        ));
}

class $$SchedulesTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableFilterComposer(super.$state);
  ColumnFilters<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get displayedWeekdays => $state.composableBuilder(
      column: $state.table.displayedWeekdays,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get maxCoursesPerDay => $state.composableBuilder(
      column: $state.table.maxCoursesPerDay,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SchedulesTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SchedulesTable> {
  $$SchedulesTableOrderingComposer(super.$state);
  ColumnOrderings<String> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<bool> get isDefault => $state.composableBuilder(
      column: $state.table.isDefault,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<DateTime> get createdAt => $state.composableBuilder(
      column: $state.table.createdAt,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get displayedWeekdays => $state.composableBuilder(
      column: $state.table.displayedWeekdays,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get maxCoursesPerDay => $state.composableBuilder(
      column: $state.table.maxCoursesPerDay,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

typedef $$SemesterConfigsTableCreateCompanionBuilder = SemesterConfigsCompanion
    Function({
  Value<int> id,
  required String name,
  required String startDate,
  required int totalWeeks,
  required int isActive,
});
typedef $$SemesterConfigsTableUpdateCompanionBuilder = SemesterConfigsCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<String> startDate,
  Value<int> totalWeeks,
  Value<int> isActive,
});

class $$SemesterConfigsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SemesterConfigsTable,
    SemesterConfig,
    $$SemesterConfigsTableFilterComposer,
    $$SemesterConfigsTableOrderingComposer,
    $$SemesterConfigsTableCreateCompanionBuilder,
    $$SemesterConfigsTableUpdateCompanionBuilder> {
  $$SemesterConfigsTableTableManager(
      _$AppDatabase db, $SemesterConfigsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          filteringComposer:
              $$SemesterConfigsTableFilterComposer(ComposerState(db, table)),
          orderingComposer:
              $$SemesterConfigsTableOrderingComposer(ComposerState(db, table)),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> startDate = const Value.absent(),
            Value<int> totalWeeks = const Value.absent(),
            Value<int> isActive = const Value.absent(),
          }) =>
              SemesterConfigsCompanion(
            id: id,
            name: name,
            startDate: startDate,
            totalWeeks: totalWeeks,
            isActive: isActive,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            required String startDate,
            required int totalWeeks,
            required int isActive,
          }) =>
              SemesterConfigsCompanion.insert(
            id: id,
            name: name,
            startDate: startDate,
            totalWeeks: totalWeeks,
            isActive: isActive,
          ),
        ));
}

class $$SemesterConfigsTableFilterComposer
    extends FilterComposer<_$AppDatabase, $SemesterConfigsTable> {
  $$SemesterConfigsTableFilterComposer(super.$state);
  ColumnFilters<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<String> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get totalWeeks => $state.composableBuilder(
      column: $state.table.totalWeeks,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));

  ColumnFilters<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnFilters(column, joinBuilders: joinBuilders));
}

class $$SemesterConfigsTableOrderingComposer
    extends OrderingComposer<_$AppDatabase, $SemesterConfigsTable> {
  $$SemesterConfigsTableOrderingComposer(super.$state);
  ColumnOrderings<int> get id => $state.composableBuilder(
      column: $state.table.id,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get name => $state.composableBuilder(
      column: $state.table.name,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<String> get startDate => $state.composableBuilder(
      column: $state.table.startDate,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get totalWeeks => $state.composableBuilder(
      column: $state.table.totalWeeks,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));

  ColumnOrderings<int> get isActive => $state.composableBuilder(
      column: $state.table.isActive,
      builder: (column, joinBuilders) =>
          ColumnOrderings(column, joinBuilders: joinBuilders));
}

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$CoursesTableTableManager get courses =>
      $$CoursesTableTableManager(_db, _db.courses);
  $$TimeDetailsTableTableManager get timeDetails =>
      $$TimeDetailsTableTableManager(_db, _db.timeDetails);
  $$SchedulesTableTableManager get schedules =>
      $$SchedulesTableTableManager(_db, _db.schedules);
  $$SemesterConfigsTableTableManager get semesterConfigs =>
      $$SemesterConfigsTableTableManager(_db, _db.semesterConfigs);
}
