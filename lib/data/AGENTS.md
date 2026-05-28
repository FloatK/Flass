# DATA LAYER

Drift ORM persistence, domain models, and repository implementations.

## STRUCTURE
```
data/
├── datasources/     # Drift database, HTML parsers, sample data
├── models/          # @freezed immutable data classes (Course, Schedule)
└── repositories/    # Repository impls bridging domain interfaces to Drift
```

## WHERE TO LOOK
| Task | File | Notes |
|------|------|-------|
| Add/modify tables | `datasources/database.dart` | Bump `schemaVersion`, add migration in `onUpgrade` |
| Query courses | `datasources/database.dart` | `CourseWithDetails` join class, typed aliases |
| Import from HTML | `datasources/edu_parser_qz.dart` | Implements `EduParser` interface |
| Edit data models | `models/*.dart` | `@freezed` with `fromJson`/`toJson` |
| Add repository method | `repositories/*.dart` | Must implement corresponding domain interface |

## CONVENTIONS
- DateTime stored as TEXT in Drift (configured in `build.yaml`: `store_date_time_values_as_text: true`)
- `data_class_to_companions: false` in build.yaml, companions built manually
- Typedefs: `CourseData`, `TimeDetailData`, `ScheduleData`, `SemesterConfigData` for table row types
- Models use `@freezed`; run `dart run build_runner build` after changes

## ANTI-PATTERNS
- Don't access `database.dart` directly from presentation; go through repositories
- Don't edit `.g.dart` or `.freezed.dart` files (auto-generated)
- Don't add business logic to datasources; keep it in presentation/domain layers
