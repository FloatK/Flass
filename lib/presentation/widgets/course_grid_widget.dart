import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/l10n_utils.dart';
import '../../data/models/course.dart';
import '../../l10n/app_localizations.dart';
import '../providers/theme_provider.dart';
import 'course_block_widget.dart';

/// 课程时间段槽位。
class CourseSlot {
  final Course course;
  final TimeDetail timeDetail;
  const CourseSlot({required this.course, required this.timeDetail});
}

/// 课表周视图网格组件。
///
/// 显示一周的课程表格，支持点击课程查看详情。
/// 注意：周次切换由外部 PageView 处理，本组件不处理滑动手势。
class CourseGridWidget extends ConsumerWidget {
  final List<Course> courses;
  final int displayedWeek;
  final int totalWeeks;
  final int periodCount;
  final List<int> displayedWeekdays;
  final DateTime semesterStart;
  final void Function(Course course)? onCourseTap;

  const CourseGridWidget({
    super.key,
    required this.courses,
    required this.displayedWeek,
    required this.totalWeeks,
    this.periodCount = 12,
    required this.displayedWeekdays,
    required this.semesterStart,
    this.onCourseTap,
  });

  static const double _periodLabelWidth = 40.0;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final weekStart =
        semesterStart.add(Duration(days: (displayedWeek - 1) * 7));
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    // 只订阅影响网格背景的字段，避免其他设置变化导致重建
    final followThemeBackground = ref.watch(
        themeSettingsProvider.select((s) => s.followThemeBackground));
    final colorIndex = ref.watch(
        themeSettingsProvider.select((s) => s.colorIndex));
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridBgColor = followThemeBackground
        ? (isDark
            ? HSLColor.fromColor(colorScheme.primary)
                .withSaturation((HSLColor.fromColor(colorScheme.primary).saturation * 0.7).clamp(0.0, 1.0))
                .withLightness(0.08)
                .toColor()
            : HSLColor.fromColor(colorScheme.primary).withLightness(0.95).toColor())
        : (isDark ? const Color(0xFF1E1E1E) : Colors.white);

    return Container(
      color: gridBgColor,
      child: Column(
        children: [
          _buildHeader(context, ref, l10n, weekStart, todayStart),
          Expanded(
            child: SingleChildScrollView(
              child: _buildGridBody(context, ref),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Header
  // ---------------------------------------------------------------------------

  Widget _buildHeader(
      BuildContext context, WidgetRef ref, AppLocalizations l10n, DateTime weekStart, DateTime todayStart) {
    final colorScheme = Theme.of(context).colorScheme;
    final weekdays = displayedWeekdays.where((d) => d >= 1 && d <= 7).toList()
      ..sort();

    return Row(
      children: [
        SizedBox(
          width: _periodLabelWidth,
          child: Container(
            height: 56,
            alignment: Alignment.center,
            child: Text(
              '${weekStart.month}月',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w600,
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
        ...weekdays.map((dayOfWeek) {
          final i = dayOfWeek - 1;
          final date = weekStart.add(Duration(days: i));
          final day = date.day;
          final isToday =
              DateTime(date.year, date.month, date.day) == todayStart;
          return Expanded(
            child: SizedBox(
              height: 56,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 24,
                    height: 24,
                    decoration: isToday
                        ? BoxDecoration(
                            color: colorScheme.primary,
                            shape: BoxShape.circle,
                          )
                        : null,
                    alignment: Alignment.center,
                    child: Text(
                      '$day',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight:
                            isToday ? FontWeight.bold : FontWeight.normal,
                        color: isToday ? Colors.white : null,
                      ),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    L10nUtils.getDayLabelByIndex(l10n, i),
                    style: TextStyle(
                      fontSize: 11,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ],
    );
  }

  // ---------------------------------------------------------------------------
  // Grid body
  // ---------------------------------------------------------------------------

  Widget _buildGridBody(BuildContext context, WidgetRef ref) {
    final weekdays =
        displayedWeekdays.where((d) => d >= 1 && d <= 7).toList()..sort();
    final hSpacing = ref.watch(
        themeSettingsProvider.select((s) => s.horizontalSpacing));
    final blockHeight = ref.watch(
        themeSettingsProvider.select((s) => s.blockHeight));
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period labels column
        SizedBox(
          width: _periodLabelWidth,
          child: Column(
            children: List.generate(
              periodCount,
              (index) => Container(
                height: blockHeight,
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        // Day columns
        ...weekdays.map(
          (dayOfWeek) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: dayOfWeek != weekdays.first ? hSpacing : 0,
              ),
              child: _buildDayColumn(ref, dayOfWeek, isDark: isDark),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDayColumn(WidgetRef ref, int dayOfWeek, {required bool isDark}) {
    final slots = _getActiveSlotsForDay(dayOfWeek);
    final blockHeight = ref.watch(
        themeSettingsProvider.select((s) => s.blockHeight));
    final courseSpacing = ref.watch(
        themeSettingsProvider.select((s) => s.courseSpacing));

    return SizedBox(
      height: periodCount * blockHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: slots.map((slot) {
          final top = (slot.timeDetail.startPeriod - 1) * blockHeight;
          final height =
              (slot.timeDetail.duration * blockHeight - courseSpacing)
                  .clamp(0.0, double.infinity);
          return Positioned(
            top: top,
            left: 0,
            right: 0,
            height: height,
            child: _buildCourseBlock(ref, slot.course, isDark: isDark),
          );
        }).toList(),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Course block
  // ---------------------------------------------------------------------------

  Widget _buildCourseBlock(WidgetRef ref, Course course, {required bool isDark}) {
    return CourseBlockWidget(
      course: course,
      isDark: isDark,
      onTap: () => onCourseTap?.call(course),
    );
  }

  // ---------------------------------------------------------------------------
  // Course filtering
  // ---------------------------------------------------------------------------

  List<CourseSlot> _getActiveSlotsForDay(int dayOfWeek) {
    final slots = <CourseSlot>[];
    for (final course in courses) {
      for (final td in course.timeDetails) {
        if (td.dayOfWeek == dayOfWeek &&
            (td.weeks.isEmpty || td.weeks.contains(displayedWeek))) {
          slots.add(CourseSlot(course: course, timeDetail: td));
        }
      }
    }
    return slots;
  }
}
