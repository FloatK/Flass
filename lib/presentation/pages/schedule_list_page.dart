import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../core/utils/ui_utils.dart';
import '../../core/utils/vibrate.dart';
import '../../data/models/schedule.dart';
import '../../l10n/app_localizations.dart';
import '../providers/schedule_provider.dart';
import '../widgets/app_dialogs.dart';
import 'schedule_edit_page.dart';

class ScheduleListPage extends ConsumerWidget {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final schedulesAsync = ref.watch(scheduleListProvider);
    final currentAsync = ref.watch(currentScheduleProvider);
    final currentId = currentAsync.valueOrNull?.id;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.selectSchedule)),
      body: schedulesAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return Center(child: Text(l10n.noSchedule));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: schedules.length + 1, // +1 for create button at bottom
            itemBuilder: (context, index) {
              if (index == schedules.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: OutlinedButton.icon(
                    onPressed: () { Vibrate.light(); _createSchedule(context, ref); },
                    icon: const Icon(Icons.add),
                    label: Text(l10n.createSchedule),
                  ),
                );
              }
              final s = schedules[index];
              final isActive = s.id == currentId;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.name,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                      ),
                      if (!isActive)
                        TextButton(
                          onPressed: () { Vibrate.light(); _applySchedule(context, ref, s); },
                          child: Text(l10n.apply),
                        ),
                      if (isActive)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.check, size: 20, color: Colors.green),
                        ),
                      TextButton(
                        onPressed: () {
                          Vibrate.light();
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScheduleEditPage(schedule: s),
                            ),
                          );
                        },
                        child: Text(l10n.edit),
                      ),
                      TextButton(
                          onPressed: () { Vibrate.light(); _confirmDelete(context, ref, s); },
                        child: Text(l10n.delete,
                            style: const TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('${l10n.loadFailed}: $e')),
      ),
    );
  }

  void _applySchedule(BuildContext context, WidgetRef ref, Schedule s) {
    ref.read(currentScheduleProvider.notifier).switchSchedule(s);
    final l10n = AppLocalizations.of(context)!;
    showAppSnackBar(context, '${l10n.scheduleSwitchedTo}「${s.name}」');
    context.pop();
  }

  Future<void> _createSchedule(BuildContext context, WidgetRef ref) async {
    final l10n = AppLocalizations.of(context)!;
    final result = await AppDialogs.textInput(
      context,
      title: l10n.newSchedule,
      hint: l10n.scheduleName,
    );
    if (result == null || result.isEmpty) return;
    final newSchedule = Schedule(
      id: const Uuid().v4(),
      name: result,
      createdAt: DateTime.now(),
    );
    await ref.read(scheduleRepositoryProvider).createSchedule(newSchedule);
    ref.invalidate(scheduleListProvider);
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, Schedule s) async {
    final confirmed = await AppDialogs.confirmDelete(
      context,
      itemName: s.name,
    );
    if (!confirmed || !context.mounted) return;
    try {
      await ref.read(scheduleRepositoryProvider).deleteSchedule(s.id);
      ref.invalidate(scheduleListProvider);
      ref.invalidate(currentScheduleProvider);
    } catch (e) {
      if (context.mounted) {
        showAppSnackBar(context, '$e', isError: true);
      }
    }
  }
}
