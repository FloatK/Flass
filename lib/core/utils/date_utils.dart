import 'package:intl/intl.dart';

class DateUtils {
  DateUtils._();

  static String formatDateRange(DateTime start, DateTime end) {
    final formatter = DateFormat('MM.dd');
    return '${formatter.format(start)} - ${formatter.format(end)}';
  }

  static DateTime weekStart(DateTime date) {
    final weekday = date.weekday;
    return date.subtract(Duration(days: weekday - 1));
  }

  static DateTime weekEnd(DateTime date) {
    return weekStart(date).add(const Duration(days: 6));
  }

  static int currentWeekIndex(DateTime semesterStart, int totalWeeks) {
    final now = DateTime.now();
    final start = DateTime(semesterStart.year, semesterStart.month, semesterStart.day);
    final today = DateTime(now.year, now.month, now.day);
    final diff = today.difference(start).inDays;
    if (diff < 0) return 1;
    // Use integer division (floor) to correctly map days 0-6 to week 1,
    // days 7-13 to week 2, etc. Using .ceil() caused the last day of each
    // week (day 6, 13, etc.) to be misclassified as the next week.
    final week = (diff ~/ 7) + 1;
    return week.clamp(1, totalWeeks);
  }
}
