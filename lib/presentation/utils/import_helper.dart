import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/vibrate.dart';
import '../../data/models/course.dart';
import '../../data/models/schedule.dart';
import '../../l10n/app_localizations.dart';
import '../providers/course_provider.dart';
import '../providers/schedule_provider.dart';

/// Shared import logic reused by both 教务导入 and 文本导入.
class ImportHelper {
  ImportHelper._();

  /// Shows the choice dialog, then executes the chosen import action.
  ///
  /// Uses ConsumerStatefulWidget so the dialog has its own ref,
  /// avoiding "ref disposed" errors when the parent widget is disposed.
  ///
  /// [onNewSchedule] receives [scheduleName] captured from the naming dialog.
  static Future<void> showChoiceDialogAndImport({
    required BuildContext context,
    required int courseCount,
    required List<Course> courses,
    required Future<void> Function(WidgetRef ref, List<Course> courses)
        onOverwrite,
    required Future<void> Function(
            WidgetRef ref, List<Course> courses, String? scheduleName)
        onNewSchedule,
    VoidCallback? onComplete,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => _ImportChoiceDialog(
        courseCount: courseCount,
        courses: courses,
        onOverwrite: onOverwrite,
        onNewSchedule: onNewSchedule,
        onComplete: onComplete,
      ),
    );
  }
}

class _ImportChoiceDialog extends ConsumerStatefulWidget {
  final int courseCount;
  final List<Course> courses;
  final Future<void> Function(WidgetRef ref, List<Course> courses) onOverwrite;
  final Future<void> Function(
          WidgetRef ref, List<Course> courses, String? scheduleName)
      onNewSchedule;
  final VoidCallback? onComplete;

  const _ImportChoiceDialog({
    required this.courseCount,
    required this.courses,
    required this.onOverwrite,
    required this.onNewSchedule,
    this.onComplete,
  });

  @override
  ConsumerState<_ImportChoiceDialog> createState() =>
      _ImportChoiceDialogState();
}

class _ImportChoiceDialogState extends ConsumerState<_ImportChoiceDialog> {
  bool _isImporting = false;
  String? _error;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  Future<void> _doOverwrite() async {
    setState(() {
      _isImporting = true;
      _error = null;
    });
    try {
      await widget.onOverwrite(ref, widget.courses);
      if (mounted) {
        await _showSemesterConfigDialog();
        if (mounted) {
          Navigator.pop(context);
          widget.onComplete?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _error = '$e';
        });
      }
    }
  }

  Future<void> _doNewSchedule() async {
    // Step 1: Show naming dialog using ImportHelper's own valid context
    final nameCtrl = TextEditingController();
    final scheduleName = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.newSchedule),
        content: TextField(
          controller: nameCtrl,
          decoration: InputDecoration(
            labelText: l10n.scheduleName,
            hintText: l10n.scheduleNameHint,
            border: const OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Vibrate.light();
              Navigator.pop(ctx);
            },
            child: Text(l10n.cancel),
          ),
          ElevatedButton(
            onPressed: () {
              Vibrate.light();
              Navigator.pop(ctx, nameCtrl.text.trim());
            },
            child: Text(l10n.confirmImport),
          ),
        ],
      ),
    );

    // User cancelled the naming dialog
    if (scheduleName == null || !mounted) return;

    // Step 2: Show loading state and execute import (dialog stays open)
    setState(() {
      _isImporting = true;
      _error = null;
    });
    try {
      await widget.onNewSchedule(ref, widget.courses, scheduleName);
      if (mounted) {
        await _showSemesterConfigDialog();
        if (mounted) {
          Navigator.pop(context);
          widget.onComplete?.call();
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isImporting = false;
          _error = '$e';
        });
      }
    }
  }

  /// Shows the semester config dialog after a successful import.
  /// Pre-fills with existing schedule config if available.
  ///
  /// After the user picks a start date, writes to Schedule.startDate.
  Future<void> _showSemesterConfigDialog() async {
    final currentSchedule = ref.read(currentScheduleProvider).valueOrNull;

    if (!mounted) return;

    final result = await showDialog<_SemesterConfigResult>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _SemesterConfigDialog(
        initialDate: currentSchedule?.startDate != null
            ? (DateTime.tryParse(currentSchedule!.startDate!) ?? DateTime.now())
            : DateTime.now(),
        initialWeeks: currentSchedule?.totalWeeks ?? 20,
      ),
    );

    if (result == null || !mounted) return;

    // Write to current Schedule (the active system)
    if (currentSchedule != null) {
      final updatedSchedule = currentSchedule.copyWith(
        startDate: result.startDate
            .toIso8601String()
            .split('T')[0], // 'YYYY-MM-DD'
        totalWeeks: result.totalWeeks,
      );
      await ref
          .read(currentScheduleProvider.notifier)
          .updateSchedule(updatedSchedule);
      // 关键：同时刷新课表列表，确保编辑页面能读取到最新的 startDate
      ref.invalidate(scheduleListProvider);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
          _isImporting ? l10n.importing : l10n.courseCountTitle(widget.courseCount)),
      content: _isImporting
          ? const SizedBox(
              height: 60,
              child: Center(child: CircularProgressIndicator()),
            )
          : _error != null
              ? Text(l10n.importFailedMsg(_error!),
                  style:
                      TextStyle(color: Theme.of(context).colorScheme.error))
              : Text(l10n.chooseImportMethod),
      actions: _isImporting
          ? []
          : [
              TextButton(
                onPressed: () {
                  Vibrate.light();
                  _doOverwrite();
                },
                child: Text(l10n.overwriteCurrentSchedule),
              ),
              TextButton(
                onPressed: () {
                  Vibrate.light();
                  _doNewSchedule();
                },
                child: Text(l10n.createNewScheduleAndImport),
              ),
              TextButton(
                onPressed: () {
                  Vibrate.light();
                  Navigator.pop(context);
                },
                child: Text(l10n.cancel),
              ),
            ],
    );
  }
}

/// Overwrite the current schedule with [courses].
Future<void> overwriteImport(WidgetRef ref, List<Course> courses) async {
  final schedule = ref.read(currentScheduleProvider).valueOrNull;
  if (schedule != null) {
    await ref
        .read(courseListProvider.notifier)
        .deleteAllByScheduleId(schedule.id);
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
  await ref
      .read(currentScheduleProvider.notifier)
      .switchSchedule(newSchedule);

  final notifier = ref.read(courseListProvider.notifier);
  for (final c in courses) {
    await notifier.addCourse(c);
  }
}

/// Result from the semester config dialog.
class _SemesterConfigResult {
  final DateTime startDate;
  final int totalWeeks;
  const _SemesterConfigResult({
    required this.startDate,
    required this.totalWeeks,
  });
}

/// Dialog for setting semester start date and total weeks.
class _SemesterConfigDialog extends StatefulWidget {
  final DateTime initialDate;
  final int initialWeeks;

  const _SemesterConfigDialog({
    required this.initialDate,
    required this.initialWeeks,
  });

  @override
  State<_SemesterConfigDialog> createState() => _SemesterConfigDialogState();
}

class _SemesterConfigDialogState extends State<_SemesterConfigDialog> {
  late DateTime _selectedDate;
  late TextEditingController _weeksController;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _selectedDate = widget.initialDate;
    _weeksController =
        TextEditingController(text: widget.initialWeeks.toString());
  }

  @override
  void dispose() {
    _weeksController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (date != null && mounted) {
      setState(() => _selectedDate = date);
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateStr =
        '${_selectedDate.year}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.day.toString().padLeft(2, '0')}';
    return AlertDialog(
      title: Text(l10n.setSemester),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            title: Text(l10n.startDate),
            subtitle: Text(dateStr),
            trailing: const Icon(Icons.calendar_today),
            onTap: _pickDate,
          ),
          TextField(
            controller: _weeksController,
            decoration: InputDecoration(labelText: l10n.totalWeeks),
            keyboardType: TextInputType.number,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(l10n.skip),
        ),
        ElevatedButton(
          onPressed: () {
            final weeks = int.tryParse(_weeksController.text);
            if (weeks == null || weeks < 1) return;
            Vibrate.light();
            Navigator.pop(
              context,
              _SemesterConfigResult(
                startDate: _selectedDate,
                totalWeeks: weeks,
              ),
            );
          },
          child: Text(l10n.confirm),
        ),
      ],
    );
  }
}
