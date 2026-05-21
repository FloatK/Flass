import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/add_edit_course_page.dart';
import 'presentation/pages/import_schedule_page.dart';
import 'presentation/pages/schedule_list_page.dart';
import 'presentation/pages/week_schedule_page.dart';

final _router = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const WeekSchedulePage(),
    ),
    GoRoute(
      path: '/add',
      builder: (context, state) => const AddEditCoursePage(),
    ),
    GoRoute(
      path: '/edit/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return AddEditCoursePage(courseId: id);
      },
    ),
    GoRoute(
      path: '/import',
      builder: (context, state) => const ImportSchedulePage(),
    ),
    GoRoute(
      path: '/schedules',
      builder: (context, state) => const ScheduleListPage(),
    ),
  ],
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: lightTheme(),
      title: 'WakeUp 课程表',
    );
  }
}
