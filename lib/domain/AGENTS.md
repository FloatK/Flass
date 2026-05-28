# DOMAIN LAYER

**Purpose:** Abstract repository interfaces (Clean Architecture boundary)

## STRUCTURE
```
domain/
└── repositories/
    ├── course_repository.dart    # Course CRUD + stream by scheduleId
    └── schedule_repository.dart  # Schedule CRUD + default management
```

## WHERE TO LOOK
| Task | File | Notes |
|------|------|-------|
| Add course operations | `repositories/course_repository.dart` | Stream-based read, Future writes |
| Add schedule operations | `repositories/schedule_repository.dart` | All Future-based |
| Implement new interface | `data/repositories/` | Concrete classes live there |

## CONVENTIONS
- Abstract classes only, no codegen annotations
- Return types: `Stream<List<T>>` for reactive queries, `Future<void>` for writes
- Optional params for scoped queries: `{String? scheduleId}`

## ANTI-PATTERNS
- **Dependency Inversion violation:** Interfaces import from `data/models/` directly. Domain should define its own types or accept generics.
- **No domain entities:** `Course` and `Schedule` are freezed DTOs in `data/models/`, not domain objects.
- **No use cases:** Business logic lives in providers (`presentation/providers/`), import helpers (`presentation/utils/`), and utilities (`core/utils/`).
- **Thin layer:** This layer is purely structural scaffolding. The actual architecture boundary is weak.
