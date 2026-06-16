import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/config/action_item.dart';
import '../../core/utils/vibrate.dart';
import '../../core/config/app_bar_config.dart';
import '../../data/models/course.dart';
import '../../data/models/schedule.dart';
import '../../l10n/app_localizations.dart';
import '../providers/course_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/app_dialogs.dart';
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
  PageController? _pageController;
  int _displayedWeek = 1;  // Synced with PageController via _onPageScroll
  int _lastTotalWeeks = 0;  // Track totalWeeks to detect changes
  List<ActionItem> _appBarActionItems = [];
  List<ActionItem> _allAvailableItems = [];

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    // PageController and _displayedWeek are lazily initialized in build()
    // once currentScheduleProvider has loaded. Initializing them here
    // would read a stale value from currentWeekProvider (which falls back
    // to 1 while the schedule is still loading asynchronously).
    _loadAppBarConfig();
  }

  @override
  void dispose() {
    _pageController?.removeListener(_onPageScroll);
    _pageController?.dispose();
    super.dispose();
  }

  /// Create or recreate the PageController when the schedule is loaded
  /// or when totalWeeks changes.
  ///
  /// Called from build() so that the initial page matches the actual
  /// current week (after currentScheduleProvider has resolved).
  void _ensurePageControllerInitialized(Schedule schedule, int currentWeek) {
    final totalWeeks = schedule.totalWeeks;
    
    // If totalWeeks changed, dispose the old controller and recreate
    if (_pageController != null && _lastTotalWeeks != totalWeeks) {
      _pageController?.removeListener(_onPageScroll);
      _pageController?.dispose();
      _pageController = null;
    }
    
    if (_pageController == null) {
      final clampedWeek = currentWeek.clamp(1, totalWeeks);
      _displayedWeek = clampedWeek;
      _pageController = PageController(initialPage: clampedWeek - 1);
      _pageController!.addListener(_onPageScroll);
      _lastTotalWeeks = totalWeeks;
    }
  }

  void _onPageScroll() {
    final controller = _pageController;
    if (controller == null) return;
    final page = controller.page;
    if (page == null) return;
    final newWeek = (page.round() + 1).clamp(1, _getTotalWeeks());
    if (newWeek != _displayedWeek) {
      setState(() => _displayedWeek = newWeek);
    }
  }

  Future<void> _loadAppBarConfig() async {
    final items = await AppBarConfig.loadActionItems();
    if (mounted) {
      // 创建所有 ActionItem 的覆盖版本（包括不在 AppBar 中的）
      final allItems = ActionItemRegistry.instance.getAll();
      final overriddenAll = allItems.map((item) => _overrideItemCallback(item)).toList();
      final overriddenAppBar = items.map((item) => _overrideItemCallback(item)).toList();
      setState(() {
        _appBarActionItems = overriddenAppBar;
        _allAvailableItems = overriddenAll;
      });
    }
  }

  /// 覆盖需要页面状态的 ActionItem 回调
  ActionItem _overrideItemCallback(ActionItem item) {
    switch (item.id) {
      case 'exportTimetable':
        return item.copyWith(
          onPressed: (context) {
            ExportDialog.show(
                context, ref.read(courseListProvider).valueOrNull ?? []);
          },
        );
      case 'previousWeek':
        return item.copyWith(
          onPressed: (context) {
            _pageController?.previousPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      case 'nextWeek':
        return item.copyWith(
          onPressed: (context) {
            _pageController?.nextPage(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      case 'goToCurrentWeek':
        return item.copyWith(
          onPressed: (context) {
            final currentWeek = ref.read(currentWeekProvider);
            _pageController?.animateToPage(
              currentWeek - 1,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            );
          },
        );
      case 'themeSettings':
        return item.copyWith(
          onPressed: (context) {
            _showThemeSettingsOverlay(context);
          },
        );
      case 'swapCourse':
        return item.copyWith(
          onPressed: (context) {
            final courses =
                ref.read(courseListProvider).valueOrNull ?? [];
            final schedule =
                ref.read(currentScheduleProvider).valueOrNull;
            final startDate = schedule?.startDate;
            if (startDate != null) {
              SwapCourseDialog.show(
                context,
                courses,
                _displayedWeek,
                DateTime.parse(startDate),
              );
            }
          },
        );
      default:
        return item;
    }
  }

  int _getTotalWeeks() {
    final schedule = ref.read(currentScheduleProvider).valueOrNull;
    return schedule?.totalWeeks ?? 20;
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
    final scheduleAsync = ref.watch(currentScheduleProvider);
    // 使用 ref.listen 而非 ref.watch，避免 scheduleList 变化时重建整个页面
    ref.listen(scheduleListProvider, (_, __) {});
    final schedule = scheduleAsync.valueOrNull;
    final currentWeek = ref.watch(currentWeekProvider);

    // Lazy-init the PageController once the schedule has loaded.
    // This must run in build (not initState) because currentWeekProvider
    // depends on the async currentScheduleProvider, which is not yet
    // resolved when initState runs.
    if (schedule != null) {
      _ensurePageControllerInitialized(schedule, currentWeek);
    }

    final totalWeeks = schedule?.totalWeeks ?? 20;
    final displayedWeek = _displayedWeek;
    final isCurrentWeek = displayedWeek == currentWeek;

    return Scaffold(
      appBar: _buildAppBar(schedule, displayedWeek, currentWeek, isCurrentWeek),
      body: _buildBody(courseListAsync, schedule, totalWeeks),
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
    Schedule? schedule,
    int displayedWeek,
    int currentWeek,
    bool isCurrentWeek,
  ) {
    return AppBar(
      leadingWidth: 90,
      leading: schedule != null
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
            _buildTitle(schedule, displayedWeek),
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          if (schedule != null && !isCurrentWeek)
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
                tooltip: item.displayNameBuilder(context),
                onPressed: () {
                  Vibrate.light();
                  item.onPressed(context);
                },
              ),
            ),
        IconButton(
          icon: const Icon(Icons.more_vert),
          tooltip: l10n.more,
          onPressed: () {
            Vibrate.light();
            _showSchedulePopup(context);
          },
        ),
      ],
    );
  }

  String _buildTitle(Schedule? schedule, int displayedWeek) {
    if (schedule == null) return l10n.appTitle;
    return '${l10n.weekLabel}$displayedWeek${l10n.weekSuffix}';
  }

  String _buildTodayDateLabel() {
    final now = DateTime.now();
    return '${now.month}月${now.day}日';
  }

  // ---------------------------------------------------------------------------
  // Body
  // ---------------------------------------------------------------------------

  Widget _buildBody(
    AsyncValue<List<Course>> courseListAsync,
    Schedule? schedule,
    int totalWeeks,
  ) {
    if (schedule == null) {
      return Center(
        child: Text(
          l10n.noCourse,
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
              l10n.noCourse,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          );
        }
        final periodCount = schedule.maxCoursesPerDay;
        final startDate = schedule.startDate;
        if (startDate == null || startDate.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.calendar_today,
                    size: 48,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                const SizedBox(height: 16),
                Text(
                  l10n.startDateNotSet,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.startDateNotSetHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                ),
              ],
            ),
          );
        }
        final semesterStart = DateTime.tryParse(startDate);
        if (semesterStart == null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error_outline,
                    size: 48,
                    color: Theme.of(context).colorScheme.error),
                const SizedBox(height: 16),
                Text(
                  l10n.startDateNotSet,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  '${l10n.startDateNotSetHint}\n($startDate)',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }
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
              semesterStart: semesterStart,
              onCourseTap: (course) => _showCourseDetail(course),
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
              l10n.loadFailed,
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
              label: Text(l10n.retry),
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

  Future<void> _confirmDelete(Course course) async {
    final confirmed = await AppDialogs.confirmDelete(
      context,
      itemName: course.name,
    );
    if (!confirmed || !mounted) return;
    await ref.read(courseListProvider.notifier).deleteCourse(course.id);
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

  void _showSchedulePopup(BuildContext context) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: '',
      pageBuilder: (ctx, _, _) => SchedulePopup(
        displayedWeek: _getDisplayedWeek(),
        totalWeeks: _getTotalWeeks(),
        onWeekChanged: (week) {
          _pageController?.animateToPage(
            week - 1,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
          );
        },
        appBarItems: _appBarActionItems,
        allAvailableItems: _allAvailableItems,
        onConfigChanged: () {
          _loadAppBarConfig();
          setState(() {});
        },
        onActionItem: (item) => item.onPressed(context),
      ),
    );
  }
}
