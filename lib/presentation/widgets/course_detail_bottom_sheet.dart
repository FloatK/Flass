import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/utils/l10n_utils.dart';
import '../../core/utils/vibrate.dart';
import '../../core/utils/week_utils.dart';
import '../../data/models/course.dart';
import '../../l10n/app_localizations.dart';

/// 课程详情底部弹窗。
///
/// 显示课程的教师、地点、时间安排，以及编辑/删除操作。
class CourseDetailBottomSheet extends StatelessWidget {
  final Course course;
  final VoidCallback? onDelete;

  const CourseDetailBottomSheet({
    super.key,
    required this.course,
    this.onDelete,
  });

  /// 显示课程详情底部弹窗。
  static void show(BuildContext context, Course course,
      {VoidCallback? onDelete}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) => CourseDetailBottomSheet(
        course: course,
        onDelete: onDelete,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return DraggableScrollableSheet(
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
              '${l10n.teacherLabel}: ${course.teacher}',
            ),
            if (course.location != null && course.location!.isNotEmpty)
              _buildInfoRow(
                Icons.location_on_outlined,
                '${l10n.locationLabel}: ${course.location}',
              ),
            const Divider(height: 24),
            // Time schedule header
            Text(
              l10n.timeSchedule,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
            ),
            const SizedBox(height: 8),
            // Time detail entries
            ...course.timeDetails.map(
              (td) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Text(_formatTimeDetail(l10n, td)),
              ),
            ),
            const Divider(height: 24),
            // Action buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Vibrate.light();
                      Navigator.pop(context);
                      context.push('/edit/${course.id}');
                    },
                    icon: const Icon(Icons.edit),
                    label: Text(l10n.edit),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      Vibrate.light();
                      Navigator.pop(context);
                      onDelete?.call();
                    },
                    icon: const Icon(Icons.delete),
                    label: Text(l10n.delete),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).colorScheme.error,
                      foregroundColor: Theme.of(context).colorScheme.onError,
                    ),
                  ),
                ),
              ],
            ),
          ],
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

  String _formatTimeDetail(AppLocalizations l10n, TimeDetail td) {
    final dayLabel = L10nUtils.getDayLabel(l10n, td.dayOfWeek);
    final endPeriod = td.startPeriod + td.duration - 1;
    final periodRange =
        td.duration > 1 ? '${td.startPeriod}-$endPeriod' : '${td.startPeriod}';
    final modeStr = td.singleOrDouble == 'single'
        ? l10n.singleWeek
        : td.singleOrDouble == 'double'
            ? l10n.doubleWeek
            : '';
    final weeksStr = WeekUtils.formatWeeks(td.weeks, everyWeekLabel: l10n.everyWeek);

    final parts = [
      '$dayLabel ${l10n.weekLabel}$periodRange${l10n.weekSuffix}',
      weeksStr,
      if (modeStr.isNotEmpty) modeStr,
    ];
    return parts.join(' | ');
  }
}
