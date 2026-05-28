import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/action_item.dart';
import '../../core/utils/vibrate.dart';
import '../../core/config/app_bar_config.dart';
import '../../core/constants/app_strings.dart';
import '../../data/datasources/database.dart' hide Course, TimeDetail, Schedule;
import '../../data/models/course.dart';
import '../providers/course_provider.dart';
import '../providers/schedule_provider.dart';
import '../providers/semester_provider.dart';
import '../widgets/course_detail_bottom_sheet.dart';
import '../widgets/course_grid_widget.dart';
import '../widgets/export_import_dialogs.dart';
import '../widgets/mutable_barrier_route.dart';
import '../widgets/schedule_popup.dart';
import '../widgets/swap_course_dialog.dart';
import '../widgets/theme_settings_dialog.dart';

class WeekSchedulePage extends ConsumerStatefulWidget {
  const WeekSchedulePage({super.key});

  @override
  ConsumerState<WeekSchedulePage> createState() => _WeekSchedulePageState();
}

class _WeekSchedulePageState extends ConsumerState<WeekSchedulePage> {
  late final PageController _pageController;
  int _displayedWeek = 1;  // Updated by PageController listener
  List<ActionItem> _appBarActionItems = [];

  @override
  void initState() {
    super.initState();
    final currentWeek = ref.read(currentWeekProvider);
    _pageController = PageController(initialPage: currentWeek - 1);
    _displayedWeek = currentWeek;
    _pageController.addListener(_onPageScroll);
    _loadAppBarConfig();
  }

  @override
  void dispose() {
    _pageController.removeListener(_onPageScroll);
    _pageController.dispose();
    super.dispose();
  }

  void _onPageScroll() {
    final page = _pageController.page;
    if (page == null) return;
    final newWeek = (page.round() + 1).clamp(1, _getTotalWeeks());
    if (newWeek != _displayedWeek) {
      setState(() => _displayedWeek = newWeek);
    }
  }

  Future<void> _loadAppBarConfig() async {
    final items = await AppBarConfig.loadActionItems();
    if (mounted) {
      setState(() => _appBarActionItems = items);
    }
  }

  int _getTotalWeeks() {
    return ref.read(activeSemesterProvider).valueOrNull?.totalWeeks ?? 16;
  }

  int _getDisplayedWeek() {
    return _displayedWeek;
  }

  List<int> _getDisplayedWeekdays() {
    final schedule = ref.read(currentScheduleProvider).valueOrNull;
    final weekdays = schedule?.displayedWeekdays ?? [1, 2, 3, 4, 5];
    return weekdays.where((d) => d >= 1 && d <= 7).toList()..sort();
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final courseListAsync = ref.watch(courseListProvider);
    final semesterAsync = ref.watch(activeSemesterProvider);
    final currentWeek = ref.watch(currentWeekProvider);
    ref.watch(scheduleListProvider);
    ref.watch(currentScheduleProvider);

    final semester = semesterAsync.valueOrNull;
    final totalWeeks = semester?.totalWeeks ?? 16;
    final displayedWeek = _displayedWeek;
    final isCurrentWeek = displayedWeek == currentWeek;

    return Scaffold(
      appBar: _buildAppBar(semester, displayedWeek, currentWeek, isCurrentWeek),
      body: _buildBody(semesterAsync, courseListAsync, semester, totalWeeks),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Vibrate.light();
          context.push('/add');
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // AppBar
  // ---------------------------------------------------------------------------

  PreferredSizeWidget _buildAppBar(
    SemesterConfigData? semester,
    int displayedWeek,
    int currentWeek,
    bool isCurrentWeek,
  ) {
    return AppBar(
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
            _buildTitle(semester, displayedWeek),
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
        ..._appBarActionItems.take(ActionItem.maxAppBarItems).map(
              (item) => IconButton(
                icon: Icon(item.icon, size: 20),
                tooltip: item.displayName,
                onPressed: () {
                  Vibrate.light();
                  _handleAppBarAction(context, item);
                },
              ),
            ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: AppStrings.more,
          onPressed: () {
            Vibrate.light();
            _showSchedulePopup(context);
          },
        ),
      ],
    );
  }

  String _buildTitle(SemesterConfigData? semester, int displayedWeek) {
    if (semester == null) return AppStrings.appTitle;
    return '${AppStrings.weekLabel}$displayedWeek${AppStrings.weekSuffix}';
  }

  String _buildTodayDateLabel() {
    final now = DateTime.now();
    return '${now.month}月${now.day}日';
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _buildBody(
    AsyncValue<SemesterConfigData?> semesterAsync,
    AsyncValue<List<Course>> courseListAsync,
    SemesterConfigData? semester,
    int totalWeeks,
  ) {
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
            final schedule =
                ref.read(currentScheduleProvider).valueOrNull;
            final periodCount = schedule?.maxCoursesPerDay ?? 12;
            return PageView.builder(
              controller: _pageController,
              itemCount: totalWeeks,
              itemBuilder: (context, index) {
                final week = index + 1;
                return CourseGridWidget(
                  courses: courses,
                  displayedWeek: week,
                  totalWeeks: totalWeeks,
                  periodCount: periodCount,
                  displayedWeekdays: _getDisplayedWeekdays(),
                  semesterStart: DateTime.parse(semester.startDate),
                  onCourseTap: (course) => _showCourseDetail(course),
                );
              },
            );
          },
        );
      },
    );
  }

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
              onPressed: () {
                Vibrate.light();
                ref.invalidate(courseListProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text(AppStrings.retry),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Course detail
  // ---------------------------------------------------------------------------

  void _showCourseDetail(Course course) {
    CourseDetailBottomSheet.show(context, course, onDelete: () {
      _confirmDelete(course);
    });
  }

  void _confirmDelete(Course course) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(AppStrings.confirmDeleteTitle),
        content: Text('${AppStrings.confirmDeleteMessage}"${course.name}"?'),
        actions: [
          TextButton(
            onPressed: () {
              Vibrate.light();
              Navigator.pop(ctx);
            },
            child: const Text(AppStrings.cancel),
          ),
          TextButton(
            onPressed: () async {
              Vibrate.light();
              Navigator.pop(ctx);
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

  // ---------------------------------------------------------------------------
  // AppBar actions
  // ---------------------------------------------------------------------------

  void _showThemeSettingsOverlay(BuildContext pageContext) {
    final dragNotifier = ValueNotifier<bool>(false);

    Navigator.of(pageContext).push(
      MutableBarrierRoute<bool>(
        dragNotifier: dragNotifier,
        builder: (_) => ThemeSettingsDialog(
          onDragChanged: (v) => dragNotifier.value = v,
          onClose: () => Navigator.of(pageContext).pop(),
        ),
      ),
    );
  }

  void _handleAppBarAction(BuildContext context, ActionItem item) {
    switch (item) {
      case ActionItem.importTimetable:
        context.push('/import');
      case ActionItem.exportTimetable:
        ExportDialog.show(context,
            ref.read(courseListProvider).valueOrNull ?? []);
      case ActionItem.importJson:
        ImportFromTextDialog.show(context);
      case ActionItem.previousWeek:
        _pageController.previousPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      case ActionItem.nextWeek:
        _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      case ActionItem.goToCurrentWeek:
        final currentWeek = ref.read(currentWeekProvider);
        _pageController.animateToPage(
          currentWeek - 1,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      case ActionItem.selectTimetable:
        context.push('/schedules');
      case ActionItem.themeSettings:
        _showThemeSettingsOverlay(context);
      case ActionItem.swapCourse:
        final courses = ref.read(courseListProvider).valueOrNull ?? [];
        final semester = ref.read(activeSemesterProvider).valueOrNull;
        if (semester != null) {
          SwapCourseDialog.show(
            context,
            courses,
            _displayedWeek,
            DateTime.parse(semester.startDate),
          );
        }
    }
  }

  void _showSchedulePopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, _, __) => SchedulePopup(
        displayedWeek: _getDisplayedWeek(),
        totalWeeks: _getTotalWeeks(),
        onWeekChanged: (week) {
          _pageController.animateToPage(
            week - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
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
}
