import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'action_item.dart';

class AppBarConfig {
  static const String _key = 'app_bar_action_items';
  static const List<ActionItem> _defaultItems = [
    ActionItem.importTimetable,
    ActionItem.exportTimetable,
  ];

  /// Load the ordered list of ActionItems that should appear on the AppBar.
  /// Falls back to default list if nothing is stored.
  static Future<List<ActionItem>> loadActionItems() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonStr = prefs.getString(_key);
    if (jsonStr == null) return List.from(_defaultItems);

    try {
      final List<dynamic> names = jsonDecode(jsonStr);
      return names
          .map((n) => ActionItem.values.cast<ActionItem?>().firstWhere(
                (e) => e!.name == n,
                orElse: () => null,
              ))
          .whereType<ActionItem>()
          .toList()
        ..sort((a, b) => ActionItem.values.indexOf(a)
            .compareTo(ActionItem.values.indexOf(b)));
    } catch (_) {
      return List.from(_defaultItems);
    }
  }

  /// Save the ordered list of ActionItems for the AppBar.
  static Future<void> saveActionItems(List<ActionItem> items) async {
    final prefs = await SharedPreferences.getInstance();
    final limited = items.take(ActionItem.maxAppBarItems).toList();
    final names = limited.map((e) => e.name).toList();
    await prefs.setString(_key, jsonEncode(names));
  }

  /// Reset to default items.
  static Future<void> resetToDefault() async {
    await saveActionItems(_defaultItems);
  }

  /// Get items that are NOT on the AppBar (shown in popup).
  static List<ActionItem> getOverflowItems(List<ActionItem> appBarItems) {
    return ActionItem.values
        .where((item) => !appBarItems.contains(item))
        .toList();
  }
}
