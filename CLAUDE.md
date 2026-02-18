# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Commands

```bash
# Dependencies
flutter pub get

# Localization (must run before build_runner)
flutter gen-l10n

# Code generation (Riverpod, Freezed, JSON serialization)
flutter pub run build_runner build --delete-conflicting-outputs

# Static analysis
flutter analyze

# Tests
flutter test

# Run web with fixed port (required for backend CORS)
flutter run -d chrome --web-hostname 0.0.0.0 --web-port 3000
```

### Verification guards (run before every push)
```bash
dart run tool/verify_riverpod_annotation.dart
dart run tool/verify_state_management_contract.dart
dart run tool/verify_navigation_go_router_contract.dart
dart run tool/verify_common_widget_boundaries.dart
dart run tool/verify_ui_constants_centralization.dart
dart run tool/verify_string_utils_contract.dart
dart run tool/verify_ui_design_guard.dart
STRICT_QUALITY_CONTRACT=1 dart run tool/verify_code_quality_contract.dart
dart run tool/verify_theme_contract.dart
dart run tool/verify_accessibility_contract.dart
dart run custom_lint
```

The CI pipeline (`flutter_ci.yml`) runs all of the above in sequence. All must pass before merge.

## Architecture

**LearnWise** is a Flutter + Spring Boot educational platform. The Flutter frontend (`lib/`) follows a strict tiered architecture:

### Layer Structure

| Layer | Path | Purpose |
|-------|------|---------|
| App | `lib/app/` | Router (GoRouter), theme (Material 3), app config/constants |
| Core | `lib/core/` | Networking (Dio + interceptors), error handling, local storage, utils |
| Common | `lib/common/` | Render-only shared widgets, design tokens (spacing/radius/colors/typography) |
| Features | `lib/features/` | Domain feature modules |
| Localization | `lib/l10n/` | ARB-based i18n (en, vi, ko); generated via `flutter gen-l10n` |

### Feature Module Structure

Each feature under `lib/features/<name>/` follows this internal layout:
- `model/` — DTOs (API) and domain models (Freezed, `@JsonSerializable`)
- `repository/` — API calls via Dio + frontend business logic
- `viewmodel/` — Riverpod `@riverpod` providers for state
- `view/` — Screens and feature-specific widgets

Current features: `auth`, `dashboard`, `decks`, `flashcards`, `folders`, `learning`, `profile`, `progress`, `study`, `tts`.

### State Management

- **Riverpod (annotation-based only):** Always use `@riverpod` / `@Riverpod`. Manual `Provider(...)` declarations are banned.
- **`AsyncValue` pattern:** Use `.when()` or `.map()` in UI. Never access `.value` directly.
- **No `setState`** in feature code. `StatefulWidget` in `lib/common/` is allowed only for pure UI animation state.

### Routing

- GoRouter only. Route names centralized in `app/router/route_names.dart` — no hardcoded strings.
- `Navigator`, `showDialog`, `showModalBottomSheet` are forbidden inside `lib/common/widgets/`.

### Common Widget Contract

`lib/common/widgets/` is strictly render-only:
- No navigation calls, no `throw`, no feature-specific widgets (`audio_waveform`, `quiz_timer`, `swipeable_list_item`).

### UI Design System

Centralized design tokens in `lib/common/styles/`:
- `spacing.dart` — `S.xs / S.sm / S.md / S.lg / S.xl`
- `radius.dart` — `R.sm / R.md / R.lg`
- `colors.dart`, `typography.dart`, `shadows.dart`

No magic number literals for spacing, radius, or colors. Use tokens; the UI design guard enforces this.

### Error Handling

`AppException` hierarchy in `lib/core/error/`. `ApiErrorMapper` converts `DioException` → `AppException`. `GlobalErrorHandler` is mounted in `MaterialApp.builder`.

### Networking

Dio with three interceptors in `lib/core/network/`: `AuthInterceptor` (JWT injection + refresh), `LoggingInterceptor`, `RetryInterceptor`.

### Storage

- `flutter_secure_storage` — JWT/refresh tokens
- `shared_preferences` — theme, language, config

## Coding Contract (enforced by CI)

- **Constant-first:** Define all literals as constants/enums before writing logic.
- **No-else:** Use guard clauses and early returns instead of `else` blocks.
- **Fail-fast:** Validate and throw early, before processing.
- **No hardcoding:** All literals go to constants/enums/config. Enum over string for state/type.
- **File creation order:** constants → enums → interfaces → DTOs/models → mappers → base/abstract → repositories → services → controllers/viewmodels → utils → tests.
- **Code size limits** (`quality_guard.yaml`): max 35 lines per function, max 300 lines per class, max 400 lines per file.
- **String normalization:** Use `StringUtils` (in `lib/core/utils/`) for trim/blank-check operations — not bare `.trim()`.

## Backend

`learn-wire-api-service/` is a Spring Boot application (Maven). Build with `./mvnw` from that directory.
