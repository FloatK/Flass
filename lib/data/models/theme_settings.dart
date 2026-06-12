import 'package:flutter/material.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'theme_settings.freezed.dart';
part 'theme_settings.g.dart';

/// Brightness 转换器
class BrightnessConverter implements JsonConverter<Brightness, String> {
  const BrightnessConverter();

  @override
  Brightness fromJson(String json) {
    return json == 'dark' ? Brightness.dark : Brightness.light;
  }

  @override
  String toJson(Brightness brightness) {
    return brightness == Brightness.dark ? 'dark' : 'light';
  }
}

/// 主题设置数据模型
///
/// 使用 @freezed 自动生成 copyWith、fromJson/toJson 等方法。
/// 添加新字段只需在此处添加，无需修改其他文件。
@freezed
class ThemeSettings with _$ThemeSettings {
  const factory ThemeSettings({
    @Default(true) bool followSystem,
    @BrightnessConverter() @Default(Brightness.light) Brightness brightness,
    @Default(0) int colorIndex,
    @Default(10.0) double cornerRadius,
    @Default(70.0) double blockHeight,
    @Default(3.0) double courseSpacing,
    @Default(2.0) double horizontalSpacing,
    @Default(1.2) double colorLightness,
    @Default(true) bool followThemeBackground,
    @Default(true) bool vibrationEnabled,
  }) = _ThemeSettings;

  factory ThemeSettings.fromJson(Map<String, dynamic> json) =>
      _$ThemeSettingsFromJson(json);

  /// 预设主题颜色
  static const List<Color> presetThemeColors = [
    Color(0xFF1565C0), // 蓝色
    Color(0xFFD32F2F), // 红色
    Color(0xFF2E7D32), // 绿色
    Color(0xFF6A1B9A), // 紫色
    Color(0xFFE65100), // 橙色
    Color(0xFFAD1457), // 粉色
    Color(0xFF00838F), // 青色
    Color(0xFF4E342E), // 棕色
  ];
}

/// ThemeSettings 扩展方法
extension ThemeSettingsExtension on ThemeSettings {
  /// 获取课表底板背景色
  Color getGridBackgroundColor(ColorScheme colorScheme, bool isDark) {
    if (!followThemeBackground) {
      return isDark ? const Color(0xFF1E1E1E) : Colors.white;
    }

    final hsl = HSLColor.fromColor(colorScheme.primary);
    if (isDark) {
      return hsl
          .withSaturation((hsl.saturation * 0.7).clamp(0.0, 1.0))
          .withLightness(0.08)
          .toColor();
    } else {
      return hsl.withLightness(0.95).toColor();
    }
  }

  /// 获取深色模式下的课程颜色（自动压暗）
  Color getDarkModeCourseColor(int colorValue) {
    final baseColor = Color(colorValue);
    final hsl = HSLColor.fromColor(baseColor);
    return hsl
        .withSaturation((hsl.saturation * 0.6).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.4).clamp(0.0, 1.0))
        .toColor();
  }
}
