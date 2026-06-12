import '../../l10n/app_localizations.dart';

/// Utility class for localization-related helper functions.
class L10nUtils {
  L10nUtils._();

  /// Get the weekday label for a given dayOfWeek (1-7).
  /// Returns localized weekday name (周一, 周二, etc.).
  static String getDayLabel(AppLocalizations l10n, int dayOfWeek) {
    switch (dayOfWeek) {
      case 1:
        return l10n.mon;
      case 2:
        return l10n.tue;
      case 3:
        return l10n.wed;
      case 4:
        return l10n.thu;
      case 5:
        return l10n.fri;
      case 6:
        return l10n.sat;
      case 7:
        return l10n.sun;
      default:
        return '';
    }
  }

  /// Get the weekday label for a given index (0-6).
  /// Returns localized weekday name (周一, 周二, etc.).
  static String getDayLabelByIndex(AppLocalizations l10n, int index) {
    return getDayLabel(l10n, index + 1);
  }

  /// Format a date as "月/日" (e.g., "6/12").
  static String formatDateShort(DateTime date) {
    return '${date.month}/${date.day}';
  }

  /// Format a date as "X月X日" (e.g., "6月12日").
  static String formatDateChinese(DateTime date) {
    return '${date.month}月${date.day}日';
  }

  /// Format a date as "YYYY-MM-DD".
  static String formatDateISO(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  /// Format a date with weekday name.
  static String formatDateWithWeekday(AppLocalizations l10n, DateTime date) {
    final weekday = getDayLabel(l10n, date.weekday);
    return '${formatDateShort(date)} ($weekday)';
  }
}
