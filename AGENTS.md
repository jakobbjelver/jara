# AGENTS.md — JARA (Just Another Running App)

> **For AI coding agents** (Hermes, OpenCode, Claude Code, Codex, etc.).
> This file tells you how to work with the JARA codebase.
> Read it before touching any code.

---

## 1. What JARA Is

An opinionated, open-source running app for iOS and Android, built with Flutter.
Privacy-first, no accounts, no social features. Read `GOAL.md` for the full philosophy.

---

## 2. Quick Start

### Prerequisites

- Flutter SDK (latest stable) — https://flutter.dev
- Xcode 16+ (macOS only, for iOS builds)
- Android Studio (for Android emulator)
- CocoaPods (`sudo gem install cocoapods`)

### First-Time Setup

```bash
cd /Users/jakob/Repos/jara
flutter pub get
cd ios && pod install && cd ..
```

### Essential Commands

```bash
# Analyze (lint + typecheck) — ALWAYS run before committing
flutter analyze

# Run all tests
flutter test

# Run a specific test file
flutter test test/domain/use_cases/start_run_test.dart

# Run on iOS simulator
flutter run -d ios

# Run on Android emulator
flutter run -d android

# Generate code (after changing drift tables, freezed classes, or Riverpod providers)
dart run build_runner build --delete-conflicting-outputs

# Watch mode for code generation (during active development)
dart run build_runner watch --delete-conflicting-outputs
```

---

## 3. Architecture

JARA follows **Clean Architecture** with four layers:

```
Presentation  →  Widgets, screens, UI state (Riverpod)
    ↓ depends on
Domain        →  Entities, use cases, repository interfaces (pure Dart, NO Flutter)
    ↓ implements
Data          →  Repository implementations, DAOs, DTOs, mappers, data sources
    ↓ uses
Core          →  Theme, router, constants, extensions, utilities
```

### Absolute Rules

1. **Domain layer does NOT import Flutter.** If you write `import 'package:flutter/material.dart'` in `lib/domain/`, you've violated the architecture.
2. **Domain defines interfaces; data implements them.** `RunRepository` is abstract in domain. `RunRepositoryImpl` is in data.
3. **Presentation depends on domain providers, never directly on data.** Widgets read `runRepositoryProvider`. They do not import DAOs or data classes.
4. **SOLID always.** Single responsibility, open/closed, dependency inversion.

---

---

## 4. Verified Package Stack

These packages are chosen because they're well-maintained, widely used, and solve
problems we'd otherwise have to write ourselves. **Never write custom code for
something a package already does.**

| Package | Version | Purpose | Why Not Custom |
|---------|---------|---------|----------------|
| `flutter_riverpod` | ^3.4.0 | State management (Notifier API) | Industry standard for Flutter state |
| `riverpod_annotation` | ^4.0.0 | Code generation for providers | Eliminates boilerplate |
| `go_router` | ^14.0.0 | Navigation & routing | Official Flutter recommendation |
| `drift` | ^2.21.0 | SQLite ORM with type-safe queries | Handles migrations, reactive queries |
| `geolocator` | ^14.0.0 | GPS location (Baseflow) | Battle-tested, cross-platform |
| `flutter_background_service` | ^5.0.0 | Background isolate for GPS | Keeps GPS alive when app is backgrounded |
| `flutter_map` | ^8.3.0 | OpenStreetMap integration | No API key, free, pure Flutter |
| `flutter_map_location_marker` | ^10.3.0 | User location on map | Saves writing a custom map layer |
| `fl_chart` | ^0.69.0 | Charts (pace, elevation, HR) | Lightweight, customizable |
| `activity_files` | ^0.5.0 | GPX/TCX/FIT/CSV/GeoJSON parsing | Auto-detects format, parses everything |
| `freezed` | ^2.5.0 | Immutable data classes + JSON | Eliminates manual `fromJson`/`toJson` |
| `encrypt` | ^5.0.0 | AES-256 encryption for backups | Don't write crypto yourself |
| `mocktail` | ^1.0.0 | Test mocking | Standard for Dart testing |

**Before adding any new dependency:** Check that it doesn't overlap with an existing
one. Check pub.dev for popularity, maintenance status, and license compatibility (GPL-3.0).

## 5. Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # MaterialApp.router
├── core/                        # Theme, router, constants, utilities
│   ├── theme/                   # AppTheme, AppColors, AppTextStyles
│   ├── router/                  # GoRouter config
│   ├── constants/               # Spacing, durations, thresholds
│   ├── extensions/              # Duration, BuildContext extensions
│   └── utils/                   # BackupService, FeatureFlags
├── domain/                      # PURE DART — no Flutter imports
│   ├── entities/                # Run, RoutePoint, Lap, Shoe, PersonalRecord
│   ├── repositories/            # Abstract interfaces
│   └── use_cases/               # Single-purpose action classes
├── data/                        # Implements domain interfaces
│   ├── database/                # Drift: tables, DAOs, database
│   ├── repositories/            # RunRepositoryImpl, SettingsRepositoryImpl
│   ├── mappers/                 # Domain Entity ↔ Drift DataClass
│   └── data_sources/            # GpsDataSource, HealthDataSource
├── features/
│   ├── run_tracking/            # Active run screen + state machine
│   ├── run_history/             # Past runs list
│   ├── run_detail/              # Post-run analysis screen
│   ├── analytics/               # Trends and charts
│   ├── settings/                # Theme, preferences, backup, Change Request
│   └── backup/                  # Backup/restore dialogs
└── shared/
    └── widgets/                 # AppScaffold, GrayscaleIcon, SectionHeader
```

---

## Conventions

### Naming

| Thing | Convention | Example |
|-------|-----------|---------|
| Files | `snake_case.dart` | `run_repository_impl.dart` |
| Classes | `PascalCase` | `RunRepositoryImpl` |
| Functions/Methods | `camelCase` | `getRunHistory()` |
| Constants | `camelCase` (not SCREAMING) | `const defaultPaceWindow = 15;` |
| Variables | `camelCase` | `final runHistory = ...` |
| Providers | `camelCase` + `Provider` suffix | `runHistoryProvider` |
| Test files | `*_test.dart` alongside source | `test/domain/use_cases/start_run_test.dart` |

### Imports

- Always use package imports: `import 'package:jara/domain/entities/run.dart';`
- Never use relative imports: `import '../../domain/entities/run.dart';` ❌
- Group imports: dart → flutter → packages → project (blank line between groups)

### Dart Style

- Use `final` for all variables that are not reassigned. Prefer `const` where possible.
- Always specify types for public APIs. Use type inference for local variables where obvious.
- Use `=>` for single-expression functions. Use `{}` for multi-statement bodies.
- Trailing commas on multi-line parameter lists (forces consistent formatting).

### SOLID in Practice

- A class with >200 lines is suspect. Split it.
- A method with >30 lines is suspect. Extract helpers.
- A use case does ONE thing. `StartRun` starts a run. It does not also check permissions, create notifications, or save to database — those are separate concerns.
- New features extend behavior through composition. Do not modify existing use cases to add new behavior — add a new use case that composes the existing ones.

---

## 6. Database (Drift)

### Code Generation

Drift generates code from table definitions. After changing any table in `lib/data/database/tables/`:

```bash
dart run build_runner build --delete-conflicting-outputs
```

This generates:
- `tables/*.dart` → `tables/*.g.dart` (data classes)
- `database/app_database.dart` → `database/app_database.g.dart` (database class)
- `daos/*.dart` → `daos/*.g.dart` (typed queries)

**Never edit generated `.g.dart` files.**

### Writing Queries

```dart
// In RunsDao:
Future<List<RunData>> getRunsSince(DateTime since) {
  return (select(runs)
    ..where((r) => r.startTime.isBiggerThanValue(since))
    ..orderBy([(r) => OrderingTerm.desc(r.startTime)])
  ).get();
}
```

### JSON Columns

Route points and laps are stored as JSON text columns:

```dart
// Write
final json = jsonEncode(routePoints.map((p) => p.toJson()).toList());
// Read
final list = (jsonDecode(json) as List).map((j) => RoutePoint.fromJson(j)).toList();
```

Use the mapper (`RunMapper`) to convert between domain entities and drift data classes.

---

## 7. State Management (Riverpod)

### Provider Types

| When | Use |
|------|-----|
| Mutable state (theme, settings, active run) | `StateNotifierProvider` |
| Async data (run detail, analytics) | `FutureProvider` or `FutureProvider.family` |
| Reactive streams (run history, GPS positions) | `StreamProvider` |
| Injected dependencies (database, repository) | `Provider` |

### Code Generation

Riverpod supports code generation for providers. If the codebase uses `@riverpod` annotations:

```bash
dart run build_runner build --delete-conflicting-outputs
```

If code generation causes friction, fall back to manual providers — Riverpod supports both.

### Reading Providers in Widgets

```dart
// In a ConsumerWidget:
class RunHistoryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final runsAsync = ref.watch(runHistoryProvider);
    return runsAsync.when(
      data: (runs) => ListView(...),
      loading: () => SkeletonList(),
      error: (e, st) => ErrorBanner(message: e.toString()),
    );
  }
}
```

---

## 8. Testing

### What to Test

| Layer | Test Type | What |
|-------|-----------|------|
| Domain | Unit | Use cases, entities, computed properties |
| Data | Unit | Repository implementations (mock drift), mappers |
| Presentation | Widget | Screens render, state transitions, tap handlers |
| Integration | Integration | Full flows (start → run → stop → view detail) |

### Running Tests

```bash
flutter test                          # All unit + widget tests
flutter test test/domain/             # Domain layer only
flutter test test/features/run_tracking/  # One feature
flutter test --update-goldens         # Update golden files
```

### Writing Tests

```dart
// Use case test
void main() {
  late MockRunRepository repository;
  late MockGpsDataSource gps;
  late StartRun useCase;

  setUp(() {
    repository = MockRunRepository();
    gps = MockGpsDataSource();
    useCase = StartRun(repository, gps);
  });

  test('creates a new run with startTime set to now', () {
    final run = useCase();
    expect(run.startTime, isNotNull);
    expect(run.endTime, isNull);
    expect(run.distanceMeters, isNull);
  });
}
```

### Mocking

Use `mocktail` for mocking:
```dart
class MockRunRepository extends Mock implements RunRepository {}
```

For drift database mocks, use `drift_dev`'s generated mocks or create an in-memory database for tests.

---

## 9. Code Review Checklist

Before pushing, review your own diff against these questions:

1. **SOLID**: Single responsibility? Open/closed? No god classes?
2. **GOAL.md**: Does this change fit JARA's philosophy? Does it violate any "Won't" item?
3. **No workarounds**: Is every API call, every pattern, justified by official documentation?
4. **No reinventing wheels**: Could an existing package do this? Did you check pub.dev and gh_grep first?
5. **Tests**: Are new behaviors tested? Do existing tests still pass?
6. **Forward-looking**: Does this paint us into a corner for V1.5 features? Check `FeatureFlags`.
7. **Grayscale**: Does the UI use green/color where it should be grayscale? Amber for warnings? Red for errors?
8. **Domain purity**: Does `lib/domain/` contain any Flutter imports?
9. **No dead code**: No commented-out blocks, no unused imports, no stale variables.

### Automated Review (Pre-Push)

To run an AI code review on your diff before pushing:

```bash
# For Hermes users:
hermes chat -q "Review the current git diff against GOAL.md and SOLID principles. Check for workarounds, dead code, wrong colors, and domain layer violations."

# For OpenCode users:
opencode run "Review the current git diff against GOAL.md and SOLID principles..."

# For Claude Code users:
claude "Review the git diff. Check GOAL.md alignment, SOLID compliance, no workarounds, grayscale UI rules."
```

Pass the diff + GOAL.md content to the agent. The agent should flag issues before you push.

---

## 10. Before Committing

```bash
# 1. Analyze — catches type errors, unused imports, lint violations
flutter analyze && echo "✓ analyze passed"

# 2. Format — enforces consistent style
dart format lib/ test/ && echo "✓ format passed"

# 3. Test — catches regressions
flutter test && echo "✓ tests passed"

# 4. Generate code (if you changed drift tables, freezed, or providers)
dart run build_runner build --delete-conflicting-outputs

# If any step fails, fix before committing.
```

---

## 11. Common Pitfalls

| Pitfall | How to Avoid |
|---------|-------------|
| **Adding Flutter import to `lib/domain/`** | The analyzer catches this. Check imports after writing domain code. |
| **Forgetting to regenerate drift after schema changes** | If your DAO queries don't compile, run `build_runner`. |
| **Using relative imports** | Always `package:jara/...` imports. Flutter's import linter catches this. |
| **Storing complex objects in SharedPreferences** | SharedPreferences is for simple key-value settings only (theme, unit preference). Run data goes in SQLite. |
| **Blocking the UI with heavy computation** | Expensive operations (export, import, backup, analytics calculation) run in isolates or are `async`. |
| **Hardcoding strings** | All user-facing strings should be in a centralized file (or prepared for i18n — even if not used in V1). |
| **Assuming GPS is always available** | Always check `isLocationServiceEnabled` and handle permission denials gracefully. |
| **Forgetting iOS plist permissions** | GPS requires `Info.plist` entries. Photo picker (for Change Request screenshots) needs `NSPhotoLibraryUsageDescription`. |
| **Drift `.g.dart` merge conflicts** | Regenerate after merge: `build_runner build --delete-conflicting-outputs`. Don't manually edit `.g.dart`. |
| **Riverpod provider naming** | Providers are `camelCase` + `Provider`. Notifiers are `PascalCase` + `Notifier`. State classes are `PascalCase` + `State`. |
| **JSON columns are strings, not structured** | `routePointsJson` and `lapsJson` are JSON strings. Always serialize/deserialize. Never query into them with SQL — if you need to query route data, normalize to a separate table. |

---

## 12. Key Files to Know

| File | Purpose |
|------|---------|
| `GOAL.md` | Project philosophy, feature matrix, what JARA is/isn't |
| `PLAN.md` (in `.hermes/plans/`) | Current implementation plan |
| `lib/core/feature_flags.dart` | V1.5 feature gates |
| `lib/data/database/app_database.dart` | Drift database definition |
| `lib/domain/repositories/run_repository.dart` | Abstract repository interface |
| `lib/core/theme/app_colors.dart` | Fixed semantic color tokens |

---

## 13. Getting Help

- **Architecture questions**: Read `PLAN.md` in `.hermes/plans/`
- **Flutter APIs**: https://api.flutter.dev
- **Drift documentation**: https://drift.simonbinder.eu/docs/
- **Riverpod documentation**: https://riverpod.dev
- **geolocator**: https://pub.dev/packages/geolocator
- **GoRouter**: https://pub.dev/packages/go_router
- **Real-world Flutter examples**: Use `gh_grep` to search GitHub for patterns

---

> **Remember**: JARA is opinionated. When in doubt, GOAL.md is the authority.
> If GOAL.md doesn't answer your question, the answer should be added to GOAL.md.
