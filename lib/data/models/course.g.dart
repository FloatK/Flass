// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CourseImpl _$$CourseImplFromJson(Map<String, dynamic> json) => _$CourseImpl(
      id: json['id'] as String,
      name: json['name'] as String,
      teacher: json['teacher'] as String,
      location: json['location'] as String?,
      color: (json['color'] as num?)?.toInt() ?? 0xFF2196F3,
      timeDetails: (json['timeDetails'] as List<dynamic>?)
              ?.map((e) => TimeDetail.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
    );

Map<String, dynamic> _$$CourseImplToJson(_$CourseImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'teacher': instance.teacher,
      'location': instance.location,
      'color': instance.color,
      'timeDetails': instance.timeDetails,
    };

_$TimeDetailImpl _$$TimeDetailImplFromJson(Map<String, dynamic> json) =>
    _$TimeDetailImpl(
      dayOfWeek: (json['dayOfWeek'] as num).toInt(),
      startPeriod: (json['startPeriod'] as num).toInt(),
      duration: (json['duration'] as num?)?.toInt() ?? 1,
      weeks: (json['weeks'] as List<dynamic>?)
              ?.map((e) => (e as num).toInt())
              .toList() ??
          const [],
      singleOrDouble: json['singleOrDouble'] as String? ?? 'all',
    );

Map<String, dynamic> _$$TimeDetailImplToJson(_$TimeDetailImpl instance) =>
    <String, dynamic>{
      'dayOfWeek': instance.dayOfWeek,
      'startPeriod': instance.startPeriod,
      'duration': instance.duration,
      'weeks': instance.weeks,
      'singleOrDouble': instance.singleOrDouble,
    };
