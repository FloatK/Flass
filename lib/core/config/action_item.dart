import 'package:flutter/material.dart';

enum ActionItem {
  importTimetable,
  exportTimetable,
  importJson,
  previousWeek,
  nextWeek,
  goToCurrentWeek,
  selectTimetable,
  themeSettings,
  swapCourse;

  String get displayName {
    switch (this) {
      case ActionItem.importTimetable:
        return '从教务导入';
      case ActionItem.exportTimetable:
        return '分享课表';
      case ActionItem.importJson:
        return '从文本导入';
      case ActionItem.previousWeek:
        return '上一周';
      case ActionItem.nextWeek:
        return '下一周';
      case ActionItem.goToCurrentWeek:
        return '返回当前周';
      case ActionItem.selectTimetable:
        return '选择课表';
      case ActionItem.themeSettings:
        return '主题';
      case ActionItem.swapCourse:
        return '调课';
    }
  }

  IconData get icon {
    switch (this) {
      case ActionItem.importTimetable:
        return Icons.school;
      case ActionItem.exportTimetable:
        return Icons.share;
      case ActionItem.importJson:
        return Icons.file_download;
      case ActionItem.previousWeek:
        return Icons.chevron_left;
      case ActionItem.nextWeek:
        return Icons.chevron_right;
      case ActionItem.goToCurrentWeek:
        return Icons.radio_button_checked;
      case ActionItem.selectTimetable:
        return Icons.calendar_today;
      case ActionItem.themeSettings:
        return Icons.palette;
      case ActionItem.swapCourse:
        return Icons.swap_horiz;
    }
  }

  static const int maxAppBarItems = 4;
}
