// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'course.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
  'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models',
);

Course _$CourseFromJson(Map<String, dynamic> json) {
  return _Course.fromJson(json);
}

/// @nodoc
mixin _$Course {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  String get teacher => throw _privateConstructorUsedError;
  String? get location => throw _privateConstructorUsedError;
  int get color => throw _privateConstructorUsedError;
  List<TimeDetail> get timeDetails => throw _privateConstructorUsedError;

  /// Serializes this Course to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $CourseCopyWith<Course> get copyWith => throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $CourseCopyWith<$Res> {
  factory $CourseCopyWith(Course value, $Res Function(Course) then) =
      _$CourseCopyWithImpl<$Res, Course>;
  @useResult
  $Res call({
    String id,
    String name,
    String teacher,
    String? location,
    int color,
    List<TimeDetail> timeDetails,
  });
}

/// @nodoc
class _$CourseCopyWithImpl<$Res, $Val extends Course>
    implements $CourseCopyWith<$Res> {
  _$CourseCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? teacher = null,
    Object? location = freezed,
    Object? color = null,
    Object? timeDetails = null,
  }) {
    return _then(
      _value.copyWith(
            id: null == id
                ? _value.id
                : id // ignore: cast_nullable_to_non_nullable
                      as String,
            name: null == name
                ? _value.name
                : name // ignore: cast_nullable_to_non_nullable
                      as String,
            teacher: null == teacher
                ? _value.teacher
                : teacher // ignore: cast_nullable_to_non_nullable
                      as String,
            location: freezed == location
                ? _value.location
                : location // ignore: cast_nullable_to_non_nullable
                      as String?,
            color: null == color
                ? _value.color
                : color // ignore: cast_nullable_to_non_nullable
                      as int,
            timeDetails: null == timeDetails
                ? _value.timeDetails
                : timeDetails // ignore: cast_nullable_to_non_nullable
                      as List<TimeDetail>,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$CourseImplCopyWith<$Res> implements $CourseCopyWith<$Res> {
  factory _$$CourseImplCopyWith(
    _$CourseImpl value,
    $Res Function(_$CourseImpl) then,
  ) = __$$CourseImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    String id,
    String name,
    String teacher,
    String? location,
    int color,
    List<TimeDetail> timeDetails,
  });
}

/// @nodoc
class __$$CourseImplCopyWithImpl<$Res>
    extends _$CourseCopyWithImpl<$Res, _$CourseImpl>
    implements _$$CourseImplCopyWith<$Res> {
  __$$CourseImplCopyWithImpl(
    _$CourseImpl _value,
    $Res Function(_$CourseImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? teacher = null,
    Object? location = freezed,
    Object? color = null,
    Object? timeDetails = null,
  }) {
    return _then(
      _$CourseImpl(
        id: null == id
            ? _value.id
            : id // ignore: cast_nullable_to_non_nullable
                  as String,
        name: null == name
            ? _value.name
            : name // ignore: cast_nullable_to_non_nullable
                  as String,
        teacher: null == teacher
            ? _value.teacher
            : teacher // ignore: cast_nullable_to_non_nullable
                  as String,
        location: freezed == location
            ? _value.location
            : location // ignore: cast_nullable_to_non_nullable
                  as String?,
        color: null == color
            ? _value.color
            : color // ignore: cast_nullable_to_non_nullable
                  as int,
        timeDetails: null == timeDetails
            ? _value._timeDetails
            : timeDetails // ignore: cast_nullable_to_non_nullable
                  as List<TimeDetail>,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$CourseImpl implements _Course {
  const _$CourseImpl({
    required this.id,
    required this.name,
    required this.teacher,
    this.location,
    this.color = 0xFF2196F3,
    final List<TimeDetail> timeDetails = const [],
  }) : _timeDetails = timeDetails;

  factory _$CourseImpl.fromJson(Map<String, dynamic> json) =>
      _$$CourseImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final String teacher;
  @override
  final String? location;
  @override
  @JsonKey()
  final int color;
  final List<TimeDetail> _timeDetails;
  @override
  @JsonKey()
  List<TimeDetail> get timeDetails {
    if (_timeDetails is EqualUnmodifiableListView) return _timeDetails;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_timeDetails);
  }

  @override
  String toString() {
    return 'Course(id: $id, name: $name, teacher: $teacher, location: $location, color: $color, timeDetails: $timeDetails)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$CourseImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.teacher, teacher) || other.teacher == teacher) &&
            (identical(other.location, location) ||
                other.location == location) &&
            (identical(other.color, color) || other.color == color) &&
            const DeepCollectionEquality().equals(
              other._timeDetails,
              _timeDetails,
            ));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    id,
    name,
    teacher,
    location,
    color,
    const DeepCollectionEquality().hash(_timeDetails),
  );

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      __$$CourseImplCopyWithImpl<_$CourseImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$CourseImplToJson(this);
  }
}

abstract class _Course implements Course {
  const factory _Course({
    required final String id,
    required final String name,
    required final String teacher,
    final String? location,
    final int color,
    final List<TimeDetail> timeDetails,
  }) = _$CourseImpl;

  factory _Course.fromJson(Map<String, dynamic> json) = _$CourseImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  String get teacher;
  @override
  String? get location;
  @override
  int get color;
  @override
  List<TimeDetail> get timeDetails;

  /// Create a copy of Course
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$CourseImplCopyWith<_$CourseImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

TimeDetail _$TimeDetailFromJson(Map<String, dynamic> json) {
  return _TimeDetail.fromJson(json);
}

/// @nodoc
mixin _$TimeDetail {
  int get dayOfWeek => throw _privateConstructorUsedError;
  int get startPeriod => throw _privateConstructorUsedError;
  int get duration => throw _privateConstructorUsedError;
  List<int> get weeks => throw _privateConstructorUsedError;
  String get singleOrDouble => throw _privateConstructorUsedError;

  /// Serializes this TimeDetail to a JSON map.
  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;

  /// Create a copy of TimeDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $TimeDetailCopyWith<TimeDetail> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $TimeDetailCopyWith<$Res> {
  factory $TimeDetailCopyWith(
    TimeDetail value,
    $Res Function(TimeDetail) then,
  ) = _$TimeDetailCopyWithImpl<$Res, TimeDetail>;
  @useResult
  $Res call({
    int dayOfWeek,
    int startPeriod,
    int duration,
    List<int> weeks,
    String singleOrDouble,
  });
}

/// @nodoc
class _$TimeDetailCopyWithImpl<$Res, $Val extends TimeDetail>
    implements $TimeDetailCopyWith<$Res> {
  _$TimeDetailCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of TimeDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? startPeriod = null,
    Object? duration = null,
    Object? weeks = null,
    Object? singleOrDouble = null,
  }) {
    return _then(
      _value.copyWith(
            dayOfWeek: null == dayOfWeek
                ? _value.dayOfWeek
                : dayOfWeek // ignore: cast_nullable_to_non_nullable
                      as int,
            startPeriod: null == startPeriod
                ? _value.startPeriod
                : startPeriod // ignore: cast_nullable_to_non_nullable
                      as int,
            duration: null == duration
                ? _value.duration
                : duration // ignore: cast_nullable_to_non_nullable
                      as int,
            weeks: null == weeks
                ? _value.weeks
                : weeks // ignore: cast_nullable_to_non_nullable
                      as List<int>,
            singleOrDouble: null == singleOrDouble
                ? _value.singleOrDouble
                : singleOrDouble // ignore: cast_nullable_to_non_nullable
                      as String,
          )
          as $Val,
    );
  }
}

/// @nodoc
abstract class _$$TimeDetailImplCopyWith<$Res>
    implements $TimeDetailCopyWith<$Res> {
  factory _$$TimeDetailImplCopyWith(
    _$TimeDetailImpl value,
    $Res Function(_$TimeDetailImpl) then,
  ) = __$$TimeDetailImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call({
    int dayOfWeek,
    int startPeriod,
    int duration,
    List<int> weeks,
    String singleOrDouble,
  });
}

/// @nodoc
class __$$TimeDetailImplCopyWithImpl<$Res>
    extends _$TimeDetailCopyWithImpl<$Res, _$TimeDetailImpl>
    implements _$$TimeDetailImplCopyWith<$Res> {
  __$$TimeDetailImplCopyWithImpl(
    _$TimeDetailImpl _value,
    $Res Function(_$TimeDetailImpl) _then,
  ) : super(_value, _then);

  /// Create a copy of TimeDetail
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? dayOfWeek = null,
    Object? startPeriod = null,
    Object? duration = null,
    Object? weeks = null,
    Object? singleOrDouble = null,
  }) {
    return _then(
      _$TimeDetailImpl(
        dayOfWeek: null == dayOfWeek
            ? _value.dayOfWeek
            : dayOfWeek // ignore: cast_nullable_to_non_nullable
                  as int,
        startPeriod: null == startPeriod
            ? _value.startPeriod
            : startPeriod // ignore: cast_nullable_to_non_nullable
                  as int,
        duration: null == duration
            ? _value.duration
            : duration // ignore: cast_nullable_to_non_nullable
                  as int,
        weeks: null == weeks
            ? _value._weeks
            : weeks // ignore: cast_nullable_to_non_nullable
                  as List<int>,
        singleOrDouble: null == singleOrDouble
            ? _value.singleOrDouble
            : singleOrDouble // ignore: cast_nullable_to_non_nullable
                  as String,
      ),
    );
  }
}

/// @nodoc
@JsonSerializable()
class _$TimeDetailImpl implements _TimeDetail {
  const _$TimeDetailImpl({
    required this.dayOfWeek,
    required this.startPeriod,
    this.duration = 1,
    final List<int> weeks = const [],
    this.singleOrDouble = 'all',
  }) : _weeks = weeks;

  factory _$TimeDetailImpl.fromJson(Map<String, dynamic> json) =>
      _$$TimeDetailImplFromJson(json);

  @override
  final int dayOfWeek;
  @override
  final int startPeriod;
  @override
  @JsonKey()
  final int duration;
  final List<int> _weeks;
  @override
  @JsonKey()
  List<int> get weeks {
    if (_weeks is EqualUnmodifiableListView) return _weeks;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_weeks);
  }

  @override
  @JsonKey()
  final String singleOrDouble;

  @override
  String toString() {
    return 'TimeDetail(dayOfWeek: $dayOfWeek, startPeriod: $startPeriod, duration: $duration, weeks: $weeks, singleOrDouble: $singleOrDouble)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$TimeDetailImpl &&
            (identical(other.dayOfWeek, dayOfWeek) ||
                other.dayOfWeek == dayOfWeek) &&
            (identical(other.startPeriod, startPeriod) ||
                other.startPeriod == startPeriod) &&
            (identical(other.duration, duration) ||
                other.duration == duration) &&
            const DeepCollectionEquality().equals(other._weeks, _weeks) &&
            (identical(other.singleOrDouble, singleOrDouble) ||
                other.singleOrDouble == singleOrDouble));
  }

  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  int get hashCode => Object.hash(
    runtimeType,
    dayOfWeek,
    startPeriod,
    duration,
    const DeepCollectionEquality().hash(_weeks),
    singleOrDouble,
  );

  /// Create a copy of TimeDetail
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$TimeDetailImplCopyWith<_$TimeDetailImpl> get copyWith =>
      __$$TimeDetailImplCopyWithImpl<_$TimeDetailImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$TimeDetailImplToJson(this);
  }
}

abstract class _TimeDetail implements TimeDetail {
  const factory _TimeDetail({
    required final int dayOfWeek,
    required final int startPeriod,
    final int duration,
    final List<int> weeks,
    final String singleOrDouble,
  }) = _$TimeDetailImpl;

  factory _TimeDetail.fromJson(Map<String, dynamic> json) =
      _$TimeDetailImpl.fromJson;

  @override
  int get dayOfWeek;
  @override
  int get startPeriod;
  @override
  int get duration;
  @override
  List<int> get weeks;
  @override
  String get singleOrDouble;

  /// Create a copy of TimeDetail
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$TimeDetailImplCopyWith<_$TimeDetailImpl> get copyWith =>
      throw _privateConstructorUsedError;
}
