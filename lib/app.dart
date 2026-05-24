import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'presentation/pages/about_page.dart';
import 'presentation/pages/add_edit_course_page.dart';
import 'presentation/pages/import_schedule_page.dart';
import 'presentation/pages/schedule_list_page.dart';
import 'presentation/pages/settings_page.dart';
import 'presentation/pages/week_schedule_page.dart';
import 'presentation/providers/theme_provider.dart';

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
    GoRoute(
      path: '/about',
      builder: (context, state) => const AboutPage(),
    ),
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsPage(),
    ),
  ],
);

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(themeSettingsProvider);

    final colorIndex = settings.colorIndex;
    return MaterialApp.router(
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
      theme: buildTheme(colorIndex, Brightness.light),
      darkTheme: buildTheme(colorIndex, Brightness.dark),
      themeMode: settings.followSystem
          ? ThemeMode.system
          : settings.brightness == Brightness.dark
              ? ThemeMode.dark
              : ThemeMode.light,
      title: 'Flass',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('zh', ''),
        Locale('en', ''),
      ],
    );
  }
}
