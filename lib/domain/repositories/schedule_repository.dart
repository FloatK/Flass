import '../../data/models/schedule.dart';

abstract class ScheduleRepository {
  Future<List<Schedule>> getAllSchedules();
  Future<Schedule?> getDefaultSchedule();
  Future<void> createSchedule(Schedule schedule);
  Future<void> renameSchedule(String id, String newName);
  Future<void> updateSchedule(Schedule schedule);
  Future<void> deleteSchedule(String id);
  Future<void> setDefaultSchedule(String id);
}
