import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';

/// 动作项定义
///
/// 用于 AppBar 按钮和弹出菜单。
/// 使用 [ActionItemRegistry] 注册和管理动作项。
class ActionItem {
  /// 动作唯一标识
  final String id;

  /// 显示名称（用于 UI）
  final String Function(BuildContext context) displayNameBuilder;

  /// 图标
  final IconData icon;

  /// 点击回调
  final void Function(BuildContext context) onPressed;

  /// 是否在 AppBar 中显示（默认 true）
  final bool showInAppBar;

  const ActionItem({
    required this.id,
    required this.displayNameBuilder,
    required this.icon,
    required this.onPressed,
    this.showInAppBar = true,
  });

  /// 便捷构造器（使用固定名称）
  factory ActionItem.simple({
    required String id,
    required String displayName,
    required IconData icon,
    required void Function(BuildContext context) onPressed,
    bool showInAppBar = true,
  }) {
    return ActionItem(
      id: id,
      displayNameBuilder: (_) => displayName,
      icon: icon,
      onPressed: onPressed,
      showInAppBar: showInAppBar,
    );
  }

  /// 最大 AppBar 按钮数量
  static const int maxAppBarItems = 4;

  /// 创建一个副本，覆盖指定字段
  ActionItem copyWith({
    String? id,
    String Function(BuildContext context)? displayNameBuilder,
    IconData? icon,
    void Function(BuildContext context)? onPressed,
    bool? showInAppBar,
  }) {
    return ActionItem(
      id: id ?? this.id,
      displayNameBuilder: displayNameBuilder ?? this.displayNameBuilder,
      icon: icon ?? this.icon,
      onPressed: onPressed ?? this.onPressed,
      showInAppBar: showInAppBar ?? this.showInAppBar,
    );
  }
}

/// 动作项注册表
///
/// 管理所有可用的动作项。
/// 使用 [ActionItemRegistry.instance] 获取全局实例。
///
/// 示例：
/// ```dart
/// // 注册新动作
/// ActionItemRegistry.instance.register(
///   ActionItem.simple(
///     id: 'myAction',
///     displayName: '我的动作',
///     icon: Icons.star,
///     onPressed: (context) { ... },
///   ),
/// );
///
/// // 获取所有动作
/// final items = ActionItemRegistry.instance.getAll();
/// ```
class ActionItemRegistry {
  ActionItemRegistry._();

  static final ActionItemRegistry instance = ActionItemRegistry._();

  final List<ActionItem> _items = [];

  /// 注册一个新动作项
  void register(ActionItem item) {
    _items.add(item);
  }

  /// 获取所有已注册的动作项
  List<ActionItem> getAll() => List.unmodifiable(_items);

  /// 根据 ID 查找动作项
  ActionItem? findById(String id) {
    try {
      return _items.firstWhere((item) => item.id == id);
    } catch (_) {
      return null;
    }
  }

  /// 获取所有在 AppBar 中显示的动作项
  List<ActionItem> getAppBarItems() {
    return _items.where((item) => item.showInAppBar).toList();
  }
}

/// 初始化默认动作项
///
/// 在应用启动时调用，注册所有内置动作项。
/// 需要传入回调函数，因为动作项需要访问导航和业务逻辑。
void initDefaultActionItems({
  required void Function(BuildContext context) onImportTimetable,
  required void Function(BuildContext context) onExportTimetable,
  required void Function(BuildContext context) onImportJson,
  required void Function(BuildContext context) onPreviousWeek,
  required void Function(BuildContext context) onNextWeek,
  required void Function(BuildContext context) onGoToCurrentWeek,
  required void Function(BuildContext context) onSelectTimetable,
  required void Function(BuildContext context) onThemeSettings,
  required void Function(BuildContext context) onSwapCourse,
}) {
  final registry = ActionItemRegistry.instance;

  registry.register(ActionItem(
    id: 'importTimetable',
    displayNameBuilder: (context) => AppLocalizations.of(context)!.importTimetable,
    icon: Icons.school,
    onPressed: onImportTimetable,
  ));

  registry.register(ActionItem(
    id: 'exportTimetable',
    displayNameBuilder: (context) => AppLocalizations.of(context)!.shareTimetable,
    icon: Icons.share,
    onPressed: onExportTimetable,
  ));

  registry.register(ActionItem(
    id: 'importJson',
    displayNameBuilder: (context) => AppLocalizations.of(context)!.importFromTextAction,
    icon: Icons.file_download,
    onPressed: onImportJson,
  ));

  registry.register(ActionItem(
    id: 'previousWeek',
    displayNameBuilder: (context) => AppLocalizations.of(context)!.previousWeekAction,
    icon: Icons.chevron_left,
    onPressed: onPreviousWeek,
  ));

  registry.register(ActionItem(
    id: 'nextWeek',
    displayNameBuilder: (context) => AppLocalizations.of(context)!.nextWeekAction,
    icon: Icons.chevron_right,
    onPressed: onNextWeek,
  ));

  registry.register(ActionItem(
    id: 'goToCurrentWeek',
    displayNameBuilder: (context) => AppLocalizations.of(context)!.goToCurrentWeekAction,
    icon: Icons.radio_button_checked,
    onPressed: onGoToCurrentWeek,
  ));

  registry.register(ActionItem(
    id: 'selectTimetable',
    displayNameBuilder: (context) => AppLocalizations.of(context)!.selectTimetableAction,
    icon: Icons.calendar_today,
    onPressed: onSelectTimetable,
  ));

  registry.register(ActionItem(
    id: 'themeSettings',
    displayNameBuilder: (context) => AppLocalizations.of(context)!.themeAction,
    icon: Icons.palette,
    onPressed: onThemeSettings,
  ));

  registry.register(ActionItem(
    id: 'swapCourse',
    displayNameBuilder: (context) => AppLocalizations.of(context)!.swapCourseAction,
    icon: Icons.swap_horiz,
    onPressed: onSwapCourse,
  ));
}
