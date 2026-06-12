import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/l10n_utils.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/vibrate.dart';
import '../../data/models/course.dart';
import '../../l10n/app_localizations.dart';
import '../providers/course_provider.dart';

/// 调课对话框：将某天的课程移动到另一天。
class SwapCourseDialog extends ConsumerStatefulWidget {
  final List<Course> courses;
  final int displayedWeek;
  final DateTime semesterStart;

  const SwapCourseDialog({
    super.key,
    required this.courses,
    required this.displayedWeek,
    required this.semesterStart,
  });

  static void show(
    BuildContext context,
    List<Course> courses,
    int displayedWeek,
    DateTime semesterStart,
  ) {
    showDialog(
      context: context,
      builder: (_) => SwapCourseDialog(
        courses: courses,
        displayedWeek: displayedWeek,
        semesterStart: semesterStart,
      ),
    );
  }

  @override
  ConsumerState<SwapCourseDialog> createState() => _SwapCourseDialogState();
}

class _SwapCourseDialogState extends ConsumerState<SwapCourseDialog> {
  late DateTime _sourceDate;
  late DateTime _targetDate;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    // 默认选择本周的周一和周二
    final weekStart = widget.semesterStart
        .add(Duration(days: (widget.displayedWeek - 1) * 7));
    _sourceDate = weekStart;
    _targetDate = weekStart.add(const Duration(days: 1));
  }

  int _getDayOfWeek(DateTime date) => date.weekday;

  List<Course> _getCoursesForDate(DateTime date) {
    final dayOfWeek = date.weekday;
    return widget.courses.where((c) {
      return c.timeDetails.any((td) =>
          td.dayOfWeek == dayOfWeek &&
          (td.weeks.isEmpty || td.weeks.contains(widget.displayedWeek)));
    }).toList();
  }

  Future<void> _selectDate(bool isSource) async {
    final current = isSource ? _sourceDate : _targetDate;
    final picked = await showDatePicker(
      context: context,
      initialDate: current,
      firstDate: widget.semesterStart,
      lastDate: widget.semesterStart
          .add(Duration(days: (widget.displayedWeek) * 7 - 1)),
      locale: _getLocale(),
    );
    if (picked != null) {
      setState(() {
        if (isSource) {
          _sourceDate = picked;
        } else {
          _targetDate = picked;
        }
      });
    }
  }

  Locale _getLocale() {
    final locale = WidgetsBinding.instance.platformDispatcher.locale;
    return locale;
  }

  Future<void> _swapCourses() async {
    final sourceDay = _getDayOfWeek(_sourceDate);
    final targetDay = _getDayOfWeek(_targetDate);
    final sourceCourses = _getCoursesForDate(_sourceDate);

    if (sourceCourses.isEmpty) {
      showAppSnackBar(context, l10n.noCourseOnDate(_formatDate(_sourceDate)), isError: true);
      return;
    }

    final notifier = ref.read(courseListProvider.notifier);

    // Delete target day courses first
    final targetCourses = _getCoursesForDate(_targetDate);
    for (final c in targetCourses) {
      final newTimeDetails = c.timeDetails.where((td) {
        return !(td.dayOfWeek == targetDay &&
            (td.weeks.isEmpty || td.weeks.contains(widget.displayedWeek)));
      }).toList();

      if (newTimeDetails.isEmpty) {
        await notifier.deleteCourse(c.id);
      } else {
        await notifier.updateCourse(c.copyWith(timeDetails: newTimeDetails));
      }
    }

    // Move source courses to target day
    for (final c in sourceCourses) {
      final newTimeDetails = c.timeDetails.map((td) {
        if (td.dayOfWeek == sourceDay &&
            (td.weeks.isEmpty || td.weeks.contains(widget.displayedWeek))) {
          return td.copyWith(dayOfWeek: targetDay);
        }
        return td;
      }).toList();

      await notifier.updateCourse(c.copyWith(timeDetails: newTimeDetails));
    }

    if (mounted) {
      Navigator.pop(context);
      showAppSnackBar(context,
          l10n.swapSuccess(_formatDate(_sourceDate), _formatDate(_targetDate)));
    }
  }

  String _formatDate(DateTime date) {
    return L10nUtils.formatDateWithWeekday(l10n, date);
  }

  @override
  Widget build(BuildContext context) {
    final sourceCourses = _getCoursesForDate(_sourceDate);
    final targetCourses = _getCoursesForDate(_targetDate);

    return AlertDialog(
      title: Text(l10n.swapCourse),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              l10n.swapCourseDescription,
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 24),
            // Source date
            _buildDateSelector(
              label: l10n.swapFrom,
              date: _sourceDate,
              courseCount: sourceCourses.length,
              onTap: () {
                Vibrate.light();
                _selectDate(true);
              },
            ),
            const SizedBox(height: 16),
            // Arrow
            const Center(
              child: Icon(Icons.arrow_downward, size: 24),
            ),
            const SizedBox(height: 16),
            // Target date
            _buildDateSelector(
              label: l10n.swapTo,
              date: _targetDate,
              courseCount: targetCourses.length,
              onTap: () {
                Vibrate.light();
                _selectDate(false);
              },
            ),
            if (sourceCourses.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                l10n.swapMoveCount(sourceCourses.length),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.primary,
                    ),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            Vibrate.light();
            Navigator.pop(context);
          },
          child: Text(l10n.cancel),
        ),
        ElevatedButton(
          onPressed: _getDayOfWeek(_sourceDate) == _getDayOfWeek(_targetDate)
              ? null
              : () {
                  Vibrate.light();
                  _swapCourses();
                },
          child: Text(l10n.swapConfirm),
        ),
      ],
    );
  }

  Widget _buildDateSelector({
    required String label,
    required DateTime date,
    required int courseCount,
    required VoidCallback onTap,
  }) {
    final theme = Theme.of(context);
    final weekday = L10nUtils.getDayLabel(l10n, date.weekday);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outlineVariant),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: theme.textTheme.labelMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Icon(Icons.calendar_today,
                    size: 20, color: theme.colorScheme.onSurfaceVariant),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.dateYearMonthDay(date.year, date.month, date.day),
                        style: theme.textTheme.titleMedium,
                      ),
                      Text(
                        l10n.weekdayCourseCount(weekday, courseCount),
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.edit, size: 16, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
