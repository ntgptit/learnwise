import 'dart:io';

class OpacityContractConst {
  const OpacityContractConst._();

  static const String libRoot = 'lib';
  static const String opacityTokensPath =
      'lib/core/themes/constants/opacities.dart';
  static const String requiredClassName = 'ThemeOpacities';
  static const String dartSuffix = '.dart';
  static const String generatedSuffix = '.g.dart';
  static const String freezedSuffix = '.freezed.dart';
}

class OpacityViolation {
  const OpacityViolation({
    required this.filePath,
    required this.lineNumber,
    required this.message,
    required this.lineContent,
  });

  final String filePath;
  final int lineNumber;
  final String message;
  final String lineContent;
}

final RegExp _opacityConstRegExp = RegExp(
  r'^\s*static\s+const\s+double\s+([A-Za-z0-9_]+)\s*=\s*[^;]+;',
);
final RegExp _themeOpacityUseRegExp = RegExp(
  r'\bThemeOpacities\.([A-Za-z0-9_]+)',
);
final RegExp _withOpacityRegExp = RegExp(r'\.withOpacity\s*\(');

Future<void> main() async {
  final List<OpacityViolation> violations = <OpacityViolation>[];
  final Set<String> declaredOpacityConstants = _loadDeclaredOpacityConstants(
    violations: violations,
  );

  final Directory libRoot = Directory(OpacityContractConst.libRoot);
  if (!libRoot.existsSync()) {
    stderr.writeln('Missing `${OpacityContractConst.libRoot}` directory.');
    exitCode = 1;
    return;
  }

  final List<FileSystemEntity> entities = libRoot.listSync(recursive: true);
  for (final FileSystemEntity entity in entities) {
    if (entity is! File) {
      continue;
    }

    final String normalizedPath = _normalizePath(entity.path);
    if (!normalizedPath.endsWith(OpacityContractConst.dartSuffix)) {
      continue;
    }
    if (normalizedPath.endsWith(OpacityContractConst.generatedSuffix)) {
      continue;
    }
    if (normalizedPath.endsWith(OpacityContractConst.freezedSuffix)) {
      continue;
    }

    final List<String> lines = entity.readAsLinesSync();
    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String sourceLine = _stripLineComment(rawLine).trim();
      if (sourceLine.isEmpty) {
        continue;
      }

      if (_withOpacityRegExp.hasMatch(sourceLine)) {
        violations.add(
          OpacityViolation(
            filePath: normalizedPath,
            lineNumber: index + 1,
            message:
                'Use `.withValues(alpha: ThemeOpacities.*)` instead of `.withOpacity(...)`.',
            lineContent: rawLine.trim(),
          ),
        );
      }

      final Iterable<RegExpMatch> matches = _themeOpacityUseRegExp.allMatches(
        sourceLine,
      );
      for (final RegExpMatch match in matches) {
        final String constantName = match.group(1) ?? '';
        if (constantName == '_') {
          continue;
        }
        if (declaredOpacityConstants.contains(constantName)) {
          continue;
        }
        violations.add(
          OpacityViolation(
            filePath: normalizedPath,
            lineNumber: index + 1,
            message:
                'Undefined opacity token `ThemeOpacities.$constantName`. Declare it in `${OpacityContractConst.opacityTokensPath}`.',
            lineContent: rawLine.trim(),
          ),
        );
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('Opacity constants contract passed.');
    return;
  }

  stderr.writeln('Opacity constants contract failed.');
  for (final OpacityViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '${violation.message} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

Set<String> _loadDeclaredOpacityConstants({
  required List<OpacityViolation> violations,
}) {
  final File tokenFile = File(OpacityContractConst.opacityTokensPath);
  if (!tokenFile.existsSync()) {
    violations.add(
      const OpacityViolation(
        filePath: OpacityContractConst.opacityTokensPath,
        lineNumber: 1,
        message: 'Missing opacity token file.',
        lineContent: OpacityContractConst.opacityTokensPath,
      ),
    );
    return <String>{};
  }

  final List<String> lines = tokenFile.readAsLinesSync();
  bool hasClass = false;
  final Set<String> constants = <String>{};
  for (int index = 0; index < lines.length; index++) {
    final String line = lines[index];
    if (line.contains('class ${OpacityContractConst.requiredClassName}')) {
      hasClass = true;
    }

    final RegExpMatch? match = _opacityConstRegExp.firstMatch(line);
    if (match == null) {
      continue;
    }
    final String constantName = match.group(1) ?? '';
    if (constantName.isEmpty) {
      continue;
    }
    constants.add(constantName);
  }

  if (!hasClass) {
    violations.add(
      const OpacityViolation(
        filePath: OpacityContractConst.opacityTokensPath,
        lineNumber: 1,
        message: 'Missing `ThemeOpacities` class.',
        lineContent: OpacityContractConst.requiredClassName,
      ),
    );
  }
  if (constants.isEmpty) {
    violations.add(
      const OpacityViolation(
        filePath: OpacityContractConst.opacityTokensPath,
        lineNumber: 1,
        message: 'No opacity constants found in token class.',
        lineContent: OpacityContractConst.requiredClassName,
      ),
    );
  }

  return constants;
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

String _stripLineComment(String line) {
  final int commentIndex = line.indexOf('//');
  if (commentIndex < 0) {
    return line;
  }
  return line.substring(0, commentIndex);
}
