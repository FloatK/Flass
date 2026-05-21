import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeSettings {
  final bool followSystem;
  final Brightness brightness;
  final int colorIndex;
  final double cornerRadius;
  final double blockHeight;
  final double courseSpacing;
  final double horizontalSpacing;
  final double colorLightness;

  const ThemeSettings({
    this.followSystem = true,
    this.brightness = Brightness.light,
    this.colorIndex = 0,
    this.cornerRadius = 10.0,
    this.blockHeight = 70.0,
    this.courseSpacing = 3.0,
    this.horizontalSpacing = 2.0,
    this.colorLightness = 1.2,
  });

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
}

final themeSettingsProvider = StateProvider<ThemeSettings>((ref) {
  throw UnimplementedError('Must be overridden from main');
});
