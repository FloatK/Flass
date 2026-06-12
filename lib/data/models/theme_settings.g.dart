// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'theme_settings.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ThemeSettingsImpl _$$ThemeSettingsImplFromJson(Map<String, dynamic> json) =>
    _$ThemeSettingsImpl(
      followSystem: json['followSystem'] as bool? ?? true,
      brightness: json['brightness'] == null
          ? Brightness.light
          : const BrightnessConverter().fromJson(json['brightness'] as String),
      colorIndex: (json['colorIndex'] as num?)?.toInt() ?? 0,
      cornerRadius: (json['cornerRadius'] as num?)?.toDouble() ?? 10.0,
      blockHeight: (json['blockHeight'] as num?)?.toDouble() ?? 70.0,
      courseSpacing: (json['courseSpacing'] as num?)?.toDouble() ?? 3.0,
      horizontalSpacing: (json['horizontalSpacing'] as num?)?.toDouble() ?? 2.0,
      colorLightness: (json['colorLightness'] as num?)?.toDouble() ?? 1.2,
      followThemeBackground: json['followThemeBackground'] as bool? ?? true,
      vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
    );

Map<String, dynamic> _$$ThemeSettingsImplToJson(_$ThemeSettingsImpl instance) =>
    <String, dynamic>{
      'followSystem': instance.followSystem,
      'brightness': const BrightnessConverter().toJson(instance.brightness),
      'colorIndex': instance.colorIndex,
      'cornerRadius': instance.cornerRadius,
      'blockHeight': instance.blockHeight,
      'courseSpacing': instance.courseSpacing,
      'horizontalSpacing': instance.horizontalSpacing,
      'colorLightness': instance.colorLightness,
      'followThemeBackground': instance.followThemeBackground,
      'vibrationEnabled': instance.vibrationEnabled,
    };
