import 'dart:io';

class FeatureSurfaceGuardConst {
  const FeatureSurfaceGuardConst._();

  static const String featureRoot = 'lib/presentation/features';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String allowCustomBackgroundMarker =
      'feature-surface-guard: allow-custom-background';
}

class FeatureSurfaceViolation {
  const FeatureSurfaceViolation({
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

class _SurfaceRule {
  const _SurfaceRule({
    required this.widgetName,
    required this.widgetPattern,
    required this.propertyNames,
  });

  final String widgetName;
  final RegExp widgetPattern;
  final List<String> propertyNames;
}

final List<_SurfaceRule> _surfaceRules = <_SurfaceRule>[
  _SurfaceRule(
    widgetName: 'Scaffold',
    widgetPattern: RegExp(r'\bScaffold\s*\('),
    propertyNames: <String>['backgroundColor'],
  ),
];

final List<RegExp> _allowedSurfaceExpressions = <RegExp>[
  RegExp(
    r'\bcolorScheme\.(background|surface|surfaceContainer(?:Lowest|Low|High|Highest)?)\b',
  ),
  RegExp(
    r'\bTheme\.of\(context\)\.colorScheme\.(background|surface|surfaceContainer(?:Lowest|Low|High|Highest)?)\b',
  ),
  RegExp(r'\bColors\.transparent\b'),
  RegExp(r'\bcolorScheme\.scrim\b'),
  RegExp(r'\bTheme\.of\(context\)\.colorScheme\.scrim\b'),
];

Future<void> main() async {
  final Directory root = Directory(FeatureSurfaceGuardConst.featureRoot);
  if (!root.existsSync()) {
    stderr.writeln(
      'Missing `${FeatureSurfaceGuardConst.featureRoot}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<FeatureSurfaceViolation> violations = <FeatureSurfaceViolation>[];
  final List<File> files = _collectFiles(root);
  for (final File file in files) {
    final String path = _normalizePath(file.path);
    final List<String> lines = await file.readAsLines();
    _checkFile(path: path, lines: lines, violations: violations);
  }

  if (violations.isEmpty) {
    stdout.writeln('Feature surface contract passed.');
    return;
  }

  stderr.writeln('Feature surface contract failed.');
  for (final FeatureSurfaceViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

void _checkFile({
  required String path,
  required List<String> lines,
  required List<FeatureSurfaceViolation> violations,
}) {
  for (int index = 0; index < lines.length; index++) {
    final String sourceLine = _stripLineCommentSmart(lines[index]).trim();
    if (sourceLine.isEmpty) {
      continue;
    }

    for (final _SurfaceRule rule in _surfaceRules) {
      if (!rule.widgetPattern.hasMatch(sourceLine)) {
        continue;
      }
      final int blockEnd = _findBlockEnd(lines: lines, startIndex: index);
      for (final String propertyName in rule.propertyNames) {
        final List<_PropertyOccurrence> occurrences =
            _extractPropertyOccurrences(
              lines: lines,
              blockStartIndex: index,
              blockEndIndex: blockEnd,
              propertyName: propertyName,
            );
        for (final _PropertyOccurrence occurrence in occurrences) {
          final bool allowed = _isAllowedSurfaceExpression(
            expression: occurrence.expression,
            rawLine: occurrence.lineContent,
          );
          if (allowed) {
            continue;
          }
          violations.add(
            FeatureSurfaceViolation(
              filePath: path,
              lineNumber: occurrence.lineNumber,
              reason:
                  '${rule.widgetName}.$propertyName must use theme surface/background tokens.',
              lineContent: occurrence.lineContent,
            ),
          );
        }
      }
    }
  }
}

bool _isAllowedSurfaceExpression({
  required String expression,
  required String rawLine,
}) {
  if (rawLine.contains(FeatureSurfaceGuardConst.allowCustomBackgroundMarker)) {
    return true;
  }
  for (final RegExp pattern in _allowedSurfaceExpressions) {
    if (pattern.hasMatch(expression)) {
      return true;
    }
  }
  return false;
}

class _PropertyOccurrence {
  const _PropertyOccurrence({
    required this.expression,
    required this.lineNumber,
    required this.lineContent,
  });

  final String expression;
  final int lineNumber;
  final String lineContent;
}

List<_PropertyOccurrence> _extractPropertyOccurrences({
  required List<String> lines,
  required int blockStartIndex,
  required int blockEndIndex,
  required String propertyName,
}) {
  final List<_PropertyOccurrence> occurrences = <_PropertyOccurrence>[];
  final RegExp propertyPattern = RegExp(
    '\\b${RegExp.escape(propertyName)}\\s*:',
  );
  for (int index = blockStartIndex; index <= blockEndIndex; index++) {
    final String rawLine = lines[index];
    final String line = _stripLineCommentSmart(rawLine);
    final RegExpMatch? match = propertyPattern.firstMatch(line);
    if (match == null) {
      continue;
    }
    final String expression = _collectExpression(
      lines: lines,
      startLineIndex: index,
      startOffset: match.end,
      blockEndIndex: blockEndIndex,
    );
    occurrences.add(
      _PropertyOccurrence(
        expression: expression,
        lineNumber: index + 1,
        lineContent: rawLine.trim(),
      ),
    );
  }
  return occurrences;
}

String _collectExpression({
  required List<String> lines,
  required int startLineIndex,
  required int startOffset,
  required int blockEndIndex,
}) {
  final StringBuffer buffer = StringBuffer();
  int parenthesesDepth = 0;
  int bracketsDepth = 0;
  int bracesDepth = 0;
  bool inSingleQuote = false;
  bool inDoubleQuote = false;
  bool escaped = false;

  for (
    int lineIndex = startLineIndex;
    lineIndex <= blockEndIndex;
    lineIndex++
  ) {
    final String sourceLine = _stripLineCommentSmart(lines[lineIndex]);
    final int from = lineIndex == startLineIndex ? startOffset : 0;

    for (int charIndex = from; charIndex < sourceLine.length; charIndex++) {
      final String ch = sourceLine[charIndex];
      if (escaped) {
        buffer.write(ch);
        escaped = false;
        continue;
      }
      if ((inSingleQuote || inDoubleQuote) && ch == r'\') {
        buffer.write(ch);
        escaped = true;
        continue;
      }
      if (!inDoubleQuote && ch == '\'') {
        inSingleQuote = !inSingleQuote;
        buffer.write(ch);
        continue;
      }
      if (!inSingleQuote && ch == '"') {
        inDoubleQuote = !inDoubleQuote;
        buffer.write(ch);
        continue;
      }
      if (!inSingleQuote && !inDoubleQuote) {
        if (ch == '(') {
          parenthesesDepth++;
        }
        if (ch == ')') {
          parenthesesDepth--;
        }
        if (ch == '[') {
          bracketsDepth++;
        }
        if (ch == ']') {
          bracketsDepth--;
        }
        if (ch == '{') {
          bracesDepth++;
        }
        if (ch == '}') {
          bracesDepth--;
        }
      }
      if (!inSingleQuote &&
          !inDoubleQuote &&
          ch == ',' &&
          parenthesesDepth <= 0 &&
          bracketsDepth <= 0 &&
          bracesDepth <= 0) {
        return buffer.toString().trim();
      }
      buffer.write(ch);
    }
    buffer.write(' ');
  }
  return buffer.toString().trim();
}

int _findBlockEnd({required List<String> lines, required int startIndex}) {
  final String firstLine = _stripLineCommentSmart(lines[startIndex]);
  int parenthesesDepth =
      _countChar(firstLine, '(') - _countChar(firstLine, ')');
  if (parenthesesDepth <= 0) {
    return startIndex;
  }
  for (int lineIndex = startIndex + 1; lineIndex < lines.length; lineIndex++) {
    final String sourceLine = _stripLineCommentSmart(lines[lineIndex]);
    parenthesesDepth += _countChar(sourceLine, '(');
    parenthesesDepth -= _countChar(sourceLine, ')');
    if (parenthesesDepth <= 0) {
      return lineIndex;
    }
  }
  return lines.length - 1;
}

List<File> _collectFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final String path = _normalizePath(entity.path);
    if (!path.endsWith(FeatureSurfaceGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(FeatureSurfaceGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(FeatureSurfaceGuardConst.freezedExtension)) {
      continue;
    }
    files.add(entity);
  }
  return files;
}

int _countChar(String source, String char) => char.allMatches(source).length;

String _normalizePath(String rawPath) => rawPath.replaceAll('\\', '/');

String _stripLineCommentSmart(String sourceLine) {
  bool inSingleQuote = false;
  bool inDoubleQuote = false;
  bool escaped = false;
  for (int index = 0; index < sourceLine.length - 1; index++) {
    final String ch = sourceLine[index];
    if (escaped) {
      escaped = false;
      continue;
    }
    if ((inSingleQuote || inDoubleQuote) && ch == r'\') {
      escaped = true;
      continue;
    }
    if (!inDoubleQuote && ch == '\'') {
      inSingleQuote = !inSingleQuote;
      continue;
    }
    if (!inSingleQuote && ch == '"') {
      inDoubleQuote = !inDoubleQuote;
      continue;
    }
    if (inSingleQuote || inDoubleQuote) {
      continue;
    }
    if (ch != '/') {
      continue;
    }
    if (sourceLine[index + 1] != '/') {
      continue;
    }
    return sourceLine.substring(0, index);
  }
  return sourceLine;
}
