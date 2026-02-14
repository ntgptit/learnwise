# Project Agent Rules

## Common Widgets

`lib/common/widgets` must stay render-only.

- Must not navigate (`Navigator`, `showDialog`, `showModalBottomSheet`).
- Must not throw exceptions.
- Must not host feature widgets:
  - audio waveform
  - quiz timer
  - swipeable list item
- `StatefulWidget` is allowed only for pure UI animation/UI-state widgets.

Feature-bound widgets belong in `lib/features/*/view/widgets`.

## Validation

Run before commit:

```bash
flutter pub get
flutter gen-l10n
flutter pub run build_runner build --delete-conflicting-outputs
dart run tool/verify_riverpod_annotation.dart
dart run tool/verify_state_management_contract.dart
dart run tool/verify_navigation_go_router_contract.dart
dart run tool/verify_common_widget_boundaries.dart
dart run tool/verify_ui_constants_centralization.dart
dart run tool/verify_string_utils_contract.dart
dart run tool/verify_ui_design_guard.dart
dart run tool/verify_code_quality_contract.dart
dart run custom_lint
flutter analyze
flutter test
```

## Automated Guards (tool/)

- `tool/verify_riverpod_annotation.dart`
  - Enforce Riverpod Annotation + DI usage.
  - Block manual provider declarations in non-generated files.
  - Block manual `mounted` checks (`mounted`, `context.mounted`), allow only `ref.mounted`.
- `tool/verify_state_management_contract.dart`
  - Enforce global no-`setState`.
  - Enforce global no-`else`.
  - Enforce state declarations to use Riverpod annotation in state/viewmodel/provider files.
  - Enforce AsyncValue flow to use `.when()`/`.map()` in UI layers.
- `tool/verify_navigation_go_router_contract.dart`
  - Enforce `go_router` dependency/import presence.
  - Block `Navigator.*`, `MaterialPageRoute`, and `onGenerateRoute` outside `lib/common/widgets`.
- `tool/verify_common_widget_boundaries.dart`
  - Keep `lib/common/widgets` render-only.
  - Block navigation/throw/feature-bound widget leakage.
- `tool/verify_ui_constants_centralization.dart`
  - Enforce centralized UI constants usage.
  - Block feature-level style constants and magic UI literals.
- `tool/verify_string_utils_contract.dart`
  - Enforce centralized string normalization through `StringUtils`.
  - Block direct `.trim()` usage in `lib/**` (except `lib/core/utils/string_utils.dart`).
- `tool/verify_ui_design_guard.dart`
  - Enforce mobile-first UI rules (breakpoint, spacing grid, text/icon/button/appbar sizes, touch target, hardcoded colors/sizes, Material 3 usage).
- `tool/verify_code_quality_contract.dart`
  - Enforce `@immutable/@freezed` coverage for model classes.
  - Enforce repository boundary from view/viewmodel.
  - Enforce file/class/function length limits.
  - Enforce Stateful resource disposal heuristics.
  - Enforce UI list scalability heuristics (`children:` vs builder).
  - Enforce basic cache policy heuristics.
  - Detect potentially unused Dart files via import graph reachability.
  - Default non-blocking report; set `STRICT_QUALITY_CONTRACT=1` to make violations fail.

## SonarQube (BE + FE)

Prerequisites:

- SonarQube server is running (example local: `http://localhost:9000`).
- A valid Sonar token is available.

Backend scan (Spring Boot, from `learn-wire-api-service`):

```bash
./mvnw verify sonar:sonar \
  -Dsonar.projectKey=learnwise-be \
  -Dsonar.projectName=learnwise-backend \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=<YOUR_TOKEN>
```

Frontend scan (Flutter, from repo root):

```bash
mkdir -p build/reports
flutter analyze --no-fatal-warnings --no-fatal-infos --machine > build/reports/analysis-results.txt
flutter test --machine > tests.output
sonar-scanner \
  -Dproject.settings=sonar-project.properties \
  -Dsonar.host.url=http://localhost:9000 \
  -Dsonar.token=<YOUR_TOKEN>
```

Note:

- Coverage is optional at this stage. Do not block quality gate setup on coverage generation.
