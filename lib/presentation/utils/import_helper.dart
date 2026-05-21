import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/course.dart';
import '../../data/models/schedule.dart';
import '../providers/course_provider.dart';
import '../providers/schedule_provider.dart';

/// Shared import logic reused by both 教务导入 and 文本导入.
class ImportHelper {
  ImportHelper._();

  /// Shows the choice dialog, then executes the chosen import action.
  ///
  /// Keeps the dialog open during async import (with a loading indicator)
  /// so the widget tree stays stable. On completion, closes the dialog and
  /// calls [onComplete] (if any) for the caller to show a SnackBar etc.
  static Future<void> showChoiceDialogAndImport({
    required BuildContext context,
    required WidgetRef ref,
    required int courseCount,
    required List<Course> courses,
    required Future<void> Function(WidgetRef ref, List<Course> courses) onOverwrite,
    required Future<void> Function(WidgetRef ref, List<Course> courses) onNewSchedule,
    VoidCallback? onComplete,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => _ImportChoiceDialog(
        courseCount: courseCount,
        courses: courses,
        ref: ref,
        onOverwrite: onOverwrite,
        onNewSchedule: onNewSchedule,
        onComplete: onComplete,
      ),
    );
  }
}

class _ImportChoiceDialog extends StatefulWidget {
  final int courseCount;
  final List<Course> courses;
  final WidgetRef ref;
  final Future<void> Function(WidgetRef ref, List<Course> courses) onOverwrite;
  final Future<void> Function(WidgetRef ref, List<Course> courses) onNewSchedule;
  final VoidCallback? onComplete;

  const _ImportChoiceDialog({
    required this.courseCount,
    required this.courses,
    required this.ref,
    required this.onOverwrite,
    required this.onNewSchedule,
    this.onComplete,
  });

  @override
  State<_ImportChoiceDialog> createState() => _ImportChoiceDialogState();
}

class _ImportChoiceDialogState extends State<_ImportChoiceDialog> {
  bool _isImporting = false;
  String? _error;

  Future<void> _doOverwrite() async {
    setState(() { _isImporting = true; _error = null; });
    try {
      await widget.onOverwrite(widget.ref, widget.courses);
      if (mounted) {
        Navigator.pop(context);
        widget.onComplete?.call();
      }
    } catch (e) {
      if (mounted) setState(() { _isImporting = false; _error = '$e'; });
    }
  }

  Future<void> _doNewSchedule() async {
    Navigator.pop(context);
    widget.onNewSchedule(widget.ref, widget.courses);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(_isImporting
          ? '导入中...'
          : '共 ${widget.courseCount} 门课程'),
      content: _isImporting
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : _error != null
              ? Text('导入失败: $_error', style: TextStyle(color: Theme.of(context).colorScheme.error))
              : const Text('选择导入方式：'),
      actions: _isImporting
          ? []
          : [
              TextButton(
                onPressed: _doOverwrite,
                child: const Text('覆盖当前课表'),
              ),
              TextButton(
                onPressed: _doNewSchedule,
                child: const Text('新建课表并导入'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('取消'),
              ),
            ],
    );
  }
}

/// Overwrite the current schedule with [courses].
Future<void> overwriteImport(WidgetRef ref, List<Course> courses) async {
  final schedule = ref.read(currentScheduleProvider).valueOrNull;
  if (schedule != null) {
    await ref.read(courseListProvider.notifier).deleteAllByScheduleId(schedule.id);
  }
  final notifier = ref.read(courseListProvider.notifier);
  for (final c in courses) {
    await notifier.addCourse(c);
  }
}

/// Create a new schedule and import [courses] into it.
Future<void> newScheduleImport(
  WidgetRef ref,
  List<Course> courses, {
  String? scheduleName,
}) async {
  final uuid = const Uuid();
  final now = DateTime.now();
  final name = (scheduleName != null && scheduleName.isNotEmpty)
      ? scheduleName
      : '导入课表 ${now.month}月${now.day}日 '
          '${now.hour.toString().padLeft(2, '0')}:${now.minute.toString().padLeft(2, '0')}';
  final newSchedule = Schedule(
    id: uuid.v4(),
    name: name,
    isDefault: false,
    createdAt: now,
  );
  await ref.read(scheduleRepositoryProvider).createSchedule(newSchedule);
  ref.invalidate(scheduleListProvider);
  await ref.read(currentScheduleProvider.notifier).switchSchedule(newSchedule);

  final notifier = ref.read(courseListProvider.notifier);
  for (final c in courses) {
    await notifier.addCourse(c);
  }
}
