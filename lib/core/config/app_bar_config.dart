import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'action_item.dart';

class AppBarConfig {
  static const String _key = 'app_bar_action_items';
  static const List<String> _defaultItemIds = [
    'importTimetable',
    'exportTimetable',
  ];

  /// Load the ordered list of ActionItems that should appear on the AppBar.
  /// Falls back to default list if nothing is stored.
  static Future<List<ActionItem>> loadActionItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    final registry = ActionItemRegistry.instance;

    if (jsonStr == null) {
      return _defaultItemIds
          .map((id) => registry.findById(id))
          .whereType<ActionItem>()
          .toList();
    }

    try {
      final List<dynamic> ids = jsonDecode(jsonStr);
      return ids
          .map((id) => registry.findById(id as String))
          .whereType<ActionItem>()
          .toList();
    } catch (_) {
      return _defaultItemIds
          .map((id) => registry.findById(id))
          .whereType<ActionItem>()
          .toList();
    }
  }

  /// Save the ordered list of ActionItems for the AppBar.
  static Future<void> saveActionItems(List<ActionItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final limited = items.take(ActionItem.maxAppBarItems).toList();
    final ids = limited.map((e) => e.id).toList();
    await prefs.setString(_key, jsonEncode(ids));
  }

  /// Reset to default items.
  static Future<void> resetToDefault() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }

  /// Get items that are NOT on the AppBar (shown in popup).
  ///
  /// [allItems] 是所有可用的 ActionItem（已覆盖回调）。
  /// 返回不在 AppBar 中的项目。
  static List<ActionItem> getOverflowItems(
    List<ActionItem> appBarItems, {
    List<ActionItem>? allItems,
  }) {
    final appBarIds = appBarItems.map((e) => e.id).toSet();
    final source = allItems ?? ActionItemRegistry.instance.getAll();
    return source.where((item) => !appBarIds.contains(item.id)).toList();
  }
}
