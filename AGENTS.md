# PROJECT KNOWLEDGE BASE

**Generated:** 2026-05-28
**Commit:** 36dd9dc
**Branch:** main

## OVERVIEW
Flass is a Flutter/Dart course schedule app using Riverpod for state management, Drift for SQLite persistence, and GoRouter for navigation. Clean Architecture with code generation (freezed, json_serializable, riverpod_generator).

## STRUCTURE
```
flass/
├── lib/
│   ├── main.dart              # Entry point: DB init, ProviderScope setup
│   ├── app.dart               # MaterialApp.router with GoRouter routes
│   ├── core/                  # Constants, theme, utilities
│   ├── data/                  # Drift database, models, repository implementations
│   ├── domain/                # Repository interfaces (Clean Arch boundary)
│   └── presentation/          # Pages, Riverpod providers, widgets
├── pubspec.yaml               # Dependencies & Flutter config
├── build.yaml                 # Code generation settings (drift, freezed)
└── analysis_options.yaml      # Linting (flutter_lints)
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Add new feature page | `lib/presentation/pages/` | Create page + add GoRoute in `app.dart` |
| Modify database schema | `lib/data/datasources/database.dart` | Bump `schemaVersion`, add migration |
| Add new model | `lib/data/models/` | Use `@freezed` annotation |
| Change state logic | `lib/presentation/providers/` | Riverpod `@riverpod` classes |
| Update theme/colors | `lib/core/theme/` | `buildTheme()` in `app_theme.dart` |
| Add utility function | `lib/core/utils/` | Shared utilities across layers |
| Modify routes | `lib/app.dart` | GoRouter configuration |
| Database operations | `lib/data/repositories/` | Implements domain interfaces |

## CONVENTIONS
- **Code generation**: Run `dart run build_runner build --delete-conflicting-outputs` after model/provider changes
- **Models**: Use `@freezed` for immutable data classes with `fromJson`/`toJson`
- **Providers**: Use `@riverpod` annotation with `riverpod_generator`
- **Database**: Drift ORM with TEXT storage for DateTime values
- **Naming**: snake_case files, PascalCase classes, camelCase variables
- **Imports**: Relative imports within lib/, package imports for external deps

## ANTI-PATTERNS (THIS PROJECT)
- **DO NOT** modify `.g.dart` or `.freezed.dart` files directly (auto-generated)
- **DO NOT** use `export` in PowerShell (use `$env:` for environment variables)
- **DO NOT** commit `dbg.txt` (debug artifact)
- **NEVER** mix UI and business logic in utils (keep dialogs in widgets/)
- **ALWAYS** use `ConsumerStatefulWidget` for dialogs that access Riverpod providers

## UNIQUE STYLES
- **Compact export format**: Course data → short-key JSON → GZip → base64Url
- **Dual localization**: Hardcoded Chinese strings in `AppStrings` (no .arb files)
- **Schedule-scoped courses**: Courses linked to schedules via `scheduleId`
- **Week navigation**: `_weekOffset` pattern for week switching in `WeekSchedulePage`

## COMMANDS
```bash
# Install dependencies
flutter pub get

# Generate code (freezed, drift, json_serializable, riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run app
flutter run

# Run on specific platform
flutter run -d windows
flutter run -d chrome
flutter run -d android
```

## NOTES
- **No tests**: Project has zero test files
- **No CI/CD**: No GitHub Actions or Makefile
- **Localization**: Declared but uses hardcoded Chinese strings (English locale unsupported)
- **Domain layer**: Thin - only repository interfaces, no use cases
- **retrofit_generator**: Disabled due to SDK compatibility (commented out in pubspec.yaml)
- **AI tool dirs**: `.claude/`, `.omo/`, `.sisyphus/` are gitignored artifacts
