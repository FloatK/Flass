# lib/core/ - Utilities, Constants & Theme

## OVERVIEW
Shared utilities, color constants, theme configuration, and app-wide settings used across all layers.

## STRUCTURE
```
core/
├── config/           # App settings (SharedPreferences-based)
├── constants/        # Strings and color definitions
├── theme/            # ThemeData builder
└── utils/            # Shared utility functions
```

## WHERE TO LOOK
| Task | File | Notes |
|------|------|-------|
| Change app colors | `constants/app_colors.dart` | Hex color constants |
| Edit UI strings | `constants/app_strings.dart` | Hardcoded Chinese, no .arb files |
| Modify theme | `theme/app_theme.dart` | `buildTheme(colorIndex, brightness)` |
| Adjust app bar | `config/app_bar_config.dart` | SharedPreferences storage |
| Export/import data | `utils/export_utils.dart`, `utils/import_utils.dart` | Short-key JSON → GZip → base64Url |
| Vibration control | `utils/vibrate.dart` | Static `_enabled` flag |
| Date calculations | `utils/date_utils.dart`, `utils/week_utils.dart` | Week/date helpers |
| WebView integration | `utils/schedule_webview_helper.dart`, `utils/edu_system_webview_controller.dart` | Edu system integration |

## CONVENTIONS
- All utilities are stateless functions or static methods
- Chinese strings live in `AppStrings` class (no localization framework)
- Color palette uses `AppColors` static constants
- Theme builder accepts color index and brightness for dynamic theming

## ANTI-PATTERNS
- **Avoid**: `vibrate.dart` uses a mutable static `_enabled` flag (test-unable, global state)
- **Avoid**: Putting UI logic (dialogs, snackbars) in utils (belongs in `widgets/`)
- **Avoid**: Adding business logic here (belongs in `domain/` or `presentation/`)
