import 'dart:io';

/// UI State + Scalability Guard (v2)
///
/// Mục tiêu:
/// - Ép màn hình list/grid ưu tiên builder/pagination thay vì `children:` để tránh UI lag khi data lớn.
/// - Ép dùng `.when(...)` trên AsyncValue có đủ nhánh `loading:` và `error:`
/// - Với màn hình list/grid: ưu tiên skeleton/shimmer thay vì chỉ dùng spinner.
///
/// Phạm vi quét:
/// - Chỉ quét các file trong: `lib/features/**/view/**.dart`
/// - Bỏ qua file generated/freezed: `*.g.dart`, `*.freezed.dart`
///
/// Markers (opt-out có giải trình):
/// - `ui-state-guard: allow-list-children`
///   Cho phép dùng `children:` khi list chắc chắn nhỏ.
/// - `ui-state-guard: allow-spinner-list`
///   Cho phép list chỉ dùng spinner (không có skeleton).
/// - `ui-state-guard: allow-missing-when-state`
///   Cho phép `.when(...)` thiếu `loading:`/`error:` (ví dụ: wrapper đã handle ở tầng ngoài).
///
/// Ghi chú kỹ thuật:
/// - Regex-based guard: nhanh, dễ maintain, nhưng không mạnh bằng AST.
/// - Tránh false-positive bằng cách:
///   + strip comment trước khi match
///   + chỉ áp rule trong folder view của feature
///   + window-scan cho `children:` gần ListView/GridView
class UiStateScalabilityConst {
  const UiStateScalabilityConst._();

  static const String libDirectory = 'lib';
  static const String featurePrefix = 'lib/features/';
  static const String featureViewMarker = '/view/';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';

  static const String allowListChildrenMarker =
      'ui-state-guard: allow-list-children';
  static const String allowSpinnerMarker = 'ui-state-guard: allow-spinner-list';
  static const String allowMissingWhenStateMarker =
      'ui-state-guard: allow-missing-when-state';

  /// Max number of lines to scan forward from a ListView/GridView anchor line
  /// to detect `children:` usage.
  static const int childrenWindowLookahead = 8;
}

/// A single guard violation.
class UiStateViolation {
  const UiStateViolation({
    required this.filePath,
    required this.lineNumber,
    required this.reason,
    required this.lineContent,
  });

  final String filePath;
  final int lineNumber;
  final String reason;
  final String lineContent;
}

final RegExp _whenRegExp = RegExp(r'\.when\s*\(');
final RegExp _loadingArmRegExp = RegExp(r'\bloading\s*:');
final RegExp _errorArmRegExp = RegExp(r'\berror\s*:');

final RegExp _listViewRegExp = RegExp(r'\bListView\s*\(');
final RegExp _gridViewRegExp = RegExp(r'\bGridView\s*\(');
final RegExp _childrenPropertyRegExp = RegExp(r'\bchildren\s*:');

final RegExp _spinnerRegExp = RegExp(r'\bCircularProgressIndicator\s*\(');
final RegExp _skeletonRegExp = RegExp(
  r'\b(?:Skeleton|Shimmer)\w*\b|\bShimmerBox\b',
);

Future<void> main() async {
  final Directory libDirectory = Directory(
    UiStateScalabilityConst.libDirectory,
  );
  if (!libDirectory.existsSync()) {
    stderr.writeln(
      'Missing `${UiStateScalabilityConst.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(libDirectory);
  final List<UiStateViolation> violations = <UiStateViolation>[];

  for (final File file in sourceFiles) {
    final String path = _normalizePath(file.path);
    if (!_isFeatureViewFile(path)) {
      continue;
    }

    final List<String> rawLines = await file.readAsLines();
    final List<String> lines = rawLines.map(_stripLineComment).toList();
    final String source = lines.join('\n');

    final bool allowListChildren = source.contains(
      UiStateScalabilityConst.allowListChildrenMarker,
    );
    final bool allowSpinner = source.contains(
      UiStateScalabilityConst.allowSpinnerMarker,
    );
    final bool allowMissingWhenState = source.contains(
      UiStateScalabilityConst.allowMissingWhenStateMarker,
    );

    _checkWhenArms(
      violations: violations,
      path: path,
      source: source,
      allowMissingWhenState: allowMissingWhenState,
    );

    _checkSpinnerForListScreens(
      violations: violations,
      path: path,
      source: source,
      allowSpinner: allowSpinner,
    );

    if (allowListChildren) {
      continue;
    }

    _checkChildrenListUsage(
      path: path,
      rawLines: rawLines,
      strippedLines: lines,
      violations: violations,
    );
  }

  if (violations.isEmpty) {
    stdout.writeln('UI state + scalability guard v2 passed.');
    return;
  }

  stderr.writeln('UI state + scalability guard v2 failed.');
  for (final UiStateViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

/// Validate AsyncValue `.when(...)` branches.
///
/// Rule:
/// - Nếu có `.when(` thì phải có `loading:` và `error:`
/// - Trừ khi có marker allow: `allow-missing-when-state`
void _checkWhenArms({
  required List<UiStateViolation> violations,
  required String path,
  required String source,
  required bool allowMissingWhenState,
}) {
  final bool hasWhen = _whenRegExp.hasMatch(source);
  if (!hasWhen) {
    return;
  }
  if (allowMissingWhenState) {
    return;
  }

  final bool hasLoadingArm = _loadingArmRegExp.hasMatch(source);
  if (!hasLoadingArm) {
    violations.add(
      UiStateViolation(
        filePath: path,
        lineNumber: 1,
        reason:
            'AsyncValue `.when()` must include `loading:` branch or add `${UiStateScalabilityConst.allowMissingWhenStateMarker}` with justification.',
        lineContent: path,
      ),
    );
  }

  final bool hasErrorArm = _errorArmRegExp.hasMatch(source);
  if (!hasErrorArm) {
    violations.add(
      UiStateViolation(
        filePath: path,
        lineNumber: 1,
        reason:
            'AsyncValue `.when()` must include `error:` branch or add `${UiStateScalabilityConst.allowMissingWhenStateMarker}` with justification.',
        lineContent: path,
      ),
    );
  }
}

/// For list/grid screens, prefer skeleton over spinner-only.
///
/// Rule:
/// - Nếu file có ListView/GridView
/// - và có CircularProgressIndicator
/// - nhưng không có Skeleton/Shimmer
/// - và không có marker allow spinner
/// => flag.
void _checkSpinnerForListScreens({
  required List<UiStateViolation> violations,
  required String path,
  required String source,
  required bool allowSpinner,
}) {
  if (allowSpinner) {
    return;
  }

  final bool hasList =
      _listViewRegExp.hasMatch(source) || _gridViewRegExp.hasMatch(source);
  if (!hasList) {
    return;
  }

  final bool hasSpinner = _spinnerRegExp.hasMatch(source);
  if (!hasSpinner) {
    return;
  }

  final bool hasSkeleton = _skeletonRegExp.hasMatch(source);
  if (hasSkeleton) {
    return;
  }

  violations.add(
    UiStateViolation(
      filePath: path,
      lineNumber: 1,
      reason:
          'List screens should prefer skeleton/shimmer loading over spinner-only. Add skeleton UI or `${UiStateScalabilityConst.allowSpinnerMarker}` with justification.',
      lineContent: path,
    ),
  );
}

/// Detect `children:` usage for ListView/GridView near an anchor line.
///
/// Rule:
/// - Khi thấy ListView( / GridView(
/// - scan forward N lines (default 8)
/// - nếu thấy `children:` => flag.
/// - Khuyến nghị: dùng builder/pagination (ListView.builder/GridView.builder/SliverList, etc.)
void _checkChildrenListUsage({
  required String path,
  required List<String> rawLines,
  required List<String> strippedLines,
  required List<UiStateViolation> violations,
}) {
  for (int i = 0; i < strippedLines.length; i++) {
    final String line = strippedLines[i].trim();
    if (line.isEmpty) {
      continue;
    }

    final bool hasListMarker =
        _listViewRegExp.hasMatch(line) || _gridViewRegExp.hasMatch(line);
    if (!hasListMarker) {
      continue;
    }

    final bool hasChildren = _windowContainsChildren(
      strippedLines: strippedLines,
      anchorIndex: i,
    );
    if (!hasChildren) {
      continue;
    }

    violations.add(
      UiStateViolation(
        filePath: path,
        lineNumber: i + 1,
        reason:
            'Prefer builder/pagination for ListView/GridView instead of `children:`. Add `${UiStateScalabilityConst.allowListChildrenMarker}` only when list size is guaranteed small.',
        lineContent: rawLines[i].trim(),
      ),
    );
  }
}

/// Scan forward from [anchorIndex] for `children:` within a bounded window.
bool _windowContainsChildren({
  required List<String> strippedLines,
  required int anchorIndex,
}) {
  final int end = anchorIndex + UiStateScalabilityConst.childrenWindowLookahead;
  for (int i = anchorIndex; i <= end; i++) {
    if (i >= strippedLines.length) {
      return false;
    }
    final String line = strippedLines[i].trim();
    if (line.isEmpty) {
      continue;
    }
    if (_childrenPropertyRegExp.hasMatch(line)) {
      return true;
    }
  }
  return false;
}

/// Collect Dart files excluding generated/freezed output.
List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(UiStateScalabilityConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(UiStateScalabilityConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(UiStateScalabilityConst.freezedExtension)) {
      continue;
    }
    files.add(entity);
  }
  return files;
}

/// Only enforce rules in feature view layer files.
bool _isFeatureViewFile(String path) {
  if (!path.startsWith(UiStateScalabilityConst.featurePrefix)) {
    return false;
  }
  if (!path.contains(UiStateScalabilityConst.featureViewMarker)) {
    return false;
  }
  return true;
}

/// Normalize path separators to `/`.
String _normalizePath(String path) => path.replaceAll('\\', '/');

/// Strip `//` comment from a line.
///
/// Note:
/// - Simpler than smart stripper; acceptable here because guard rules
///   match UI patterns (ListView/GridView/when/loading/error/children) which
///   rarely appear inside URLs.
String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    UiStateScalabilityConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}
