import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/vibrate.dart';
import '../../data/models/course.dart';
import '../providers/theme_provider.dart';

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
    final weekStart =
        semesterStart.add(Duration(days: (displayedWeek - 1) * 7));
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    final settings = ref.watch(themeSettingsProvider);
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gridBgColor = settings.getGridBackgroundColor(colorScheme, isDark);

    return Container(
      color: gridBgColor,
      child: Column(
        children: [
          _buildHeader(context, ref, weekStart, todayStart),
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
      BuildContext context, WidgetRef ref, DateTime weekStart, DateTime todayStart) {
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
                    AppStrings.dayLabels[i],
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
    final settings = ref.watch(themeSettingsProvider);
    final hSpacing = settings.horizontalSpacing;
    final blockHeight = settings.blockHeight;
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
    final settings = ref.watch(themeSettingsProvider);
    final blockHeight = settings.blockHeight;
    final courseSpacing = settings.courseSpacing;

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
    final tSettings = ref.watch(themeSettingsProvider);

    final baseColor = course.color != 0
        ? Color(course.color)
        : Color(AppColors.presetCourseColors[0]);

    Color courseColor;
    if (isDark) {
      // Dark mode: auto-dim colors
      courseColor = tSettings.getDarkModeCourseColor(baseColor.value);
    } else {
      // Light mode: use normal color adjustment
      final hsl = HSLColor.fromColor(baseColor);
      final adjustedLightness =
          (hsl.lightness * tSettings.colorLightness).clamp(0.0, 1.0);
      courseColor = hsl.withLightness(adjustedLightness).toColor();
    }

    final radius = tSettings.cornerRadius;

    return GestureDetector(
      onTap: () {
        Vibrate.light();
        onCourseTap?.call(course);
      },
      child: Container(
        clipBehavior: Clip.hardEdge,
        decoration: BoxDecoration(
          color: courseColor,
          borderRadius: BorderRadius.circular(radius),
        ),
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              course.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            if (course.location != null && course.location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  course.location!,
                  style: const TextStyle(color: Colors.white, fontSize: 9),
                ),
              ),
          ],
        ),
      ),
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
