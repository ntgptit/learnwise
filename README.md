# learnwise

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

## Architecture Guard

This project enforces Riverpod Annotation DI in `lib/`.

Run locally:

```bash
dart run tool/verify_riverpod_annotation.dart
```

CI also runs this guard and fails when manual `Provider(...)` declarations are found in non-generated files.

## Common Widget Contract

`lib/common/widgets` is strictly render-only.

Rules:

- No navigation (`Navigator`, `showDialog`, `showModalBottomSheet`) inside common widgets.
- No `throw` in common widgets.
- No feature-bound widgets in common:
  - `audio_waveform`
  - `quiz_timer`
  - `swipeable_list_item`
- `StatefulWidget` in common is only allowed for pure UI animation/UI-state widgets.

Run locally:

```bash
dart run tool/verify_common_widget_boundaries.dart
```

CI fails when these rules are violated.

## UI Design Guard

Frontend UI standards are enforced by an automated guard:

```bash
dart run tool/verify_ui_design_guard.dart
```

This guard checks mobile-first breakpoint limits, spacing grid, button/icon/appbar sizes,
touch target minimum size, large hardcoded size usage, hardcoded colors, and Material 3 component usage.

## SonarQube (BE + FE)

SonarQube is configured for both backend and frontend:

- Backend (Spring Boot): `learn-wire-api-service/pom.xml`
- Frontend (Flutter): `sonar-project.properties`
- CI workflow: `.github/workflows/sonarqube.yml`

Setup details and run commands are documented in `docs/sonarqube.md`.
