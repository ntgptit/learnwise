import 'dart:io';

/// Enforces centralized string manipulation policy.
///
/// All string normalization / validation / transformation
/// must go through:
///
///     lib/core/utils/string_utils.dart
///
/// Direct string manipulation is forbidden elsewhere.
class StringUtilsContractConst {
  const StringUtilsContractConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';

  static const String allowedFile = 'lib/core/utils/string_utils.dart';
}

class StringUtilsViolation {
  const StringUtilsViolation({
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

/// Forbidden string operations outside StringUtils.
final List<RegExp> _forbiddenPatterns = <RegExp>[
  RegExp(r'\.\s*trim\s*\(\s*\)'),
  RegExp(r'\.\s*trimLeft\s*\(\s*\)'),
  RegExp(r'\.\s*trimRight\s*\(\s*\)'),
  RegExp(r'\.\s*toLowerCase\s*\(\s*\)'),
  RegExp(r'\.\s*toUpperCase\s*\(\s*\)'),
  RegExp(r'\.\s*isEmpty\b'),
  RegExp(r'\.\s*isNotEmpty\b'),
  RegExp(r'\.\s*replaceAll\s*\('),
  RegExp(r'\.\s*split\s*\('),
  RegExp(r'\.\s*substring\s*\('),
];

/// Detects common null + empty checks.
final RegExp _nullEmptyCheckPattern = RegExp(
  r'!=\s*null\s*&&\s*.*\.(?:isEmpty|isNotEmpty)',
);

Future<void> main() async {
  final Directory root = Directory(StringUtilsContractConst.libDirectory);

  if (!root.existsSync()) {
    stderr.writeln(
      'Missing `${StringUtilsContractConst.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(root);
  final List<StringUtilsViolation> violations = <StringUtilsViolation>[];

  for (final File file in sourceFiles) {
    final String path = _normalizePath(file.path);

    // Allow only in string_utils.dart
    if (path == StringUtilsContractConst.allowedFile) {
      continue;
    }

    final List<String> lines = await file.readAsLines();

    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String sourceLine = _stripLineComment(rawLine).trim();

      if (sourceLine.isEmpty) {
        continue;
      }

      if (_containsForbiddenPattern(sourceLine)) {
        violations.add(
          StringUtilsViolation(
            filePath: path,
            lineNumber: index + 1,
            reason: 'Direct string manipulation is forbidden. Use StringUtils.',
            lineContent: rawLine.trim(),
          ),
        );
        continue;
      }

      if (_nullEmptyCheckPattern.hasMatch(sourceLine)) {
        violations.add(
          StringUtilsViolation(
            filePath: path,
            lineNumber: index + 1,
            reason:
                'Null + empty check is forbidden. Use StringUtils.isBlank/isNotBlank.',
            lineContent: rawLine.trim(),
          ),
        );
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('StringUtils contract guard passed.');
    return;
  }

  stderr.writeln('StringUtils contract guard failed.');
  stderr.writeln(
    'All string normalization and validation must go through StringUtils.',
  );

  for (final StringUtilsViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '${violation.reason} ${violation.lineContent}',
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

    if (!path.endsWith(StringUtilsContractConst.dartExtension)) {
      continue;
    }

    if (path.endsWith(StringUtilsContractConst.generatedExtension)) {
      continue;
    }

    if (path.endsWith(StringUtilsContractConst.freezedExtension)) {
      continue;
    }

    files.add(entity);
  }

  return files;
}

bool _containsForbiddenPattern(String line) {
  for (final RegExp regExp in _forbiddenPatterns) {
    if (regExp.hasMatch(line)) {
      return true;
    }
  }
  return false;
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    StringUtilsContractConst.lineCommentPrefix,
  );

  if (commentIndex < 0) {
    return sourceLine;
  }

  return sourceLine.substring(0, commentIndex);
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
