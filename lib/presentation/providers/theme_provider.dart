import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/utils/vibrate.dart';
import '../../data/models/theme_settings.dart';

// 重新导出 ThemeSettings，保持向后兼容
export '../../data/models/theme_settings.dart';

const _kThemeSettingsKey = 'theme_settings_json';

/// 从 SharedPreferences 加载主题设置
///
/// 使用 JSON 序列化，添加新字段无需修改此函数。
Future<ThemeSettings> loadThemeSettings() async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = prefs.getString(_kThemeSettingsKey);

  ThemeSettings settings;
  if (jsonStr != null) {
    try {
      final json = jsonDecode(jsonStr) as Map<String, dynamic>;
      settings = ThemeSettings.fromJson(json);
    } catch (e) {
      // JSON 解析失败，使用默认值
      settings = const ThemeSettings();
    }
  } else {
    // 首次启动，尝试从旧格式迁移
    settings = await _migrateFromLegacyFormat(prefs);
  }

  Vibrate.setEnabled(settings.vibrationEnabled);
  return settings;
}

/// 保存主题设置到 SharedPreferences
///
/// 使用 JSON 序列化，添加新字段无需修改此函数。
Future<void> saveThemeSettings(ThemeSettings settings) async {
  final prefs = await SharedPreferences.getInstance();
  final jsonStr = jsonEncode(settings.toJson());
  await prefs.setString(_kThemeSettingsKey, jsonStr);
  Vibrate.setEnabled(settings.vibrationEnabled);
}

/// 从旧格式迁移（兼容旧版本）
Future<ThemeSettings> _migrateFromLegacyFormat(SharedPreferences prefs) async {
  final settings = ThemeSettings(
    followSystem: prefs.getBool('theme_follow_system') ?? true,
    brightness: prefs.getString('theme_brightness') == 'dark'
        ? Brightness.dark
        : Brightness.light,
    colorIndex: prefs.getInt('theme_color_index') ?? 0,
    cornerRadius: prefs.getDouble('theme_corner_radius') ?? 10.0,
    blockHeight: prefs.getDouble('theme_block_height') ?? 70.0,
    courseSpacing: prefs.getDouble('theme_course_spacing') ?? 3.0,
    horizontalSpacing: prefs.getDouble('theme_horizontal_spacing') ?? 2.0,
    colorLightness: prefs.getDouble('theme_color_lightness') ?? 1.2,
    followThemeBackground:
        prefs.getBool('theme_follow_theme_background') ?? true,
    vibrationEnabled: prefs.getBool('theme_vibration_enabled') ?? true,
  );

  // 迁移后立即保存为新格式
  await saveThemeSettings(settings);

  // 清除旧格式的 keys
  prefs.remove('theme_follow_system');
  prefs.remove('theme_brightness');
  prefs.remove('theme_color_index');
  prefs.remove('theme_corner_radius');
  prefs.remove('theme_block_height');
  prefs.remove('theme_course_spacing');
  prefs.remove('theme_horizontal_spacing');
  prefs.remove('theme_color_lightness');
  prefs.remove('theme_follow_theme_background');
  prefs.remove('theme_vibration_enabled');

  return settings;
}

/// 主题设置 Provider
final themeSettingsProvider = StateProvider<ThemeSettings>((ref) {
  throw UnimplementedError('Must be overridden from main');
});
