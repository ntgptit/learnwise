# AGENTS.md — Codex Agent Instructions (ROOT ENTRY)
Version: 1.1
Owner: Codex Governance
Scope: global/agents
Intent: **File entrypoint chạy ĐẦU TIÊN trong mọi phiên Codex.** Điều phối toàn bộ hành vi theo cây `.codex` (MASTER + factory backend/frontend + core checklists) và **buộc tuân thủ Master Coding Contract** (constant-first, no-else, fail-fast, structure-first).

---
## 0) Load Conditions
Load when:
- Bất kỳ phiên Codex nào bắt đầu.

Do NOT load when:
- Không có (luôn áp dụng).

Guarantee:
- **AGENTS.md luôn được load đầu tiên.**
- Sau khi AGENTS.md được load, mới được load các file khác theo Decision Flow.

---
## 1) Priority & Non-Goals
Priority: **P0** — root entrypoint, điều phối checklist, thực thi Coding Contract.

Non-goals:
- Không thay thế nội dung chi tiết trong MASTER/factory/core checklists.
- Không định nghĩa business logic.

---
## 2) Definitions
- **AGENTS:** `./AGENTS.md` (this file, root entrypoint)
- **MASTER:** `./MASTER.md` (điều phối core + factory, quyết định mode/platform)
- **CODING-CONTRACT:** `./coding_contract.md` (Master Coding Contract; constant-first, no-else, fail-fast)
- **Factory:** `backend/_factory.md`, `frontend/_factory.md`
- **Core tree:** `core/**` (architecture, stability, scope-control, constants, error-handling, config, logging, messaging, ...)

---
## 3) Decision Flow (Corrected Precedence & Load Order)
Step 0: **Load AGENTS.md** (this file) — luôn đầu tiên.
Step 1: Load **MASTER.md** để xác định platform/size/task, ưu tiên, quyết định cuối.
Step 2: Load **coding_contract.md** để khóa chuẩn code-gen (constant-first, no-else, fail-fast, structure/order).
Step 3: Load core bắt buộc: architecture, stability, scope-control, config, constants, error-handling, logging, messaging.
Step 4: Theo platform:
- Backend → dùng backend/_factory.md, luôn load backend/common/*, chọn đúng một tech folder (spring-boot/quarkus/nodejs).
- Frontend → dùng frontend/_factory.md, luôn load frontend/common/*, chọn đúng một tech/state folder (react TS/JS, flutter riverpod/bloc, vue khi có).
Step 5: Chỉ load design-patterns khi refactor/extensibility.
Step 6: Chỉ load solid khi review/đề xuất chỉnh code.
Step 7: Chỉ load packaging khi tạo/move class/folder.
Step 8: Áp dụng modes (small/standard/enterprise).
Step 9: Nếu bất kỳ FAIL → dừng, báo theo Output Contract.

---
## 4) Rules
### 4.1 MUST (Fail if violated)
- MUST-01: Luôn tuân theo MASTER + factory để chọn checklist; không tự chọn thủ công.
  - Rationale: tránh thiếu/thừa checklist.
  - Evidence: checklist platform không được load qua factory.
  - Fix: chạy lại theo MASTER + factory.

- MUST-02: Tuân thủ Output Rules: với yêu cầu sửa, chỉ trả diff/patch/snippet; review theo format Critical/Improvements/Optional/Final verdict.
  - Rationale: giảm noise, đúng hợp đồng người dùng.
  - Evidence: trả full file hoặc thiếu verdict.
  - Fix: gửi lại patch/ngắn gọn + verdict.

- MUST-03: Áp dụng Minimal-change & Stability (core/stability, scope-control).
  - Rationale: tránh regressions.
  - Evidence: chỉnh code ổn định không trong scope.
  - Fix: revert/thu hẹp patch.

- MUST-04: **Tuân thủ Master Coding Contract khi sinh/patch code.**
  - Constant-first: define constants trước logic.
  - No-else: guard clause + early return.
  - Fail-fast: validate/throw sớm.
  - No-hardcode: mọi literal đưa vào constants/enums/config.
  - Correct file order: constants → enums → interfaces → DTO/model → config → mapper → base/abstract → repo → service → controller → utils → tests.
  - Enum over string for state/type.
  - No business logic in controller.

- MUST-05: Khi patch code → **chuẩn hóa theo Coding Contract trước khi xuất output** (extract literals, reorder, remove else, flatten nesting).

### 4.2 SHOULD (Warn if violated)
- SHOULD-01: Nhắc user nếu thiếu thông tin để chọn mode (small/standard/enterprise) hoặc tech/platform.

### 4.3 MUST NOT (Fail if violated)
- MUSTNOT-01: Không thêm checklist không thuộc factory hoặc ngoài scope platform hiện tại.
  - Evidence: load nhiều backend tech cùng lúc.
  - Fix: giữ đúng một implementation.

- MUSTNOT-02: Không sinh output code nếu vi phạm Coding Contract (else, hardcode, sai order).

---
## 5) Output Contract
Khi báo lỗi/vi phạm:
- Liệt kê Rule ID.
- Bước sửa tối thiểu.
- Không đề xuất refactor ngoài phạm vi.

Khi fix:
- Trả diff/patch hoặc snippet.
- Không trả full file trừ khi user yêu cầu.

---
## 6) Examples
Good:
"Loaded AGENTS → MASTER → CODING-CONTRACT → core → backend/common → spring-boot via factory; findings: MUST-04 fail … patch: …"

Bad:
- Bỏ qua AGENTS, load MASTER trực tiếp.
- Tự chọn spring-boot + nodejs cùng lúc.
- Trả full file khi chỉ cần patch.

---
## 7) Cross-References
Related files:
- AGENTS.md
- MASTER.md
- coding_contract.md
- backend/_factory.md, frontend/_factory.md
- core/** (architecture, stability, scope-control, design-patterns, solid, packaging, config, messaging, constants, error-handling, logging)

Precedence:
**AGENTS > MASTER > CODING-CONTRACT > factory > core/platform checklists**

---

# Project Agent Rules

## Child Component – Flutter Architecture Checklist

`AGENTS.md` bao gồm checklist con sau và checklist này bắt buộc áp dụng khi sửa code Flutter:

- Source: `C:\Users\ntgpt\.codex\flutter_architecture_checklist.md`
- Role: checklist kiến trúc Flutter/Riverpod theo tier structure
- Scope: toàn bộ thay đổi trong `lib/**` và `test/**` liên quan Flutter

Precedence trong repo này:

1. `AGENTS.md` (parent contract)
2. `C:\Users\ntgpt\.codex\flutter_architecture_checklist.md` (child checklist)

Yêu cầu thực thi:

- Khi task liên quan Flutter UI/state/architecture, phải đối chiếu checklist con trước khi patch.
- Nếu có xung đột, giữ nguyên quy tắc ở `AGENTS.md` và áp dụng checklist con trong phạm vi không mâu thuẫn.

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

## Mandatory Post-Code Gate

Required after any code delivery (not only before commit):

- Must run full local gate equivalent to `.github/workflows/flutter_ci.yml` before returning final code.
- Must run all verification scripts in `D:\workspace\learnwise\tool` (the `dart run tool/*` commands listed above).
- Must run `tool/verify_code_quality_contract.dart` with strict mode enabled to match CI:
  - `STRICT_QUALITY_CONTRACT=1 dart run tool/verify_code_quality_contract.dart` (bash)
  - `$env:STRICT_QUALITY_CONTRACT='1'; dart run tool/verify_code_quality_contract.dart` (PowerShell)
- If any step fails, must fix before delivery; if blocked by environment, must explicitly report which step failed and why.

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
