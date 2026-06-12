import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/constants/app_colors.dart';
import '../../core/utils/l10n_utils.dart';
import '../../core/utils/vibrate.dart';
import '../../core/utils/ui_utils.dart';
import '../../data/models/course.dart';
import '../../l10n/app_localizations.dart';
import '../providers/course_provider.dart';
import '../providers/schedule_provider.dart';
import '../widgets/color_picker.dart';

class AddEditCoursePage extends ConsumerStatefulWidget {
  const AddEditCoursePage({super.key, this.courseId});

  final String? courseId;

  @override
  ConsumerState<AddEditCoursePage> createState() => _AddEditCoursePageState();
}

class _TimeEntryData {
  int dayOfWeek;
  int startPeriod;
  int duration;
  Set<int> selectedWeeks;

  _TimeEntryData({
    this.dayOfWeek = 1,
    this.startPeriod = 1,
    this.duration = 1,
    Set<int>? selectedWeeks,
  }) : selectedWeeks = selectedWeeks ?? <int>{};

  _TimeEntryData copy() => _TimeEntryData(
        dayOfWeek: dayOfWeek,
        startPeriod: startPeriod,
        duration: duration,
        selectedWeeks: Set<int>.from(selectedWeeks),
      );
}

class _AddEditCoursePageState extends ConsumerState<AddEditCoursePage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _teacherController = TextEditingController();
  final _locationController = TextEditingController();
  final _scrollController = ScrollController();
  int _selectedColor = AppColors.presetCourseColors.first;
  final List<_TimeEntryData> _timeEntries = [_TimeEntryData()];
  bool _initialized = false;
  bool _saving = false;
  bool _showSaveButton = true;
  double _lastScrollPosition = 0;

  bool get _isEditing => widget.courseId != null;

  AppLocalizations get l10n => AppLocalizations.of(context)!;

  int get _totalWeeks {
    final schedule = ref.read(currentScheduleProvider).valueOrNull;
    return schedule?.totalWeeks ?? 20;
  }

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadExistingCourse();
    });
  }

  void _onScroll() {
    final currentPos = _scrollController.position.pixels;
    if (currentPos > _lastScrollPosition + 10 && _showSaveButton) {
      setState(() => _showSaveButton = false);
    } else if (currentPos < _lastScrollPosition - 10 && !_showSaveButton) {
      setState(() => _showSaveButton = true);
    }
    _lastScrollPosition = currentPos;
  }

  void _loadExistingCourse() {
    if (!_isEditing || _initialized || !mounted) return;
    final courses = ref.read(courseListProvider).valueOrNull;
    if (courses == null) return;
    for (final c in courses) {
      if (c.id == widget.courseId) {
        _nameController.text = c.name;
        _teacherController.text = c.teacher;
        _locationController.text = c.location ?? '';
        _selectedColor = c.color;
        _timeEntries.clear();
        for (final td in c.timeDetails) {
          _timeEntries.add(_TimeEntryData(
            dayOfWeek: td.dayOfWeek,
            startPeriod: td.startPeriod,
            duration: td.duration,
            selectedWeeks: Set<int>.from(td.weeks),
          ));
        }
        if (_timeEntries.isEmpty) _timeEntries.add(_TimeEntryData());
        setState(() => _initialized = true);
        break;
      }
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teacherController.dispose();
    _locationController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  // ---------------------------------------------------------------------------
  // Save
  // ---------------------------------------------------------------------------

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;

    // Each time entry must have at least one week selected
    for (int i = 0; i < _timeEntries.length; i++) {
      if (_timeEntries[i].selectedWeeks.isEmpty) {
        showAppSnackBar(context, l10n.selectWeeksHint(i + 1), isError: true);
        return;
      }
    }

    setState(() => _saving = true);

    try {
      final details = _timeEntries.map((e) {
        final weeks = e.selectedWeeks.toList()..sort();
        return TimeDetail(
          dayOfWeek: e.dayOfWeek,
          startPeriod: e.startPeriod,
          duration: e.duration,
          weeks: weeks,
        );
      }).toList();

      final course = Course(
        id: _isEditing ? widget.courseId! : const Uuid().v4(),
        name: _nameController.text.trim(),
        teacher: _teacherController.text.trim(),
        location: _locationController.text.trim().isEmpty
            ? null
            : _locationController.text.trim(),
        color: _selectedColor,
        timeDetails: details,
      );

      if (_isEditing) {
        await ref.read(courseListProvider.notifier).updateCourse(course);
      } else {
        await ref.read(courseListProvider.notifier).addCourse(course);
      }

      if (mounted) {
        showAppSnackBar(context, _isEditing ? l10n.courseUpdated : l10n.courseAdded);
        context.pop();
      }
    } catch (e) {
      if (mounted) {
        showAppSnackBar(context, '${l10n.saveFailed}: $e', isError: true);
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Widget _buildWeekChip(String label, VoidCallback onTap) {
    final colorScheme = Theme.of(context).colorScheme;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          border: Border.all(color: colorScheme.outline),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text(label, style: const TextStyle(fontSize: 13)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    // Re-attempt load when provider data arrives (e.g. stream emitted after
    // the initial postFrameCallback).
    ref.watch(courseListProvider);
    if (_isEditing && !_initialized) {
      _loadExistingCourse();
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? l10n.editCourse : l10n.addCourse),
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Basic info ──
              _sectionTitle(context, l10n.basicInfo),
              const SizedBox(height: 8),
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: l10n.courseName,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.enterCourseName : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _teacherController,
                decoration: InputDecoration(
                  labelText: l10n.teacher,
                  border: const OutlineInputBorder(),
                ),
                validator: (v) =>
                    (v == null || v.trim().isEmpty) ? l10n.enterTeacher : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(
                  labelText: l10n.locationOptional,
                  border: const OutlineInputBorder(),
                ),
              ),

              const SizedBox(height: 24),

              // ── Color ──
              _sectionTitle(context, l10n.courseColor),
              const SizedBox(height: 8),
              _buildColorPicker(colorScheme),

              const SizedBox(height: 24),

              // ── Time details ──
              _sectionTitle(context, l10n.timeSettings),
              const SizedBox(height: 8),
              for (int i = 0; i < _timeEntries.length; i++)
                _buildTimeEntryCard(i, colorScheme),
              const SizedBox(height: 8),
              _buildAddTimeButton(colorScheme),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
      floatingActionButton: AnimatedSlide(
        offset: _showSaveButton ? Offset.zero : const Offset(0, 2),
        duration: const Duration(milliseconds: 200),
        child: FloatingActionButton.extended(
          onPressed: _saving ? null : () { Vibrate.light(); _save(); },
          icon: _saving
              ? const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.save),
          label: Text(_saving ? '' : l10n.save),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }

  // ---------------------------------------------------------------------------
  // Section helpers
  // ---------------------------------------------------------------------------

  Widget _sectionTitle(BuildContext context, String title) {
    final theme = Theme.of(context);
    return Text(
      title,
      style: theme.textTheme.titleSmall?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Color picker
  // ---------------------------------------------------------------------------

  Widget _buildColorPicker(ColorScheme colorScheme) {
    final colors = AppColors.presetCourseColors.map((c) => Color(c)).toList();
    final selectedIndex = AppColors.presetCourseColors.indexOf(_selectedColor);
    return ColorPicker(
      colors: colors,
      selectedIndex: selectedIndex >= 0 ? selectedIndex : 0,
      onColorSelected: (index) {
        setState(() => _selectedColor = AppColors.presetCourseColors[index]);
      },
    );
  }

  // ---------------------------------------------------------------------------
  // Time entry card
  // ---------------------------------------------------------------------------

  Widget _buildTimeEntryCard(int index, ColorScheme colorScheme) {
    final entry = _timeEntries[index];
    final textTheme = Theme.of(context).textTheme;

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: colorScheme.outlineVariant),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Card header ──
            Row(
              children: [
                Text(
                  l10n.timeSlotLabel(index + 1),
                  style: textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w500),
                ),
                const Spacer(),
                if (_timeEntries.length > 1)
                  IconButton(
                    icon: const Icon(Icons.delete_outline, size: 20),
                    onPressed: () { Vibrate.light(); setState(() => _timeEntries.removeAt(index)); },
                    color: colorScheme.error,
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 12),

            // ── Dropdowns: day / start period / duration ──
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: entry.dayOfWeek,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: l10n.weekday,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: List.generate(
                      7,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(L10nUtils.getDayLabel(l10n, i + 1)),
                      ),
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => entry.dayOfWeek = v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: entry.startPeriod,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: l10n.startPeriod,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: List.generate(
                      12,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(l10n.periodLabel(i + 1)),
                      ),
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => entry.startPeriod = v);
                    },
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: DropdownButtonFormField<int>(
                    initialValue: entry.duration,
                    isDense: true,
                    decoration: InputDecoration(
                      labelText: l10n.duration,
                      border: const OutlineInputBorder(),
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                    ),
                    items: List.generate(
                      3,
                      (i) => DropdownMenuItem(
                        value: i + 1,
                        child: Text(l10n.durationLabel(i + 1)),
                      ),
                    ),
                    onChanged: (v) {
                      if (v != null) setState(() => entry.duration = v);
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // ── Quick week buttons ──
            Wrap(
              spacing: 4,
              runSpacing: 4,
              children: [
                _buildWeekChip(l10n.allWeeks, () {
                  Vibrate.light();
                  setState(() {
                    entry.selectedWeeks =
                        Set<int>.from(List.generate(_totalWeeks, (i) => i + 1));
                  });
                }),
                _buildWeekChip(l10n.singleWeek, () {
                  Vibrate.light();
                  setState(() {
                    entry.selectedWeeks =
                        Set<int>.from(List.generate((_totalWeeks + 1) ~/ 2, (i) => i * 2 + 1));
                  });
                }),
                _buildWeekChip(l10n.doubleWeek, () {
                  Vibrate.light();
                  setState(() {
                    entry.selectedWeeks =
                        Set<int>.from(List.generate(_totalWeeks ~/ 2, (i) => i * 2 + 2));
                  });
                }),
              ],
            ),

            const SizedBox(height: 8),

            // ── Week checkboxes ──
            Wrap(
              spacing: 2,
              runSpacing: 0,
              children: List.generate(_totalWeeks, (i) {
                final week = i + 1;
                final selected = entry.selectedWeeks.contains(week);
                return InkWell(
                  onTap: () {
                    Vibrate.light();
                    setState(() {
                      if (selected) {
                        entry.selectedWeeks.remove(week);
                      } else {
                        entry.selectedWeeks.add(week);
                      }
                    });
                  },
                  child: Container(
                    width: 36,
                    height: 32,
                    alignment: Alignment.center,
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: selected
                          ? colorScheme.primaryContainer
                          : null,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(
                        color: selected
                            ? colorScheme.primary
                            : colorScheme.outlineVariant,
                        width: 1,
                      ),
                    ),
                    child: Text(
                      '$week',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: selected ? FontWeight.w600 : null,
                        color: selected
                            ? colorScheme.onPrimaryContainer
                            : null,
                      ),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Add time button
  // ---------------------------------------------------------------------------

  Widget _buildAddTimeButton(ColorScheme colorScheme) {
    return OutlinedButton.icon(
      onPressed: () { Vibrate.light(); setState(() => _timeEntries.add(_TimeEntryData())); },
      icon: const Icon(Icons.add, size: 18),
      label: Text(l10n.addTimeSlot),
    );
  }
}
