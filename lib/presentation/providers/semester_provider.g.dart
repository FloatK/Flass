// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'semester_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$databaseHash() => r'68b191995ce33a9359eb0605142984ef0ddf91eb';

/// See also [database].
@ProviderFor(database)
final databaseProvider = Provider<AppDatabase>.internal(
  database,
  name: r'databaseProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$databaseHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef DatabaseRef = ProviderRef<AppDatabase>;
String _$currentWeekHash() => r'8cd3d79f1acb35e8b293893127efd32f1221a89e';

/// See also [currentWeek].
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
String _$activeSemesterHash() => r'476a8e323ed5c4571e595941dfe327bcb4533443';

/// See also [ActiveSemester].
@ProviderFor(ActiveSemester)
final activeSemesterProvider =
    AutoDisposeAsyncNotifierProvider<
      ActiveSemester,
      SemesterConfigData?
    >.internal(
      ActiveSemester.new,
      name: r'activeSemesterProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$activeSemesterHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$ActiveSemester = AutoDisposeAsyncNotifier<SemesterConfigData?>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
