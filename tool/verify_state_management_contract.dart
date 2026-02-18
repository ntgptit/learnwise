import 'dart:io';

/// ===============================================================
/// State Management Contract Guard v2
/// ===============================================================
///
/// Enforces architectural rules:
///
/// 1. No `setState()` usage (state must be managed via Riverpod).
/// 2. No `else` / `else if` (guard clause + early return philosophy).
/// 3. AsyncValue must use `.when()` / `.map()` (no hasValue/requireValue).
/// 4. Riverpod controllers must have `@riverpod/@Riverpod`.
///
/// Switch-case is allowed.
/// ===============================================================

class StateContractConst {
  const StateContractConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';

  static const String viewFolderMarker = '/view/';
  static const String commonWidgetsPrefix = 'lib/common/widgets/';
}

/// Represents a contract violation.
class StateContractViolation {
  const StateContractViolation({
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

final RegExp _setStateRegExp = RegExp(r'\bsetState\s*\(');
final RegExp _elseRegExp = RegExp(r'^\s*else\b');
final RegExp _asyncValueTypeRegExp = RegExp(r'\bAsyncValue\s*<');
final RegExp _whenOrMapRegExp = RegExp(r'\.(?:when|map)\s*\(');
final RegExp _forbiddenAsyncFlowRegExp = RegExp(
  r'\b(?:hasValue|requireValue|maybeWhen|maybeMap)\b',
);
final RegExp _riverpodAnnotationRegExp = RegExp(r'@\s*(?:riverpod|Riverpod)\b');
final RegExp _generatedControllerClassRegExp = RegExp(
  r'\bclass\s+\w+\s+extends\s+_\$\w+\b',
);

Future<void> main() async {
  final Directory libDirectory = Directory(StateContractConst.libDirectory);

  if (!libDirectory.existsSync()) {
    stderr.writeln('Missing `${StateContractConst.libDirectory}` directory.');
    exitCode = 1;
    return;
  }

  final List<File> files = _collectSourceFiles(libDirectory);
  final List<StateContractViolation> violations = [];

  for (final file in files) {
    final path = _normalizePath(file.path);
    final lines = await file.readAsLines();

    final bool isUiFile = _isUiFile(path);
    final bool isStateFile = _isStateFile(path);

    final bool hasRiverpodAnnotation = _fileHasRiverpodAnnotation(lines);

    if (isStateFile && !hasRiverpodAnnotation) {
      violations.add(
        StateContractViolation(
          filePath: path,
          lineNumber: 1,
          reason: 'State file must contain @riverpod/@Riverpod annotation.',
          lineContent: path,
        ),
      );
    }

    bool fileHasAsyncValue = false;
    bool fileHasWhenOrMap = false;

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i];
      final line = _stripLineComment(rawLine).trim();

      if (line.isEmpty) continue;

      if (_setStateRegExp.hasMatch(line)) {
        violations.add(
          _violation(
            path,
            i,
            rawLine,
            'setState is forbidden. Use Riverpod state management.',
          ),
        );
      }

      if (_elseRegExp.hasMatch(line)) {
        violations.add(
          _violation(
            path,
            i,
            rawLine,
            'else / else if is forbidden. Use guard clauses + early return.',
          ),
        );
      }

      if (_generatedControllerClassRegExp.hasMatch(line)) {
        if (!_hasNearbyRiverpodAnnotation(lines, i)) {
          violations.add(
            _violation(
              path,
              i,
              rawLine,
              'Generated Riverpod controller must be preceded by @riverpod.',
            ),
          );
        }
      }

      if (!isUiFile) continue;

      if (_asyncValueTypeRegExp.hasMatch(line)) {
        fileHasAsyncValue = true;
      }

      if (_whenOrMapRegExp.hasMatch(line)) {
        fileHasWhenOrMap = true;
      }

      if (_forbiddenAsyncFlowRegExp.hasMatch(line)) {
        violations.add(
          _violation(
            path,
            i,
            rawLine,
            'AsyncValue must use .when()/.map() instead of hasValue/requireValue/maybeWhen.',
          ),
        );
      }
    }

    if (isUiFile && fileHasAsyncValue && !fileHasWhenOrMap) {
      violations.add(
        StateContractViolation(
          filePath: path,
          lineNumber: 1,
          reason:
              'UI file consumes AsyncValue but does not use .when()/.map().',
          lineContent: path,
        ),
      );
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('State contract guard v2 passed.');
    return;
  }

  stderr.writeln('State contract guard v2 failed.');
  for (final v in violations) {
    stderr.writeln(
      '${v.filePath}:${v.lineNumber}: ${v.reason} ${v.lineContent}',
    );
  }

  exitCode = 1;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = [];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;

    final path = _normalizePath(entity.path);

    if (!path.endsWith(StateContractConst.dartExtension)) continue;
    if (path.endsWith(StateContractConst.generatedExtension)) continue;
    if (path.endsWith(StateContractConst.freezedExtension)) continue;

    files.add(entity);
  }

  return files;
}

bool _isStateFile(String path) {
  if (path.endsWith('_viewmodel.dart')) return true;
  if (path.endsWith('viewmodel.dart')) return true;
  if (path.endsWith('_provider.dart')) return true;
  if (path.endsWith('_providers.dart')) return true;
  return false;
}

bool _isUiFile(String path) {
  if (path.startsWith(StateContractConst.commonWidgetsPrefix)) return true;
  return path.contains(StateContractConst.viewFolderMarker);
}

bool _fileHasRiverpodAnnotation(List<String> lines) {
  for (final line in lines) {
    if (_riverpodAnnotationRegExp.hasMatch(line)) {
      return true;
    }
  }
  return false;
}

bool _hasNearbyRiverpodAnnotation(List<String> lines, int classIndex) {
  for (int i = classIndex - 1; i >= 0 && i >= classIndex - 3; i--) {
    if (_riverpodAnnotationRegExp.hasMatch(lines[i])) {
      return true;
    }
  }
  return false;
}

StateContractViolation _violation(
  String path,
  int index,
  String rawLine,
  String reason,
) {
  return StateContractViolation(
    filePath: path,
    lineNumber: index + 1,
    reason: reason,
    lineContent: rawLine.trim(),
  );
}

String _stripLineComment(String line) {
  final int index = line.indexOf(StateContractConst.lineCommentPrefix);
  if (index < 0) return line;
  return line.substring(0, index);
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
