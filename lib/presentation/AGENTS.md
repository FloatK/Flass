# PRESENTATION LAYER

## OVERVIEW
UI layer with pages, Riverpod providers, widgets, and utility helpers.

## STRUCTURE
```
presentation/
├── pages/          # Full-screen views (one per route)
├── providers/      # Riverpod @riverpod classes (.g.dart generated)
├── widgets/        # Reusable UI components and dialogs
└── utils/          # UI helpers (import/export dialogs, business logic)
```

## WHERE TO LOOK
| Task | Location | Notes |
|------|----------|-------|
| Add a new page | `pages/` | Register route in `lib/app.dart` GoRouter |
| Modify schedule view | `pages/week_schedule_page.dart` | Main page, 378 lines, uses `_weekOffset` pattern |
| Edit a provider | `providers/` | Run `build_runner` after changes |
| Change theme logic | `providers/theme_provider.dart` | `ThemeSettings` data class lives here too |
| Add a dialog | `widgets/` | Use `ConsumerStatefulWidget` to access Riverpod ref |
| Import/export logic | `utils/import_helper.dart` | Monolith: UI dialogs + parsing mixed together |
| Swap courses | `widgets/swap_course_dialog.dart` | Course swap UI |
| Export schedule | `widgets/export_import_dialogs.dart` | Share/import dialog flow |

## CONVENTIONS
- Pages that need Riverpod extend `ConsumerStatefulWidget`
- Dialogs also use `ConsumerStatefulWidget` (not plain `StatefulWidget`) to avoid ref disposal errors
- Providers use `@riverpod` annotation; generated `.g.dart` files are committed
- `week_schedule_page.dart` navigates weeks via `_weekOffset` integer state

## ANTI-PATTERNS
- **DO NOT** add routes for `schedule_edit_page.dart` in GoRouter. It uses imperative `Navigator.push` by design.
- **DO NOT** put data classes in provider files. `ThemeSettings` in `theme_provider.dart` is a known deviation; prefer `data/models/` for new models.
- **DO NOT** replicate the `import_helper.dart` pattern. It mixes UI dialogs with parsing logic. New helpers should split UI from business logic.
- **NEVER** use plain `StatefulWidget` for dialogs that need `ref`. Always use `ConsumerStatefulWidget`.
