import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/utils/date_utils.dart' as custom;
import '../../core/utils/export_utils.dart';
import '../../data/models/course.dart';
import '../../data/models/schedule.dart';
import '../providers/course_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/semester_provider.dart';

class WeekSchedulePage extends ConsumerStatefulWidget {
  const WeekSchedulePage({super.key});

  @override
  ConsumerState<WeekSchedulePage> createState() => _WeekSchedulePageState();
}

class _WeekSchedulePageState extends ConsumerState<WeekSchedulePage> {
  int _weekOffset = 0;

  static const int _totalPeriods = 12;
  static const double _periodHeight = 48.0;
  static const double _periodLabelWidth = 80.0;
  static const Color _gridBorderColor = Color(0xFFEEEEEE);
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
      final semesterStart = DateTime.parse(semester.startDate);
      final weekStart =
          semesterStart.add(Duration(days: (displayedWeek - 1) * 7));
      final weekEnd = weekStart.add(const Duration(days: 6));
      final dateRange = custom.DateUtils.formatDateRange(weekStart, weekEnd);
      return '${semester.name} ${AppStrings.weekLabel}$displayedWeek${AppStrings.weekSuffix} ($dateRange)';
    }

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
              return _buildScheduleGrid(courses, displayedWeek);
            },
          );
        },
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: GestureDetector(
          onTap: _showScheduleSwitcher,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(child: Text(buildTitle(), overflow: TextOverflow.ellipsis)),
              const Icon(Icons.arrow_drop_down, size: 20),
            ],
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: (currentWeek + _weekOffset) > 1
                ? () => setState(() => _weekOffset--)
                : null,
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: (currentWeek + _weekOffset) < totalWeeks
                ? () => setState(() => _weekOffset++)
                : null,
          ),
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'import':
                  context.push('/import');
                case 'export':
                  _exportCourses();
                case 'import_json':
                  _importJson();
                case 'settings':
                  context.push('/settings/semester');
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'import',
                child: ListTile(
                  leading: Icon(Icons.school),
                  title: Text(AppStrings.importFromEdu),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'export',
                child: ListTile(
                  leading: Icon(Icons.file_upload_outlined),
                  title: Text(AppStrings.exportSchedule),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuItem(
                value: 'import_json',
                child: ListTile(
                  leading: Icon(Icons.file_download_outlined),
                  title: Text('导入 JSON'),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'settings',
                child: ListTile(
                  leading: Icon(Icons.settings),
                  title: Text(AppStrings.semesterSettings),
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
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

  Widget _buildScheduleGrid(List<Course> courses, int displayedWeek) {
    return Column(
      children: [
        _buildHeaderRow(),
        Expanded(
          child: SingleChildScrollView(
            child: _buildGridBody(courses, displayedWeek),
          ),
        ),
      ],
    );
  }

  Widget _buildHeaderRow() {
    return Row(
      children: [
        const SizedBox(width: _periodLabelWidth),
        ...List.generate(
          7,
          (index) => Expanded(
            child: Container(
              height: 40,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                border: Border(
                  bottom: BorderSide(color: _gridBorderColor, width: 1),
                ),
              ),
              child: Text(
                _dayLabels[index],
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGridBody(List<Course> courses, int displayedWeek) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Period labels column
        SizedBox(
          width: _periodLabelWidth,
          child: Column(
            children: List.generate(
              _totalPeriods,
              (index) => Container(
                height: _periodHeight,
                alignment: Alignment.center,
                decoration: const BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: _gridBorderColor, width: 0.5),
                  ),
                ),
                child: Text(
                  '${index + 1}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ),
            ),
          ),
        ),
        // 7 day columns
        ...List.generate(
          7,
          (dayIndex) => Expanded(
            child: _buildDayColumn(dayIndex + 1, courses, displayedWeek),
          ),
        ),
      ],
    );
  }

  Widget _buildDayColumn(
    int dayOfWeek,
    List<Course> courses,
    int displayedWeek,
  ) {
    final slots = _getActiveSlotsForDay(dayOfWeek, courses, displayedWeek);

    return SizedBox(
      height: _totalPeriods * _periodHeight,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Grid cell backgrounds
          ...List.generate(
            _totalPeriods,
            (index) => Positioned(
              top: index * _periodHeight,
              left: 0,
              right: 0,
              height: _periodHeight,
              child: Container(
                decoration: const BoxDecoration(
                  border: Border(
                    bottom:
                        BorderSide(color: _gridBorderColor, width: 0.5),
                    right:
                        BorderSide(color: _gridBorderColor, width: 0.5),
                  ),
                ),
              ),
            ),
          ),
          // Course blocks
          ...slots.map((slot) {
            final top = (slot.timeDetail.startPeriod - 1) * _periodHeight;
            final height = slot.timeDetail.duration * _periodHeight;
            return Positioned(
              top: top + 1,
              left: 1,
              right: 1,
              height: height - 2,
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
    final courseColor =
        course.color != 0 ? Color(course.color) : Color(AppColors.presetCourseColors[0]);

    return GestureDetector(
      onTap: () => _showCourseDetailSheet(course),
      child: Container(
        decoration: BoxDecoration(
          color: courseColor,
          borderRadius: BorderRadius.circular(4),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 3),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              course.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            if (course.location != null && course.location!.isNotEmpty) ...[
              const SizedBox(height: 1),
              Text(
                course.location!,
                style: const TextStyle(color: Colors.white70, fontSize: 9),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
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

  // ---- Schedule switcher ----

  void _showScheduleSwitcher() {
    showModalBottomSheet(
      context: context,
      builder: (ctx) => Consumer(
        builder: (context, ref, _) {
          final schedulesAsync = ref.watch(scheduleListProvider);
          return schedulesAsync.when(
          data: (schedules) {
            final currentAsync = ref.watch(currentScheduleProvider);
            final currentId = currentAsync.valueOrNull?.id;
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Padding(
                  padding: EdgeInsets.all(16),
                  child: Text(
                    '切换课表',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
                ...schedules.map((s) => ListTile(
                      leading: Icon(
                        s.isDefault ? Icons.star : Icons.calendar_today,
                        color: s.id == currentId ? Theme.of(context).colorScheme.primary : null,
                      ),
                      title: Text(s.name),
                      trailing: s.id == currentId ? const Icon(Icons.check, size: 20) : null,
                      onTap: () {
                        ref.read(currentScheduleProvider.notifier).switchSchedule(s);
                        Navigator.pop(ctx);
                      },
                    )),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.edit),
                  title: const Text('管理课表'),
                  onTap: () {
                    Navigator.pop(ctx);
                    _showManageSchedulesDialog();
                  },
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('${AppStrings.loadFailed}: $e')),
        );
      },
    ),
    );
  }

  void _showManageSchedulesDialog() {
    final schedulesAsync = ref.read(scheduleListProvider);
    showDialog(
      context: context,
      builder: (ctx) {
        return schedulesAsync.when(
          data: (schedules) {
            return AlertDialog(
              title: const Text('管理课表'),
              content: SizedBox(
                width: double.maxFinite,
                child: ListView(
                  shrinkWrap: true,
                  children: [
                    ...schedules.map((s) => ListTile(
                          title: Text(s.name),
                          subtitle: s.isDefault ? const Text('默认') : null,
                          trailing: PopupMenuButton<String>(
                            onSelected: (action) {
                              Navigator.pop(ctx);
                              if (action == 'rename') {
                                _showRenameDialog(s);
                              } else if (action == 'delete') {
                                _confirmDeleteSchedule(s);
                              } else if (action == 'setDefault') {
                                ref.read(scheduleRepositoryProvider).setDefaultSchedule(s.id);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(value: 'rename', child: Text('重命名')),
                              if (!s.isDefault)
                                const PopupMenuItem(value: 'setDefault', child: Text('设为默认')),
                              if (!s.isDefault)
                                const PopupMenuItem(
                                  value: 'delete',
                                  child: Text('删除', style: TextStyle(color: Colors.red)),
                                ),
                            ],
                          ),
                        )),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _showCreateScheduleDialog();
                  },
                  child: const Text('新建课表'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('关闭'),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('$e')),
        );
      },
    );
  }

  void _showCreateScheduleDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建课表'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '课表名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await ref.read(scheduleRepositoryProvider).createSchedule(
                    Schedule(
                      id: const Uuid().v4(),
                      name: controller.text.trim(),
                      createdAt: DateTime.now(),
                    ),
                  );
              ref.invalidate(scheduleListProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('创建'),
          ),
        ],
      ),
    );
  }

  void _showRenameDialog(Schedule schedule) {
    final controller = TextEditingController(text: schedule.name);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('重命名课表'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(hintText: '新名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              if (controller.text.trim().isEmpty) return;
              await ref.read(scheduleRepositoryProvider).renameSchedule(
                    schedule.id,
                    controller.text.trim(),
                  );
              ref.invalidate(scheduleListProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('确认'),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteSchedule(Schedule schedule) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${schedule.name}」吗？\n该课表下的课程将变为未分类。'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () async {
              await ref.read(scheduleRepositoryProvider).deleteSchedule(schedule.id);
              ref.invalidate(scheduleListProvider);
              ref.invalidate(currentScheduleProvider);
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  void _exportCourses() {
    final courses = ref.read(courseListProvider).valueOrNull;
    if (courses == null || courses.isEmpty) return;
    final json = ExportUtils.exportToJson(courses);
    Clipboard.setData(ClipboardData(text: json));
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('课表数据已复制到剪贴板')),
    );
  }

  void _importJson() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('导入 JSON'),
        content: TextField(
          controller: controller,
          maxLines: 8,
          decoration: const InputDecoration(
            hintText: '粘贴 JSON 内容...',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('取消')),
          TextButton(
            onPressed: () {
              final text = controller.text.trim();
              if (text.isEmpty || !ExportUtils.isValidScheduleJson(text)) {
                ScaffoldMessenger.of(ctx).showSnackBar(
                  const SnackBar(content: Text('无效的 JSON 格式')),
                );
                return;
              }
              Navigator.pop(ctx);
              final courses = ExportUtils.importFromJson(text);
              final notifier = ref.read(courseListProvider.notifier);
              for (final c in courses) {
                notifier.addCourse(c);
              }
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('成功导入 ${courses.length} 门课程')),
              );
            },
            child: const Text('导入'),
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
