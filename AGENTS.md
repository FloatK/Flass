# PROJECT KNOWLEDGE BASE

**Last updated:** 2026-06-13

## OVERVIEW
Flass is a Flutter/Dart course schedule app using Riverpod for state management, sqflite for SQLite persistence, and GoRouter for navigation. Clean Architecture with code generation (freezed, json_serializable, riverpod_generator).

## STRUCTURE
```
flass/
├── lib/
│   ├── main.dart              # Entry point: DB init, ProviderScope setup
│   ├── app.dart               # MaterialApp.router with GoRouter routes
│   ├── core/                  # Constants, theme, utilities
│   ├── data/                  # sqflite database, models, repository implementations
│   ├── domain/                # Repository interfaces (Clean Arch boundary)
│   ├── presentation/          # Pages, Riverpod providers, widgets
│   └── l10n/                  # Localization (generated)
├── ohos/                      # HarmonyOS build config + dependency overrides
├── pubspec.yaml               # Dependencies & Flutter config
├── build.yaml                 # Code generation settings (freezed)
├── build_regular.ps1          # Build script (Android/iOS/Windows/Linux/macOS)
└── build_ohos.ps1             # Build script (HarmonyOS)
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Add new feature page | `lib/presentation/pages/` | Create page + add GoRoute in `app.dart` |
| Modify database schema | `lib/data/datasources/database.dart` | Bump `_dbVersion`, add migration in `_onUpgrade` |
| Add new model | `lib/data/models/` | Use `@freezed` annotation |
| Change state logic | `lib/presentation/providers/` | Riverpod `@riverpod` classes |
| Update theme/colors | `lib/core/theme/` | `buildTheme()` in `app_theme.dart` |
| Add utility function | `lib/core/utils/` | Shared utilities across layers |
| Modify routes | `lib/app.dart` | GoRouter configuration |
| Database operations | `lib/data/repositories/` | Implements domain interfaces |
| Export/import data | `lib/core/utils/export_utils.dart`, `lib/core/utils/import_utils.dart` | Short-key JSON → GZip → base64Url |
| Vibration control | `lib/core/utils/vibrate.dart` | Static `_enabled` flag |
| Date calculations | `lib/core/utils/date_utils.dart`, `lib/core/utils/week_utils.dart` | Week/date helpers |
| WebView integration | `lib/core/utils/schedule_webview_helper.dart`, `lib/core/utils/edu_system_webview_controller.dart` | Edu system integration |
| Course queries | `lib/data/datasources/course_dao.dart` | DAO pattern, stream-based reads |
| Schedule queries | `lib/data/datasources/schedule_dao.dart` | DAO pattern |
| Import from HTML | `lib/data/datasources/edu_parser_qz.dart` | Implements `EduParser` interface |
| Add course operations | `lib/domain/repositories/course_repository.dart` | Stream-based read, Future writes |
| Add schedule operations | `lib/domain/repositories/schedule_repository.dart` | All Future-based |
| Change app colors | `lib/core/constants/app_colors.dart` | Hex color constants |
| Edit UI strings | `lib/core/constants/app_strings.dart` | Hardcoded Chinese |
| Modify theme | `lib/core/theme/app_theme.dart` | `buildTheme(colorIndex, brightness)` |
| Add a dialog | `lib/presentation/widgets/` | Use `ConsumerStatefulWidget` to access Riverpod ref |
| Swap courses | `lib/presentation/widgets/swap_course_dialog.dart` | Course swap UI |
| Export schedule | `lib/presentation/widgets/export_import_dialogs.dart` | Share/import dialog flow |

## LAYER DETAILS

### Data Layer (`lib/data/`)
```
data/
├── datasources/     # sqflite database, DAOs, HTML parsers, sample data
├── models/          # @freezed immutable data classes (Course, Schedule)
└── repositories/    # Repository impls bridging domain interfaces to sqflite
```
- Database uses sqflite with DAO pattern (`CourseDao`, `ScheduleDao`, `SemesterConfigDao`)
- Data types: `CourseData`, `TimeDetailData`, `ScheduleData`, `SemesterConfigData`
- Companion types for inserts/updates: `CoursesCompanion`, `SchedulesCompanion`, `TimeDetailsCompanion`
- Models use `@freezed`; run `dart run build_runner build` after changes

### Domain Layer (`lib/domain/`)
```
domain/
└── repositories/
    ├── course_repository.dart    # Course CRUD + stream by scheduleId
    └── schedule_repository.dart  # Schedule CRUD + default management
```
- Abstract classes only, no codegen annotations
- Return types: `Stream<List<T>>` for reactive queries, `Future<void>` for writes
- Thin layer — business logic lives in providers and utils

### Presentation Layer (`lib/presentation/`)
```
presentation/
├── pages/          # Full-screen views (one per route)
├── providers/      # Riverpod @riverpod classes (.g.dart generated)
├── widgets/        # Reusable UI components and dialogs
└── utils/          # UI helpers (import/export dialogs, business logic)
```
- Pages that need Riverpod extend `ConsumerStatefulWidget`
- `week_schedule_page.dart` navigates weeks via `_weekOffset` integer state

### Core Layer (`lib/core/`)
```
core/
├── config/           # App settings (SharedPreferences-based)
├── constants/        # Strings and color definitions
├── theme/            # ThemeData builder
└── utils/            # Shared utility functions
```
- All utilities are stateless functions or static methods
- Color palette uses `AppColors` static constants
- Theme builder accepts color index and brightness for dynamic theming

## CONVENTIONS
- **Code generation**: Run `dart run build_runner build --delete-conflicting-outputs` after model/provider changes
- **Models**: Use `@freezed` for immutable data classes with `fromJson`/`toJson`
- **Providers**: Use `@riverpod` annotation with `riverpod_generator`
- **Database**: sqflite with DAO pattern, TEXT storage for DateTime values
- **Naming**: snake_case files, PascalCase classes, camelCase variables
- **Imports**: Relative imports within lib/, package imports for external deps
- **i18n**: Uses `flutter_localizations` + `AppLocalizations` (generated from `lib/l10n/app_zh.arb`)

## ANTI-PATTERNS
- **DO NOT** modify `.g.dart` or `.freezed.dart` files directly (auto-generated)
- **DO NOT** use `export` in PowerShell (use `$env:` for environment variables)
- **DO NOT** commit `dbg.txt` (debug artifact)
- **NEVER** mix UI and business logic in utils (keep dialogs in widgets/)
- **ALWAYS** use `ConsumerStatefulWidget` for dialogs that access Riverpod providers
- **DO NOT** add routes for `schedule_edit_page.dart` in GoRouter — it uses imperative `Navigator.push` by design
- **DO NOT** put data classes in provider files — prefer `data/models/`
- **DO NOT** replicate the `import_helper.dart` pattern — it mixes UI with parsing logic
- **DO NOT** access `database.dart` directly from presentation — go through repositories
- **Avoid** putting UI logic (dialogs, snackbars) in `core/utils/` (belongs in `widgets/`)

## UNIQUE STYLES
- **Compact export format**: Course data → short-key JSON → GZip → base64Url
- **Schedule-scoped courses**: Courses linked to schedules via `scheduleId`
- **Week navigation**: `_weekOffset` pattern for week switching in `WeekSchedulePage`
- **DAO pattern**: Database operations split into `CourseDao`, `ScheduleDao`, `SemesterConfigDao`

## COMMANDS
```bash
# Install dependencies
flutter pub get

# Generate code (freezed, json_serializable, riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run on specific platform
flutter run -d windows
flutter run -d android

# Build for HarmonyOS
cp ohos/pubspec_overrides.yaml pubspec_overrides.yaml
flutter pub get
flutter run -d ohos
```

## NOTES
- **No tests**: Project has zero test files
- **No CI/CD**: No GitHub Actions or Makefile
- **Domain layer**: Thin — only repository interfaces, no use cases
- **retrofit_generator**: Disabled due to SDK compatibility (commented out in pubspec.yaml)
- **AI tool dirs**: `.claude/`, `.omo/`, `.sisyphus/` are gitignored artifacts
- **HarmonyOS**: Uses `ohos/pubspec_overrides.yaml` for OpenHarmony-SIG adapted plugins
