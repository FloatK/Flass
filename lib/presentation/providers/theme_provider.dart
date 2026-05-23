import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

enum GridBackgroundMode {
  pureBlack,
  customGray,
  followTheme,
}

class ThemeSettings {
  final bool followSystem;
  final Brightness brightness;
  final int colorIndex;
  final double cornerRadius;
  final double blockHeight;
  final double courseSpacing;
  final double horizontalSpacing;
  final double colorLightness;
  // Dark mode settings
  final double darkModeSaturation;
  final double darkModeLightness;
  // Grid background settings
  final GridBackgroundMode gridBackgroundMode;
  final double gridGrayLevel;
  final double gridThemeColorLightness;

  const ThemeSettings({
    this.followSystem = true,
    this.brightness = Brightness.light,
    this.colorIndex = 0,
    this.cornerRadius = 10.0,
    this.blockHeight = 70.0,
    this.courseSpacing = 3.0,
    this.horizontalSpacing = 2.0,
    this.colorLightness = 1.2,
    this.darkModeSaturation = 0.6,
    this.darkModeLightness = 0.4,
    this.gridBackgroundMode = GridBackgroundMode.followTheme,
    this.gridGrayLevel = 0.15,
    this.gridThemeColorLightness = 0.12,
  });

  ThemeSettings copyWith({
    bool? followSystem,
    Brightness? brightness,
    int? colorIndex,
    double? cornerRadius,
    double? blockHeight,
    double? courseSpacing,
    double? horizontalSpacing,
    double? colorLightness,
    double? darkModeSaturation,
    double? darkModeLightness,
    GridBackgroundMode? gridBackgroundMode,
    double? gridGrayLevel,
    double? gridThemeColorLightness,
  }) {
    return ThemeSettings(
      followSystem: followSystem ?? this.followSystem,
      brightness: brightness ?? this.brightness,
      colorIndex: colorIndex ?? this.colorIndex,
      cornerRadius: cornerRadius ?? this.cornerRadius,
      blockHeight: blockHeight ?? this.blockHeight,
      courseSpacing: courseSpacing ?? this.courseSpacing,
      horizontalSpacing: horizontalSpacing ?? this.horizontalSpacing,
      colorLightness: colorLightness ?? this.colorLightness,
      darkModeSaturation: darkModeSaturation ?? this.darkModeSaturation,
      darkModeLightness: darkModeLightness ?? this.darkModeLightness,
      gridBackgroundMode: gridBackgroundMode ?? this.gridBackgroundMode,
      gridGrayLevel: gridGrayLevel ?? this.gridGrayLevel,
      gridThemeColorLightness:
          gridThemeColorLightness ?? this.gridThemeColorLightness,
    );
  }

  /// 获取课表底板背景色
  Color getGridBackgroundColor(ColorScheme colorScheme) {
    switch (gridBackgroundMode) {
      case GridBackgroundMode.pureBlack:
        return Colors.black;
      case GridBackgroundMode.customGray:
        final level = gridGrayLevel.clamp(0.0, 1.0);
        return Color.fromRGBO(
          (level * 255).round(),
          (level * 255).round(),
          (level * 255).round(),
          1,
        );
      case GridBackgroundMode.followTheme:
        final hsl = HSLColor.fromColor(colorScheme.primary);
        return hsl
            .withLightness(gridThemeColorLightness.clamp(0.0, 1.0))
            .toColor();
    }
  }

  /// 获取深色模式下的课程颜色（自动压暗）
  Color getDarkModeCourseColor(int colorValue) {
    final baseColor = Color(colorValue);
    final hsl = HSLColor.fromColor(baseColor);
    return hsl
        .withSaturation((hsl.saturation * darkModeSaturation).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * darkModeLightness).clamp(0.0, 1.0))
        .toColor();
  }

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

Future<ThemeSettings> loadThemeSettings() async {
  final prefs = await SharedPreferences.getInstance();
  return ThemeSettings(
    followSystem: prefs.getBool('theme_follow_system') ?? true,
    brightness:
        prefs.getString('theme_brightness') == 'dark'
            ? Brightness.dark
            : Brightness.light,
    colorIndex: prefs.getInt('theme_color_index') ?? 0,
    cornerRadius: prefs.getDouble('theme_corner_radius') ?? 10.0,
    blockHeight: prefs.getDouble('theme_block_height') ?? 70.0,
    courseSpacing: prefs.getDouble('theme_course_spacing') ?? 3.0,
    horizontalSpacing: prefs.getDouble('theme_horizontal_spacing') ?? 2.0,
    colorLightness: prefs.getDouble('theme_color_lightness') ?? 1.2,
    darkModeSaturation: prefs.getDouble('theme_dark_saturation') ?? 0.6,
    darkModeLightness: prefs.getDouble('theme_dark_lightness') ?? 0.4,
    gridBackgroundMode: GridBackgroundMode
        .values[prefs.getInt('theme_grid_bg_mode') ?? 2],
    gridGrayLevel: prefs.getDouble('theme_grid_gray_level') ?? 0.15,
    gridThemeColorLightness:
        prefs.getDouble('theme_grid_theme_lightness') ?? 0.12,
  );
}

Future<void> saveThemeSettings(ThemeSettings settings) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool('theme_follow_system', settings.followSystem);
  await prefs.setString(
    'theme_brightness',
    settings.brightness == Brightness.dark ? 'dark' : 'light',
  );
  await prefs.setInt('theme_color_index', settings.colorIndex);
  await prefs.setDouble('theme_corner_radius', settings.cornerRadius);
  await prefs.setDouble('theme_block_height', settings.blockHeight);
  await prefs.setDouble('theme_course_spacing', settings.courseSpacing);
  await prefs.setDouble('theme_horizontal_spacing', settings.horizontalSpacing);
  await prefs.setDouble('theme_color_lightness', settings.colorLightness);
  await prefs.setDouble('theme_dark_saturation', settings.darkModeSaturation);
  await prefs.setDouble('theme_dark_lightness', settings.darkModeLightness);
  await prefs.setInt(
      'theme_grid_bg_mode', settings.gridBackgroundMode.index);
  await prefs.setDouble('theme_grid_gray_level', settings.gridGrayLevel);
  await prefs.setDouble(
      'theme_grid_theme_lightness', settings.gridThemeColorLightness);
}

final themeSettingsProvider = StateProvider<ThemeSettings>((ref) {
  throw UnimplementedError('Must be overridden from main');
});
