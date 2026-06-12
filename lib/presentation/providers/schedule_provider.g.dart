// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'schedule_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$scheduleRepositoryHash() =>
    r'ddfb83a309174388105a5647cc55300b9c00ee09';

/// See also [scheduleRepository].
@ProviderFor(scheduleRepository)
final scheduleRepositoryProvider = Provider<ScheduleRepository>.internal(
  scheduleRepository,
  name: r'scheduleRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleRepositoryRef = ProviderRef<ScheduleRepository>;
String _$scheduleListHash() => r'63a9e159584bfa1f26eac603ee8a785939730781';

/// See also [scheduleList].
@ProviderFor(scheduleList)
final scheduleListProvider = FutureProvider<List<Schedule>>.internal(
  scheduleList,
  name: r'scheduleListProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$scheduleListHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef ScheduleListRef = FutureProviderRef<List<Schedule>>;
String _$currentWeekHash() => r'10997898cd6ec802a71047b23dee52731b2e9bae';

/// 基于当前课表的 startDate 计算当前周次
///
/// Copied from [currentWeek].
@ProviderFor(currentWeek)
final currentWeekProvider = AutoDisposeProvider<int>.internal(
  currentWeek,
  name: r'currentWeekProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$currentWeekHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CurrentWeekRef = AutoDisposeProviderRef<int>;
String _$currentScheduleHash() => r'2b8e488c439fbaa6799cd7aed758d400cb78da9c';

/// See also [CurrentSchedule].
@ProviderFor(CurrentSchedule)
final currentScheduleProvider =
    AsyncNotifierProvider<CurrentSchedule, Schedule>.internal(
      CurrentSchedule.new,
      name: r'currentScheduleProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$currentScheduleHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CurrentSchedule = AsyncNotifier<Schedule>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
