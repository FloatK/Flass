import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../data/models/schedule.dart';
import '../../domain/repositories/schedule_repository.dart';

part 'schedule_provider.g.dart';

@Riverpod(keepAlive: true)
ScheduleRepository scheduleRepository(ScheduleRepositoryRef ref) {
  throw UnimplementedError('Must be overridden with database instance');
}

@Riverpod(keepAlive: true)
class CurrentSchedule extends _$CurrentSchedule {
  @override
  Future<Schedule> build() async {
    final repo = ref.watch(scheduleRepositoryProvider);
    final defaultSched = await repo.getDefaultSchedule();
    return defaultSched!;
  }

  Future<void> switchSchedule(Schedule schedule) async {
    state = AsyncData(schedule);
  }

  Future<void> refresh() async {
    final repo = ref.read(scheduleRepositoryProvider);
    final sched = await repo.getDefaultSchedule();
    if (sched != null) {
      state = AsyncData(sched);
    }
  }

  Future<void> updateSchedule(Schedule schedule) async {
    final repo = ref.read(scheduleRepositoryProvider);
    await repo.updateSchedule(schedule);
    state = AsyncData(schedule);
  }
}

@Riverpod(keepAlive: true)
Future<List<Schedule>> scheduleList(ScheduleListRef ref) async {
  final repo = ref.watch(scheduleRepositoryProvider);
  return repo.getAllSchedules();
}
