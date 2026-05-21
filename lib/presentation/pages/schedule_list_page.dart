import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:uuid/uuid.dart';

import '../../data/models/schedule.dart';
import '../providers/schedule_provider.dart';
import 'schedule_edit_page.dart';

class ScheduleListPage extends ConsumerWidget {
  const ScheduleListPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final schedulesAsync = ref.watch(scheduleListProvider);
    final currentAsync = ref.watch(currentScheduleProvider);
    final currentId = currentAsync.valueOrNull?.id;

    return Scaffold(
      appBar: AppBar(title: const Text('选择课表')),
      body: schedulesAsync.when(
        data: (schedules) {
          if (schedules.isEmpty) {
            return const Center(child: Text('暂无课表'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(12),
            itemCount: schedules.length + 1, // +1 for create button at bottom
            itemBuilder: (context, index) {
              if (index == schedules.length) {
                return Padding(
                  padding: const EdgeInsets.only(top: 16),
                  child: OutlinedButton.icon(
                    onPressed: () => _createSchedule(context, ref),
                    icon: const Icon(Icons.add),
                    label: const Text('新建课表'),
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
                          onPressed: () => _applySchedule(context, ref, s),
                          child: const Text('应用'),
                        ),
                      if (isActive)
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 8),
                          child: Icon(Icons.check, size: 20, color: Colors.green),
                        ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ScheduleEditPage(schedule: s),
                            ),
                          );
                        },
                        child: const Text('编辑'),
                      ),
                      TextButton(
                        onPressed: () => _confirmDelete(context, ref, s),
                        child: const Text('删除',
                            style: TextStyle(color: Colors.red)),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('加载失败: $e')),
      ),
    );
  }

  void _applySchedule(BuildContext context, WidgetRef ref, Schedule s) {
    ref.read(currentScheduleProvider.notifier).switchSchedule(s);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('已切换到「${s.name}」')),
    );
    context.pop();
  }

  Future<void> _createSchedule(BuildContext context, WidgetRef ref) async {
    final nameCtrl = TextEditingController();
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('新建课表'),
        content: TextField(
          controller: nameCtrl,
          decoration: const InputDecoration(hintText: '课表名称'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, nameCtrl.text.trim()),
            child: const Text('创建'),
          ),
        ],
      ),
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

  void _confirmDelete(BuildContext context, WidgetRef ref, Schedule s) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('确认删除'),
        content: Text('确定要删除「${s.name}」吗？'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('取消'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ref.read(scheduleRepositoryProvider).deleteSchedule(s.id);
                ref.invalidate(scheduleListProvider);
                ref.invalidate(currentScheduleProvider);
                if (ctx.mounted) Navigator.pop(ctx);
              } catch (e) {
                if (ctx.mounted) {
                  Navigator.pop(ctx);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('$e')),
                  );
                }
              }
            },
            child: const Text('删除', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
