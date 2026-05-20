import 'package:flutter/material.dart';

enum ActionItem {
  importTimetable,
  exportTimetable,
  importJson,
  previousWeek,
  nextWeek,
  goToCurrentWeek,
  selectTimetable,
  clearCache,
  about;

  String get displayName {
    switch (this) {
      case ActionItem.importTimetable:
        return '导入课表';
      case ActionItem.exportTimetable:
        return '分享课表';
      case ActionItem.importJson:
        return '从 JSON 导入';
      case ActionItem.previousWeek:
        return '上一周';
      case ActionItem.nextWeek:
        return '下一周';
      case ActionItem.goToCurrentWeek:
        return '返回当前周';
      case ActionItem.selectTimetable:
        return '选择课表';
      case ActionItem.clearCache:
        return '清除缓存';
      case ActionItem.about:
        return '关于';
    }
  }

  IconData get icon {
    switch (this) {
      case ActionItem.importTimetable:
        return Icons.school;
      case ActionItem.exportTimetable:
        return Icons.share;
      case ActionItem.importJson:
        return Icons.upload_file;
      case ActionItem.previousWeek:
        return Icons.chevron_left;
      case ActionItem.nextWeek:
        return Icons.chevron_right;
      case ActionItem.goToCurrentWeek:
        return Icons.radio_button_checked;
      case ActionItem.selectTimetable:
        return Icons.calendar_today;
      case ActionItem.clearCache:
        return Icons.cleaning_services_outlined;
      case ActionItem.about:
        return Icons.info_outline;
    }
  }

  static const int maxAppBarItems = 4;
}
