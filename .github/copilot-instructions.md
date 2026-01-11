# GitHub Copilot / AI Agent Instructions — Life Tracker

Quick reference for AI coding agents to be productive in this repo.
Keep changes small, test locally, and ask for human review on behavior changes.

---

## Quick start (commands)
- flutter pub get
- Code generators (run after model/type changes):
  - flutter pub run build_runner build --delete-conflicting-outputs
  - VSCode task: **Generate Isar Models** (runs the build_runner command)
- Run app: flutter run
- Build release APK / AAB: flutter build apk --release / flutter build appbundle --release
- Tests:
  - Unit & widget: flutter test (or `flutter test test/unit/` and `flutter test test/widget/`)
  - Integration tests: flutter test integration_test/

---

## Big picture / architecture
- Clean Architecture with separation into: `lib/app`, `lib/core`, `lib/data`, `lib/features/*`.
- State management: Riverpod (providers consistently named `*Provider`, e.g. `notificationServiceProvider`).
- Persistence: Isar NoSQL DB. All collections live under `features/*/data/models` and are registered in `lib/core/database/database_service.dart`.
- Navigation: `go_router` (`lib/app/app_router.dart`).
- Notifications: centralized `NotificationService` in `lib/core/services/notification_service.dart` (initialization includes timezone setup).

---

## Important project-specific patterns
- Isar models:
  - Use @collection, `Id id = Isar.autoIncrement;`, and `.g.dart` parts (example: `lib/features/health/data/models/weight_model.dart`).
  - Regenerate Isar code after changes with `build_runner`.
- Providers & state:
  - Providers follow naming conventions `somethingProvider` and use `Provider`, `FutureProvider`, `StreamProvider`, or `StateNotifier` when needed.
  - StateNotifiers store `AsyncValue<T>` for lists and asynchronous states (see `features/*/presentation/providers/*_provider.dart`).
- DB initialization:
  - `lib/app_startup.dart` waits for `isarProvider` before initializing `NotificationService`.
  - `DatabaseService` opens Isar with `inspector: true` for debugging and will attempt to delete DB files on schema mismatch (see `_openDB()`), so tests or migrations may recreate DB.
- Code generation:
  - Project uses `freezed`, `json_serializable`, `riverpod_generator`, `isar_generator`. Generated files (`*.g.dart`, `*.freezed.dart`) are excluded from linting and should be regenerated rather than manually edited.

---

## Where to look for examples
- Isar model example: `lib/features/health/data/models/weight_model.dart` (pattern for conversion to/from domain entities)
- DB registration: `lib/core/database/database_service.dart` (list of schemas and error handling)
- Provider & DI examples: `lib/app_startup.dart`, `lib/core/providers/*`, and feature providers under `features/*/presentation/providers/`
- Notification & scheduling: `lib/core/services/notification_service.dart`
- Localization setup: `l10n.yaml` and `lib/l10n/` (run `flutter pub get` + `build_runner` / flutter gen-l10n if needed)

---

## Safety checks & common pitfalls
- When changing Isar schemas, expect a schema mismatch; the service may delete DB files to recover — be careful with local data.
- The encryption key generation in `DatabaseService` is a placeholder—replace with a secure key generation strategy if enabling DB encryption.
- Timezone and notification initialization are defensive; test on device/emulator (not only unit tests) for alarm behaviors.
- Avoid editing generated files. If CI shows missing generated files, run `flutter pub run build_runner build --delete-conflicting-outputs`.

---

## Suggested tasks for PRs by LLMs
- Small, well-scoped changes (fix a bug, refactor a provider) with tests and a short summary.
- If modifying models, add a note in the PR that `build_runner` must be run to regenerate code and include the generated changes.
- When changing DB schemas: propose migration strategy and document DB reset risk to reviewers.

---

If anything here is unclear or you want more examples (e.g., a short list of typical provider patterns or a checklist to run before PRs), tell me where to expand.