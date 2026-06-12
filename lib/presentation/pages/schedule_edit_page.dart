import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/utils/l10n_utils.dart';
import '../../core/utils/ui_utils.dart';
import '../../core/utils/vibrate.dart';
import '../../data/models/schedule.dart';
import '../../l10n/app_localizations.dart';
import '../providers/schedule_provider.dart';

class ScheduleEditPage extends ConsumerStatefulWidget {
  final Schedule schedule;

  const ScheduleEditPage({super.key, required this.schedule});

  @override
  ConsumerState<ScheduleEditPage> createState() => _ScheduleEditPageState();
}

class _ScheduleEditPageState extends ConsumerState<ScheduleEditPage> {
  late TextEditingController _nameController;
  late int _maxCoursesPerDay;
  late Set<int> _selectedWeekdays;
  late TextEditingController _startDateController;
  late TextEditingController _totalWeeksController;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.schedule.name);
    _maxCoursesPerDay = widget.schedule.maxCoursesPerDay;
    _selectedWeekdays = widget.schedule.displayedWeekdays.toSet();
    
    // 从课表自身的字段初始化
    _startDateController = TextEditingController(
      text: widget.schedule.startDate ?? '',
    );
    _totalWeeksController = TextEditingController(
      text: widget.schedule.totalWeeks.toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _startDateController.dispose();
    _totalWeeksController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.editSchedule),
        actions: [
          TextButton(
            onPressed: () { Vibrate.light(); _save(); },
            child: Text(l10n.save),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // -- Schedule section --
          TextField(
            controller: _nameController,
            decoration: InputDecoration(
              labelText: l10n.scheduleName,
              border: const OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.maxCoursesLabel(_maxCoursesPerDay),
            style: Theme.of(context).textTheme.titleSmall,
          ),
          Slider(
            value: _maxCoursesPerDay.toDouble(),
            min: 1,
            max: 20,
            divisions: 19,
            label: '$_maxCoursesPerDay',
            onChanged: (v) => setState(() => _maxCoursesPerDay = v.round()),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.displayedWeekdays,
            style: Theme.of(context).textTheme.titleSmall,
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 4,
            children: List.generate(7, (i) {
              final day = i + 1;
              final selected = _selectedWeekdays.contains(day);
              return FilterChip(
                label: Text(L10nUtils.getDayLabelByIndex(l10n, i)),
                selected: selected,
                onSelected: (v) {
                  setState(() {
                    if (v) {
                      _selectedWeekdays.add(day);
                    } else {
                      _selectedWeekdays.remove(day);
                    }
                    if (_selectedWeekdays.isEmpty) {
                      _selectedWeekdays.add(day);
                    }
                  });
                },
              );
            }),
          ),
          const SizedBox(height: 32),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Text(
            l10n.semesterSettingsLabel,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
          const SizedBox(height: 16),
          // -- Semester section (保存到课表自身) --
          TextField(
            controller: _startDateController,
            decoration: InputDecoration(
              labelText: l10n.startDate,
              hintText: 'YYYY-MM-DD',
              border: const OutlineInputBorder(),
            ),
            readOnly: true,
            onTap: () async {
              final initialDate = _startDateController.text.isNotEmpty
                  ? DateTime.tryParse(_startDateController.text) ?? DateTime.now()
                  : DateTime.now();
              final date = await showDatePicker(
                context: context,
                initialDate: initialDate,
                firstDate: DateTime(2020),
                lastDate: DateTime(2030),
              );
              if (date != null) {
                _startDateController.text =
                    date.toIso8601String().substring(0, 10);
              }
            },
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _totalWeeksController,
            decoration: InputDecoration(
              labelText: l10n.totalWeeks,
              border: const OutlineInputBorder(),
            ),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Future<void> _save() async {
    // Validate schedule fields
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      showAppSnackBar(context, l10n.enterScheduleName, isError: true);
      return;
    }

    final totalWeeksStr = _totalWeeksController.text.trim();
    if (totalWeeksStr.isEmpty) {
      showAppSnackBar(context, l10n.enterTotalWeeks, isError: true);
      return;
    }
    final totalWeeks = int.tryParse(totalWeeksStr);
    if (totalWeeks == null || totalWeeks < 1 || totalWeeks > 30) {
      showAppSnackBar(context, l10n.totalWeeksRange, isError: true);
      return;
    }

    final startDateStr = _startDateController.text.trim();
    if (startDateStr.isEmpty) {
      showAppSnackBar(context, l10n.selectStartDate, isError: true);
      return;
    }

    // Save schedule with startDate and totalWeeks
    final sortedWeekdays = _selectedWeekdays.toList()..sort();
    final updated = widget.schedule.copyWith(
      name: name,
      maxCoursesPerDay: _maxCoursesPerDay,
      displayedWeekdays: sortedWeekdays,
      startDate: startDateStr,
      totalWeeks: totalWeeks,
    );

    try {
      await ref.read(currentScheduleProvider.notifier).updateSchedule(updated);
      ref.invalidate(scheduleListProvider);
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      showAppSnackBar(context, '${l10n.saveFailed}: $e', isError: true);
    }
  }
}
