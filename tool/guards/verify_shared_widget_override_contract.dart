import 'dart:io';

class SharedWidgetOverrideGuardConst {
  const SharedWidgetOverrideGuardConst._();

  static const String featuresRoot = 'lib/presentation/features';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
}

class SharedWidgetOverrideViolation {
  const SharedWidgetOverrideViolation({
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

class _ForbiddenArgumentRule {
  const _ForbiddenArgumentRule({
    required this.widgetPattern,
    required this.forbiddenArgumentNames,
  });

  final RegExp widgetPattern;
  final List<String> forbiddenArgumentNames;
}

const List<String> _forbiddenColorOverrideArguments = <String>[
  'color',
  'backgroundColor',
  'foregroundColor',
  'iconColor',
  'textColor',
  'hintColor',
  'fillColor',
  'focusColor',
  'hoverColor',
  'splashColor',
  'overlayColor',
  'borderColor',
  'dividerColor',
  'surfaceTintColor',
  'shadowColor',
  'progressColor',
  'customColor',
  'selectedItemColor',
  'unselectedItemColor',
  'selectedColor',
  'unselectedColor',
  'activeColor',
  'inactiveColor',
  'activeTrackColor',
  'inactiveTrackColor',
  'thumbColor',
  'trackColor',
  'checkColor',
];

final List<_ForbiddenArgumentRule> _rules = <_ForbiddenArgumentRule>[
  _ForbiddenArgumentRule(
    widgetPattern: RegExp(r'\bLumos[A-Z]\w*\s*\('),
    forbiddenArgumentNames: _forbiddenColorOverrideArguments,
  ),
];

Future<void> main() async {
  final Directory root = Directory(SharedWidgetOverrideGuardConst.featuresRoot);
  if (!root.existsSync()) {
    stderr.writeln(
      'Missing `${SharedWidgetOverrideGuardConst.featuresRoot}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<SharedWidgetOverrideViolation> violations =
      <SharedWidgetOverrideViolation>[];
  final List<File> files = _collectDartFiles(root);
  for (final File file in files) {
    final String path = _normalizePath(file.path);
    final List<String> lines = await file.readAsLines();
    _checkFile(path: path, lines: lines, violations: violations);
  }

  if (violations.isEmpty) {
    stdout.writeln('Shared widget override contract passed.');
    return;
  }

  stderr.writeln('Shared widget override contract failed.');
  for (final SharedWidgetOverrideViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

void _checkFile({
  required String path,
  required List<String> lines,
  required List<SharedWidgetOverrideViolation> violations,
}) {
  for (int index = 0; index < lines.length; index++) {
    final String sourceLine = _stripLineComment(lines[index]).trim();
    if (sourceLine.isEmpty) {
      continue;
    }

    for (final _ForbiddenArgumentRule rule in _rules) {
      if (!rule.widgetPattern.hasMatch(sourceLine)) {
        continue;
      }
      final String widgetName = _extractWidgetName(sourceLine);
      final int blockEnd = _findBlockEnd(lines: lines, startIndex: index);
      final String callExpression = _collectCallExpression(
        lines: lines,
        startIndex: index,
        endIndex: blockEnd,
      );
      for (final String argumentName in rule.forbiddenArgumentNames) {
        final bool hasForbiddenNamedArgument = _hasTopLevelNamedArgument(
          source: callExpression,
          argumentName: argumentName,
        );
        if (!hasForbiddenNamedArgument) {
          continue;
        }
        violations.add(
          SharedWidgetOverrideViolation(
            filePath: path,
            lineNumber: index + 1,
            reason:
                '$widgetName must not override `$argumentName` from feature layer.',
            lineContent: lines[index].trim(),
          ),
        );
      }
    }
  }
}

String _extractWidgetName(String sourceLine) {
  final RegExpMatch? match = RegExp(r'\b(Lumos[A-Z]\w*)\s*\(').firstMatch(
    sourceLine,
  );
  if (match == null) {
    return 'LumosWidget';
  }
  return match.group(1) ?? 'LumosWidget';
}

String _collectCallExpression({
  required List<String> lines,
  required int startIndex,
  required int endIndex,
}) {
  final StringBuffer buffer = StringBuffer();
  for (int index = startIndex; index <= endIndex; index++) {
    buffer.write(_stripLineComment(lines[index]));
    buffer.write(' ');
  }
  return buffer.toString();
}

bool _hasTopLevelNamedArgument({
  required String source,
  required String argumentName,
}) {
  int depth = 0;
  bool inSingleQuote = false;
  bool inDoubleQuote = false;
  bool escaped = false;
  final StringBuffer tokenBuffer = StringBuffer();

  for (int index = 0; index < source.length; index++) {
    final String ch = source[index];
    if (escaped) {
      tokenBuffer.write(ch);
      escaped = false;
      continue;
    }
    if ((inSingleQuote || inDoubleQuote) && ch == r'\') {
      tokenBuffer.write(ch);
      escaped = true;
      continue;
    }
    if (!inDoubleQuote && ch == '\'') {
      inSingleQuote = !inSingleQuote;
      tokenBuffer.write(ch);
      continue;
    }
    if (!inSingleQuote && ch == '"') {
      inDoubleQuote = !inDoubleQuote;
      tokenBuffer.write(ch);
      continue;
    }
    if (inSingleQuote || inDoubleQuote) {
      tokenBuffer.write(ch);
      continue;
    }
    if (ch == '(' || ch == '[' || ch == '{') {
      depth++;
      tokenBuffer.write(ch);
      continue;
    }
    if (ch == ')' || ch == ']' || ch == '}') {
      depth--;
      tokenBuffer.write(ch);
      continue;
    }
    if (ch == ',' && depth == 1) {
      final String token = tokenBuffer.toString().trim();
      if (_isNamedArgumentToken(token: token, argumentName: argumentName)) {
        return true;
      }
      tokenBuffer.clear();
      continue;
    }
    tokenBuffer.write(ch);
  }

  final String remaining = tokenBuffer.toString().trim();
  return _isNamedArgumentToken(token: remaining, argumentName: argumentName);
}

bool _isNamedArgumentToken({
  required String token,
  required String argumentName,
}) {
  final int colonIndex = token.indexOf(':');
  if (colonIndex <= 0) {
    return false;
  }
  final String left = token.substring(0, colonIndex).trim();
  if (left == argumentName) {
    return true;
  }
  return false;
}

List<File> _collectDartFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final String path = _normalizePath(entity.path);
    if (!path.endsWith(SharedWidgetOverrideGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(SharedWidgetOverrideGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(SharedWidgetOverrideGuardConst.freezedExtension)) {
      continue;
    }
    files.add(entity);
  }
  return files;
}

int _findBlockEnd({required List<String> lines, required int startIndex}) {
  final String firstLine = _stripLineComment(lines[startIndex]);
  int parenthesesDepth =
      _countChar(firstLine, '(') - _countChar(firstLine, ')');
  if (parenthesesDepth <= 0) {
    return startIndex;
  }
  for (int lineIndex = startIndex + 1; lineIndex < lines.length; lineIndex++) {
    final String sourceLine = _stripLineComment(lines[lineIndex]);
    parenthesesDepth += _countChar(sourceLine, '(');
    parenthesesDepth -= _countChar(sourceLine, ')');
    if (parenthesesDepth <= 0) {
      return lineIndex;
    }
  }
  return lines.length - 1;
}

int _countChar(String source, String char) => char.allMatches(source).length;

String _normalizePath(String path) => path.replaceAll('\\', '/');

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf('//');
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}
