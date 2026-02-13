import 'dart:io';

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
final RegExp _elseRegExp = RegExp(r'\belse\b');
final RegExp _asyncValueTypeRegExp = RegExp(r'\bAsyncValue\s*<');
final RegExp _whenOrMapRegExp = RegExp(r'\.(?:when|map)\s*\(');
final RegExp _forbiddenAsyncFlowRegExp = RegExp(
  r'\b(?:state|[A-Za-z_][A-Za-z0-9_]*(?:State|AsyncValue|Async))\.(?:hasValue|hasError|requireValue)\b|\bmaybeWhen\s*\(|\bmaybeMap\s*\(',
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

  final List<File> dartFiles = _collectSourceFiles(libDirectory);
  final List<StateContractViolation> violations = <StateContractViolation>[];

  for (final File file in dartFiles) {
    final String normalizedPath = _normalizePath(file.path);
    final List<String> lines = await file.readAsLines();

    final bool isUiFile = _isUiFile(normalizedPath);
    final bool isStateFile = _isStateFile(normalizedPath);
    final bool hasRiverpodAnnotation = _fileHasRiverpodAnnotation(lines);
    if (isStateFile && !hasRiverpodAnnotation) {
      violations.add(
        StateContractViolation(
          filePath: normalizedPath,
          lineNumber: 1,
          reason:
              'State file must contain @riverpod/@Riverpod annotation for state declarations.',
          lineContent: normalizedPath,
        ),
      );
    }

    bool fileHasAsyncValue = false;
    bool fileHasWhenOrMap = false;

    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String sourceLine = _stripLineComment(rawLine).trim();
      if (sourceLine.isEmpty) {
        continue;
      }

      if (_setStateRegExp.hasMatch(sourceLine)) {
        violations.add(
          StateContractViolation(
            filePath: normalizedPath,
            lineNumber: index + 1,
            reason:
                'setState is forbidden. Manage state through Riverpod annotation providers.',
            lineContent: rawLine.trim(),
          ),
        );
      }

      if (_elseRegExp.hasMatch(sourceLine)) {
        violations.add(
          StateContractViolation(
            filePath: normalizedPath,
            lineNumber: index + 1,
            reason:
                'else is forbidden. Use guard clauses and early return/fail-fast flow.',
            lineContent: rawLine.trim(),
          ),
        );
      }

      if (isStateFile && _generatedControllerClassRegExp.hasMatch(sourceLine)) {
        final bool classHasAnnotation = _hasNearbyRiverpodAnnotation(
          lines: lines,
          classLineIndex: index,
        );
        if (!classHasAnnotation) {
          violations.add(
            StateContractViolation(
              filePath: normalizedPath,
              lineNumber: index + 1,
              reason:
                  'Generated Riverpod controller class must be preceded by @riverpod/@Riverpod annotation.',
              lineContent: rawLine.trim(),
            ),
          );
        }
      }

      if (!isUiFile) {
        continue;
      }

      if (_asyncValueTypeRegExp.hasMatch(sourceLine)) {
        fileHasAsyncValue = true;
      }
      if (_whenOrMapRegExp.hasMatch(sourceLine)) {
        fileHasWhenOrMap = true;
      }
      if (_forbiddenAsyncFlowRegExp.hasMatch(sourceLine)) {
        violations.add(
          StateContractViolation(
            filePath: normalizedPath,
            lineNumber: index + 1,
            reason:
                'Async state flow must use .when()/.map() instead of hasValue/hasError/isLoading/requireValue/maybeWhen/maybeMap.',
            lineContent: rawLine.trim(),
          ),
        );
      }
    }

    if (!isUiFile) {
      continue;
    }
    if (!fileHasAsyncValue) {
      continue;
    }
    if (fileHasWhenOrMap) {
      continue;
    }

    violations.add(
      StateContractViolation(
        filePath: normalizedPath,
        lineNumber: 1,
        reason:
            'UI file consumes AsyncValue but does not use .when()/.map() for state flow.',
        lineContent: normalizedPath,
      ),
    );
  }

  if (violations.isEmpty) {
    stdout.writeln('State management contract guard passed.');
    return;
  }

  stderr.writeln('State management contract guard failed.');
  for (final StateContractViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(StateContractConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(StateContractConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(StateContractConst.freezedExtension)) {
      continue;
    }

    files.add(entity);
  }
  return files;
}

bool _isStateFile(String path) {
  if (path.contains('/viewmodel/')) {
    return true;
  }
  if (path.endsWith('/providers.dart')) {
    return true;
  }
  if (path.endsWith('_provider.dart')) {
    return true;
  }
  if (path.endsWith('_providers.dart')) {
    return true;
  }
  return false;
}

bool _isUiFile(String path) {
  if (path.startsWith(StateContractConst.commonWidgetsPrefix)) {
    return true;
  }
  if (!path.contains(StateContractConst.viewFolderMarker)) {
    return false;
  }
  return true;
}

bool _fileHasRiverpodAnnotation(List<String> lines) {
  for (final String line in lines) {
    final String sourceLine = _stripLineComment(line).trim();
    if (sourceLine.isEmpty) {
      continue;
    }
    if (_riverpodAnnotationRegExp.hasMatch(sourceLine)) {
      return true;
    }
  }
  return false;
}

bool _hasNearbyRiverpodAnnotation({
  required List<String> lines,
  required int classLineIndex,
}) {
  int steps = 0;
  for (int index = classLineIndex - 1; index >= 0; index--) {
    final String sourceLine = _stripLineComment(lines[index]).trim();
    if (sourceLine.isEmpty) {
      continue;
    }
    if (_riverpodAnnotationRegExp.hasMatch(sourceLine)) {
      return true;
    }
    if (sourceLine.startsWith('class ')) {
      return false;
    }
    steps++;
    if (steps >= 3) {
      return false;
    }
  }
  return false;
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    StateContractConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
