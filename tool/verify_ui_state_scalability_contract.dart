import 'dart:io';

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
}

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

    final List<String> lines = await file.readAsLines();
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

    final bool hasWhen = _whenRegExp.hasMatch(source);
    final bool hasLoadingArm = _loadingArmRegExp.hasMatch(source);
    final bool hasErrorArm = _errorArmRegExp.hasMatch(source);
    final bool hasList =
        _listViewRegExp.hasMatch(source) || _gridViewRegExp.hasMatch(source);
    final bool hasSpinner = _spinnerRegExp.hasMatch(source);
    final bool hasSkeleton = _skeletonRegExp.hasMatch(source);

    if (hasWhen && !allowMissingWhenState) {
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

    if (hasList && hasSpinner && !hasSkeleton && !allowSpinner) {
      violations.add(
        UiStateViolation(
          filePath: path,
          lineNumber: 1,
          reason:
              'List screens should prefer skeleton loading over only spinner indicators. Add skeleton/shimmer UI or `${UiStateScalabilityConst.allowSpinnerMarker}` with justification.',
          lineContent: path,
        ),
      );
    }

    if (allowListChildren) {
      continue;
    }
    _checkChildrenListUsage(path: path, lines: lines, violations: violations);
  }

  if (violations.isEmpty) {
    stdout.writeln('UI state + scalability contract guard passed.');
    return;
  }

  stderr.writeln('UI state + scalability contract guard failed.');
  for (final UiStateViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

void _checkChildrenListUsage({
  required String path,
  required List<String> lines,
  required List<UiStateViolation> violations,
}) {
  for (int index = 0; index < lines.length; index++) {
    final String rawLine = lines[index];
    final String sourceLine = _stripLineComment(rawLine).trim();
    if (sourceLine.isEmpty) {
      continue;
    }

    final bool hasListMarker =
        _listViewRegExp.hasMatch(sourceLine) ||
        _gridViewRegExp.hasMatch(sourceLine);
    if (!hasListMarker) {
      continue;
    }

    if (!_windowContainsChildren(lines: lines, anchorIndex: index)) {
      continue;
    }

    violations.add(
      UiStateViolation(
        filePath: path,
        lineNumber: index + 1,
        reason:
            'Prefer builder/pagination for ListView/GridView instead of `children:`. Add `${UiStateScalabilityConst.allowListChildrenMarker}` only when list size is guaranteed small.',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

bool _windowContainsChildren({
  required List<String> lines,
  required int anchorIndex,
}) {
  final int windowEnd = anchorIndex + 8;
  for (int index = anchorIndex; index <= windowEnd; index++) {
    if (index >= lines.length) {
      return false;
    }
    final String sourceLine = _stripLineComment(lines[index]).trim();
    if (_childrenPropertyRegExp.hasMatch(sourceLine)) {
      return true;
    }
  }
  return false;
}

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

bool _isFeatureViewFile(String path) {
  if (!path.startsWith(UiStateScalabilityConst.featurePrefix)) {
    return false;
  }
  if (!path.contains(UiStateScalabilityConst.featureViewMarker)) {
    return false;
  }
  return true;
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    UiStateScalabilityConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}
