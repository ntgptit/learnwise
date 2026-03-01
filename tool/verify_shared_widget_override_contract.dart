import 'dart:io';

class SharedWidgetOverrideGuardConst {
  const SharedWidgetOverrideGuardConst._();

  static const String featuresRoot = 'lib/presentation/features';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String baselinePath = 'tool/shared_widget_override_baseline.txt';
}

class SharedWidgetOverrideViolation {
  const SharedWidgetOverrideViolation({
    required this.id,
    required this.filePath,
    required this.lineNumber,
    required this.reason,
    required this.lineContent,
  });

  final String id;
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
    widgetPattern: RegExp(r'\b(?:Lw|App)[A-Z]\w*\s*\('),
    forbiddenArgumentNames: _forbiddenColorOverrideArguments,
  ),
];

Future<void> main([List<String> args = const <String>[]]) async {
  final bool writeBaseline = args.contains('--write-baseline');
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
    _printStaleBaselineHint(
      staleBaselineIds: _collectStaleBaselineIds(
        allViolations: violations,
        baselineIds: _loadBaseline(),
      ),
    );
    stdout.writeln('Shared widget override contract passed.');
    return;
  }

  if (writeBaseline) {
    _writeBaseline(violations: violations);
    stdout.writeln(
      'Wrote baseline with ${violations.length} entries to `${SharedWidgetOverrideGuardConst.baselinePath}`.',
    );
    return;
  }

  final Set<String> baselineIds = _loadBaseline();
  final List<SharedWidgetOverrideViolation> regressions =
      <SharedWidgetOverrideViolation>[];
  for (final SharedWidgetOverrideViolation violation in violations) {
    if (baselineIds.contains(violation.id)) {
      continue;
    }
    regressions.add(violation);
  }
  final Set<String> staleBaselineIds = _collectStaleBaselineIds(
    allViolations: violations,
    baselineIds: baselineIds,
  );
  if (regressions.isEmpty) {
    _printStaleBaselineHint(staleBaselineIds: staleBaselineIds);
    stdout.writeln('Shared widget override contract passed.');
    return;
  }

  stderr.writeln('Shared widget override contract failed.');
  for (final SharedWidgetOverrideViolation violation in regressions) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  _printStaleBaselineHint(staleBaselineIds: staleBaselineIds);
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
            id: '$path:${index + 1}:$widgetName:$argumentName',
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
  final RegExpMatch? match = RegExp(
    r'\b((?:Lw|App)[A-Z]\w*)\s*\(',
  ).firstMatch(sourceLine);
  if (match == null) {
    return 'SharedWidget';
  }
  return match.group(1) ?? 'SharedWidget';
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

Set<String> _loadBaseline() {
  final File baselineFile = File(SharedWidgetOverrideGuardConst.baselinePath);
  if (!baselineFile.existsSync()) {
    return <String>{};
  }
  final Set<String> baselineIds = <String>{};
  final List<String> lines = baselineFile.readAsLinesSync();
  for (final String line in lines) {
    final String normalized = line.trim();
    if (normalized.isEmpty) {
      continue;
    }
    if (normalized.startsWith('#')) {
      continue;
    }
    baselineIds.add(normalized);
  }
  return baselineIds;
}

void _writeBaseline({required List<SharedWidgetOverrideViolation> violations}) {
  final File baselineFile = File(SharedWidgetOverrideGuardConst.baselinePath);
  final List<String> ids =
      violations.map((violation) => violation.id).toSet().toList()..sort();
  baselineFile.writeAsStringSync('${ids.join('\n')}\n');
}

Set<String> _collectStaleBaselineIds({
  required List<SharedWidgetOverrideViolation> allViolations,
  required Set<String> baselineIds,
}) {
  final Set<String> violationIds = allViolations
      .map((violation) => violation.id)
      .toSet();
  final Set<String> staleIds = <String>{};
  for (final String baselineId in baselineIds) {
    if (violationIds.contains(baselineId)) {
      continue;
    }
    staleIds.add(baselineId);
  }
  return staleIds;
}

void _printStaleBaselineHint({required Set<String> staleBaselineIds}) {
  if (staleBaselineIds.isEmpty) {
    return;
  }
  stdout.writeln(
    'Stale baseline entries detected (${staleBaselineIds.length}). '
    'Consider cleaning `${SharedWidgetOverrideGuardConst.baselinePath}`.',
  );
}
