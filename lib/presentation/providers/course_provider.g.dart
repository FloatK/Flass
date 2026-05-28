// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'course_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$courseRepositoryHash() => r'ae4a9f44d8e90f4e3eb435c4a05d348c024f6a35';

/// See also [courseRepository].
@ProviderFor(courseRepository)
final courseRepositoryProvider = Provider<CourseRepository>.internal(
  courseRepository,
  name: r'courseRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$courseRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

@Deprecated('Will be removed in 3.0. Use Ref instead')
// ignore: unused_element
typedef CourseRepositoryRef = ProviderRef<CourseRepository>;
String _$courseListHash() => r'c70be3cc509df9e7224f130db6d07b92ae26b00c';

/// See also [CourseList].
@ProviderFor(CourseList)
final courseListProvider =
    AutoDisposeStreamNotifierProvider<CourseList, List<Course>>.internal(
      CourseList.new,
      name: r'courseListProvider',
      debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
          ? null
          : _$courseListHash,
      dependencies: null,
      allTransitiveDependencies: null,
    );

typedef _$CourseList = AutoDisposeStreamNotifier<List<Course>>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
