import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/action_item.dart';
import '../../core/config/app_bar_config.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/export_utils.dart';
import '../../data/datasources/database.dart' hide Course, TimeDetail, Schedule;
import '../../data/models/course.dart';
import '../../data/models/schedule.dart';
import '../providers/course_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/semester_provider.dart';
import '../providers/theme_provider.dart';
import '../utils/import_helper.dart';
import '../widgets/schedule_popup.dart';
import '../widgets/theme_settings_dialog.dart';

class WeekSchedulePage extends ConsumerStatefulWidget {
  const WeekSchedulePage({super.key});

  @override
  ConsumerState<WeekSchedulePage> createState() => _WeekSchedulePageState();
}

class _WeekSchedulePageState extends ConsumerState<WeekSchedulePage> {
  int _weekOffset = 0;
  List<ActionItem> _appBarActionItems = [];

  @override
  void initState() {
    super.initState();
    _loadAppBarConfig();
  }

  Future<void> _loadAppBarConfig() async {
    final items = await AppBarConfig.loadActionItems();
    if (mounted) {
      setState(() {
        _appBarActionItems = items;
      });
    }
  }

  int _periodCount(Schedule? schedule) => schedule?.maxCoursesPerDay ?? 12;
  static const double _periodLabelWidth = 40.0;
  static const List<String> _dayLabels = [
    AppStrings.mon,
    AppStrings.tue,
    AppStrings.wed,
    AppStrings.thu,
    AppStrings.fri,
    AppStrings.sat,
    AppStrings.sun,
  ];

  @override
  Widget build(BuildContext context) {
    final courseListAsync = ref.watch(courseListProvider);
    final semesterAsync = ref.watch(activeSemesterProvider);
    final currentWeek = ref.watch(currentWeekProvider);
    ref.watch(scheduleListProvider);
    ref.watch(currentScheduleProvider);

    final semester = semesterAsync.valueOrNull;
    final totalWeeks = semester?.totalWeeks ?? 16;
    final displayedWeek = (currentWeek + _weekOffset).clamp(1, totalWeeks);

    String buildTitle() {
      if (semester == null) return AppStrings.appTitle;
      return '${AppStrings.weekLabel}$displayedWeek${AppStrings.weekSuffix}';
    }

    String _buildTodayDateLabel() {
      final now = DateTime.now();
      return '${now.month}月${now.day}日';
    }

    final isCurrentWeek = displayedWeek == currentWeek;

    Widget buildBody() {
      return semesterAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => _buildErrorWidget(e),
        data: (semester) {
          if (semester == null) {
            return Center(
              child: Text(
                AppStrings.noCourse,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            );
          }
          return courseListAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (e, _) => _buildErrorWidget(e),
            data: (courses) {
              if (courses.isEmpty) {
                return Center(
                  child: Text(
                    AppStrings.noCourse,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                );
              }
              final pCount = _periodCount(
              ref.read(currentScheduleProvider).valueOrNull);
          return _buildScheduleGrid(
              courses, displayedWeek, semester, periodCount: pCount);
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        leadingWidth: 90,
        leading: semester != null
            ? Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Center(
                  child: Text(
                    _buildTodayDateLabel(),
                    maxLines: 1,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            : null,
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              buildTitle(),
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
            ),
            if (semester != null && !isCurrentWeek)
              Text(
                '(非本周)',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
          ],
        ),
        actions: [
          // Configurable action buttons (max 4)
          ..._appBarActionItems.take(ActionItem.maxAppBarItems).map(
                (item) => IconButton(
                  icon: Icon(item.icon, size: 20),
                  tooltip: item.displayName,
                  onPressed: () => _handleAppBarAction(context, item),
                ),
              ),
          // Overflow popup (always rightmost)
          IconButton(
            icon: const Icon(Icons.more_vert),
            tooltip: '更多',
            onPressed: () => _showSchedulePopup(context),
          ),
        ],
      ),
      body: buildBody(),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.push('/add'),
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Error widget
  // ---------------------------------------------------------------------------

  Widget _buildErrorWidget(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 12),
            Text(
              AppStrings.loadFailed,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            Text(
              '$error',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: () => ref.invalidate(courseListProvider),
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Schedule grid
  // ---------------------------------------------------------------------------

  Widget _buildScheduleGrid(
    List<Course> courses,
    int displayedWeek,
    SemesterConfigData semester, {
    int periodCount = 12,
  }) {
    final semesterStart = DateTime.parse(semester.startDate);
    final weekStart = semesterStart.add(Duration(days: (displayedWeek - 1) * 7));
    final totalWeeks = semester.totalWeeks;
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);

    return GestureDetector(
      onHorizontalDragEnd: (details) {
        if (details.primaryVelocity == null) return;
        if (details.primaryVelocity! < -100 && displayedWeek < totalWeeks) {
          setState(() => _weekOffset++);
        } else if (details.primaryVelocity! > 100 && displayedWeek > 1) {
          setState(() => _weekOffset--);
        }
      },
      child: Column(
        children: [
          _buildCombinedHeader(weekStart, todayStart),
          Expanded(
            child: SingleChildScrollView(
              child: _buildGridBody(courses, displayedWeek, periodCount: periodCount),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCombinedHeader(DateTime weekStart, DateTime todayStart) {
    final colorScheme = Theme.of(context).colorScheme;
    final displayedDays = _getDisplayedWeekdays();
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
          ...displayedDays.map((dayOfWeek) {
            final i = dayOfWeek - 1;
            final date = weekStart.add(Duration(days: i));
            final day = date.day;
            final isToday =
                DateTime(date.year, date.month, date.day) == todayStart;
            return Expanded(
              child: Container(
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
                      _dayLabels[i],
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

  Widget _buildGridBody(List<Course> courses, int displayedWeek,
      {int periodCount = 12}) {
    final displayedDays = _getDisplayedWeekdays();
    final hSpacing = ref.watch(themeSettingsProvider).horizontalSpacing;
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
                height: ref.watch(themeSettingsProvider).blockHeight,
                alignment: Alignment.center,
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        // displayed week day columns with horizontal spacing
        ...displayedDays.map(
          (dayOfWeek) => Expanded(
            child: Padding(
              padding: EdgeInsets.only(
                left: dayOfWeek != displayedDays.first ? hSpacing : 0,
              ),
              child: _buildDayColumn(
                  dayOfWeek, courses, displayedWeek, periodCount: periodCount),
            ),
          ),
        ),
      ],
    );
  }

  List<int> _getDisplayedWeekdays() {
    final schedule = ref.read(currentScheduleProvider).valueOrNull;
    final weekdays = schedule?.displayedWeekdays ?? [1, 2, 3, 4, 5];
    return weekdays.where((d) => d >= 1 && d <= 7).toList()..sort();
  }

  Widget _buildDayColumn(
    int dayOfWeek,
    List<Course> courses,
    int displayedWeek, {
    int periodCount = 12,
  }) {
    final slots = _getActiveSlotsForDay(dayOfWeek, courses, displayedWeek);

    final settings = ref.watch(themeSettingsProvider);
    final blockHeight = settings.blockHeight;
    final courseSpacing = settings.courseSpacing;

    return SizedBox(
      height: periodCount * blockHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Course blocks — no grid lines, tightly packed
          ...slots.map((slot) {
            final top = (slot.timeDetail.startPeriod - 1) * blockHeight;
            final height =
                (slot.timeDetail.duration * blockHeight - courseSpacing)
                    .clamp(0.0, double.infinity);
            return Positioned(
              top: top,
              left: 0,
              right: 0,
              height: height,
              child: _buildCourseBlock(slot.course),
            );
          }),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Course filtering
  // ---------------------------------------------------------------------------

  List<_CourseSlot> _getActiveSlotsForDay(
    int dayOfWeek,
    List<Course> courses,
    int displayedWeek,
  ) {
    final slots = <_CourseSlot>[];
    for (final course in courses) {
      for (final td in course.timeDetails) {
        if (td.dayOfWeek == dayOfWeek &&
            (td.weeks.isEmpty || td.weeks.contains(displayedWeek))) {
          slots.add(_CourseSlot(course: course, timeDetail: td));
        }
      }
    }
    return slots;
  }

  // ---------------------------------------------------------------------------
  // Course block
  // ---------------------------------------------------------------------------

  Widget _buildCourseBlock(Course course) {
    final tSettings = ref.watch(themeSettingsProvider);
    final baseColor =
        course.color != 0 ? Color(course.color) : Color(AppColors.presetCourseColors[0]);
    final hsl = HSLColor.fromColor(baseColor);
    final adjustedLightness =
        (hsl.lightness * tSettings.colorLightness).clamp(0.0, 1.0);
    final courseColor = hsl.withLightness(adjustedLightness).toColor();
    final radius = ref.watch(themeSettingsProvider).cornerRadius;

    return GestureDetector(
      onTap: () => _showCourseDetailSheet(course),
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
              maxLines: 100,
              overflow: TextOverflow.ellipsis,
            ),
            if (course.location != null && course.location!.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 1),
                child: Text(
                  course.location!,
                  style: const TextStyle(color: Colors.white70, fontSize: 9),
                  maxLines: 50,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Course detail bottom sheet
  // ---------------------------------------------------------------------------

  void _showCourseDetailSheet(Course course) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.5,
        minChildSize: 0.3,
        maxChildSize: 0.85,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(16),
          child: ListView(
            controller: scrollController,
            children: [
              // Drag handle
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Course name
              Text(
                course.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 12),
              // Teacher & location
              _buildInfoRow(
                Icons.person_outline,
                '${AppStrings.teacherLabel}: ${course.teacher}',
              ),
              if (course.location != null && course.location!.isNotEmpty)
                _buildInfoRow(
                  Icons.location_on_outlined,
                  '${AppStrings.locationLabel}: ${course.location}',
                ),
              const Divider(height: 24),
              // Time schedule header
              Text(
                AppStrings.timeSchedule,
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              const SizedBox(height: 8),
              // Time detail entries
              ...course.timeDetails.map(
                (td) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(_formatTimeDetail(td)),
                ),
              ),
              const Divider(height: 24),
              // Action buttons
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        context.push('/edit/${course.id}');
                      },
                      icon: const Icon(Icons.edit),
                      label: const Text(AppStrings.edit),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _confirmDelete(course),
                      icon: const Icon(Icons.delete),
                      label: const Text(AppStrings.delete),
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Theme.of(context).colorScheme.error,
                        foregroundColor:
                            Theme.of(context).colorScheme.onError,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(child: Text(text)),
        ],
      ),
    );
  }

  String _formatTimeDetail(TimeDetail td) {
    final dayLabel = _dayLabels[td.dayOfWeek - 1];
    final endPeriod = td.startPeriod + td.duration - 1;
    final periodRange =
        td.duration > 1 ? '${td.startPeriod}-$endPeriod' : '${td.startPeriod}';
    final modeStr = td.singleOrDouble == 'single'
        ? AppStrings.singleWeek
        : td.singleOrDouble == 'double'
            ? AppStrings.doubleWeek
            : '';
    final weeksStr = _formatWeeks(td.weeks);

    final parts = [
      '$dayLabel ${AppStrings.weekLabel}$periodRange${AppStrings.weekSuffix}',
      weeksStr,
      if (modeStr.isNotEmpty) modeStr,
    ];
    return parts.join(' | ');
  }

  String _formatWeeks(List<int> weeks) {
    if (weeks.isEmpty) return AppStrings.everyWeek;

    final sorted = List<int>.from(weeks)..sort();
    final ranges = <String>[];
    int start = sorted.first;
    int end = sorted.first;

    for (int i = 1; i < sorted.length; i++) {
      if (sorted[i] == end + 1) {
        end = sorted[i];
      } else {
        ranges.add(start == end ? '$start' : '$start-$end');
        start = sorted[i];
        end = sorted[i];
      }
    }
    ranges.add(start == end ? '$start' : '$start-$end');

    return '${AppStrings.weekLabel}${ranges.join(', ')}${AppStrings.weekSuffix}';
  }

  // ---------------------------------------------------------------------------
  // Delete confirmation
  // ---------------------------------------------------------------------------

  void _confirmDelete(Course course) {
    Navigator.pop(context); // Close bottom sheet first
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(AppStrings.confirmDeleteTitle),
        content: Text(
          '${AppStrings.confirmDeleteMessage}"${course.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref
                  .read(courseListProvider.notifier)
                  .deleteCourse(course.id);
            },
            child: const Text(AppStrings.confirm),
          ),
        ],
      ),
    );
  }

  // ---- AppBar action handlers ----

  void _handleAppBarAction(BuildContext context, ActionItem item) {
    final current = ref.read(currentWeekProvider);
    final total = _getTotalWeeks();
    final displayed = (current + _weekOffset).clamp(1, total);

    switch (item) {
      case ActionItem.importTimetable:
        context.push('/import');
      case ActionItem.exportTimetable:
        _exportCourses();
      case ActionItem.importJson:
        _importJson();
      case ActionItem.previousWeek:
        if (displayed > 1) setState(() => _weekOffset--);
      case ActionItem.nextWeek:
        if (displayed < total) setState(() => _weekOffset++);
      case ActionItem.goToCurrentWeek:
        setState(() => _weekOffset = 0);
      case ActionItem.selectTimetable:
        context.push('/schedules');
      case ActionItem.clearCache:
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('清除缓存'),
            content: const Text('确定要清除缓存吗？'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('取消'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('缓存已清除（占位）')),
                  );
                },
                child: const Text('确认'),
              ),
            ],
          ),
        );
      case ActionItem.about:
        showAboutDialog(
          context: context,
          applicationName: 'WakeUp 课程表',
          applicationVersion: '0.1.0',
        );
      case ActionItem.themeSettings:
        showDialog(
          context: context,
          builder: (_) => const ThemeSettingsDialog(),
        );
    }
  }

  void _showSchedulePopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, _, __) => SchedulePopup(
        displayedWeek: (ref.read(currentWeekProvider) + _weekOffset)
            .clamp(1, _getTotalWeeks()),
        totalWeeks: _getTotalWeeks(),
        onWeekChanged: (week) {
          final current = ref.read(currentWeekProvider);
          setState(() => _weekOffset = week - current);
        },
        appBarItems: _appBarActionItems,
        onConfigChanged: () {
          _loadAppBarConfig();
          setState(() {});
        },
        onActionItem: (item) => _handleAppBarAction(context, item),
      ),
    );
  }

  int _getTotalWeeks() {
    return ref.read(activeSemesterProvider).valueOrNull?.totalWeeks ?? 16;
  }

  // ---- Old schedule switcher (kept for compatibility) ----

  void _exportCourses() {
    final courses = ref.read(courseListProvider).valueOrNull;
    if (courses == null || courses.isEmpty) return;
    final compact = ExportUtils.compactEncode(courses);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('分享课表'),
        content: const Text('选择导出方式：'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              final copyText = '将该条消息复制，点击从文本导入即可导入课表。\n「$compact」';
              Clipboard.setData(ClipboardData(text: copyText));
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('已复制 (${compact.length} 字符)，打开从文本导入粘贴即可')),
              );
            },
            child: const Text('复制紧凑码'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                final dir = await getTemporaryDirectory();
                final file = File('${dir.path}/fl${DateTime.now().microsecondsSinceEpoch}.txt');
                final fileText = '将该条消息复制，点击从文本导入即可导入课表。\n「$compact」';
                await file.writeAsString(fileText);
                await Share.shareXFiles(
                  [XFile(file.path)],
                  text: '课表数据',
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('分享失败: $e')),
                );
              }
            },
            child: const Text('分享文件'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
        ],
      ),
    );
  }

  void _importJson() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('从文本导入'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '粘贴包含「紧凑码」的内容...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              final clipboardData = await Clipboard.getData(Clipboard.kTextPlain);
              if (clipboardData == null || clipboardData.text == null) return;
              controller.text = clipboardData.text!.trim();
            },
            child: const Text('从剪贴板粘贴'),
          ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              String text = controller.text.trim();
              if (text.isEmpty) return;

              // Extract compact code from 「…」
              final match = RegExp(r'「(.+?)」').firstMatch(text);
              if (match != null) text = match.group(1)!;

              List<Course> courses;
              try {
                final uuid = const Uuid();
                if (ExportUtils.isCompactFormat(text)) {
                  courses = ExportUtils.compactDecode(text);
                } else if (ExportUtils.isValidScheduleJson(text)) {
                  courses = ExportUtils.importFromJson(text);
                } else {
                  ScaffoldMessenger.of(ctx).showSnackBar(
                    const SnackBar(content: Text('无效的格式，请检查内容')),
                  );
                  return;
                }
                // Assign fresh UUIDs to avoid UNIQUE constraint conflicts
                courses = courses.map((c) => c.copyWith(id: uuid.v4())).toList();
              } catch (e) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  SnackBar(content: Text('导入失败: $e')),
                );
                return;
              }

              Navigator.pop(ctx);
              ImportHelper.showChoiceDialogAndImport(
                context: context,
                ref: ref,
                courseCount: courses.length,
                courses: courses,
                onOverwrite: overwriteImport,
                onNewSchedule: (r, c) async {
                  // Show name dialog, then import
                  final nameCtrl = TextEditingController();
                  await showDialog(
                    context: context,
                    builder: (ctx2) => AlertDialog(
                      title: const Text('新建课表'),
                      content: TextField(
                        controller: nameCtrl,
                        decoration: const InputDecoration(
                          labelText: '课表名称',
                          hintText: '留空则自动生成',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      actions: [
                        TextButton(onPressed: () => Navigator.pop(ctx2), child: const Text('取消')),
                        ElevatedButton(
                          onPressed: () {
                            Navigator.pop(ctx2);
                          },
                          child: const Text('确认导入'),
                        ),
                      ],
                    ),
                  );
                  await newScheduleImport(r, c,
                      scheduleName: nameCtrl.text.trim());
                },
                onComplete: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('成功导入 ${courses.length} 门课程')),
                  );
                },
              );
            },
            child: const Text('解析'),
          ),
        ],
      ),
    );
  }
}

// -----------------------------------------------------------------------------
// Helper
// -----------------------------------------------------------------------------

class _CourseSlot {
  final Course course;
  final TimeDetail timeDetail;
  const _CourseSlot({required this.course, required this.timeDetail});
}
