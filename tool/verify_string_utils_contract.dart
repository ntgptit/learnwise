import 'dart:io';

class StringUtilsContractConst {
  const StringUtilsContractConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';
  static const String allowedTrimFile = 'lib/core/utils/string_utils.dart';
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

final RegExp _trimCallRegExp = RegExp(r'\.\s*trim\s*\(\s*\)');

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
    if (path == StringUtilsContractConst.allowedTrimFile) {
      continue;
    }

    final List<String> lines = await file.readAsLines();
    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String sourceLine = _stripLineComment(rawLine).trim();
      if (sourceLine.isEmpty) {
        continue;
      }
      if (!_trimCallRegExp.hasMatch(sourceLine)) {
        continue;
      }

      violations.add(
        StringUtilsViolation(
          filePath: path,
          lineNumber: index + 1,
          reason:
              'Direct trim() usage is forbidden. Use StringUtils.normalize/normalizeNullable/isBlank/isNotBlank.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('StringUtils contract guard passed.');
    return;
  }

  stderr.writeln('StringUtils contract guard failed.');
  for (final StringUtilsViolation violation in violations) {
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
