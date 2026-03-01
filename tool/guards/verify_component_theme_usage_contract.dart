import 'dart:io';

class ComponentThemeGuardConst {
  const ComponentThemeGuardConst._();

  static const String presentationRoot = 'lib/presentation';
  static const String sharedWidgetsRoot = 'lib/presentation/shared/widgets/';
  static const String featurePrefix = 'lib/presentation/features/';
  static const String featureScreensMarker = '/screens/';
  static const String featureWidgetsMarker = '/widgets/';
  static const String providersMarker = '/providers/';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String modelSuffix = '_model.dart';
  static const String modelsSuffix = '_models.dart';
  static const String importPrefix = 'import ';
  static const String exportPrefix = 'export ';
  static const String libraryPrefix = 'library ';
  static const String partPrefix = 'part ';
  static const String coreThemeImportMarker = 'core/themes/';
  static const String widgetBuildMarker = 'Widget build(';
  static const String showDialogMarker = 'showDialog';
  static const String showModalBottomSheetMarker = 'showModalBottomSheet';
  static const String allowInlineOverrideMarker =
      'component-theme-guard: allow-inline-override';
}

class ComponentThemeViolation {
  const ComponentThemeViolation({
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

class _ForbiddenPropertyRule {
  const _ForbiddenPropertyRule({
    required this.widgetName,
    required this.widgetStartPattern,
    required this.propertyNames,
    required this.reason,
  });

  final String widgetName;
  final RegExp widgetStartPattern;
  final List<String> propertyNames;
  final String reason;
}

final List<_ForbiddenPropertyRule>
_forbiddenPropertyRules = <_ForbiddenPropertyRule>[
  _ForbiddenPropertyRule(
    widgetName: 'Scaffold',
    widgetStartPattern: RegExp(r'\bScaffold\s*\('),
    propertyNames: <String>['backgroundColor'],
    reason: 'Scaffold colors in UI must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'AppBar',
    widgetStartPattern: RegExp(r'\bAppBar\s*\('),
    propertyNames: <String>['backgroundColor', 'foregroundColor'],
    reason: 'AppBar colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'BottomNavigationBar',
    widgetStartPattern: RegExp(r'\bBottomNavigationBar\s*\('),
    propertyNames: <String>[
      'backgroundColor',
      'selectedItemColor',
      'unselectedItemColor',
    ],
    reason:
        'BottomNavigationBar colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'Card',
    widgetStartPattern: RegExp(r'\bCard\s*\('),
    propertyNames: <String>['color', 'surfaceTintColor'],
    reason: 'Card colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'ElevatedButton',
    widgetStartPattern: RegExp(r'\bElevatedButton\s*\('),
    propertyNames: <String>['style'],
    reason:
        'ElevatedButton in UI files should rely on theme style from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'OutlinedButton',
    widgetStartPattern: RegExp(r'\bOutlinedButton\s*\('),
    propertyNames: <String>['style'],
    reason:
        'OutlinedButton in UI files should rely on theme style from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'TextButton',
    widgetStartPattern: RegExp(r'\bTextButton\s*\('),
    propertyNames: <String>['style'],
    reason:
        'TextButton in UI files should rely on theme style from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'FloatingActionButton',
    widgetStartPattern: RegExp(r'\bFloatingActionButton(?:\.extended)?\s*\('),
    propertyNames: <String>['backgroundColor', 'foregroundColor'],
    reason:
        'FloatingActionButton colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'Chip',
    widgetStartPattern: RegExp(r'\b(?:Chip|FilterChip|ChoiceChip)\s*\('),
    propertyNames: <String>['backgroundColor', 'side', 'labelStyle'],
    reason: 'Chip styles in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'Divider',
    widgetStartPattern: RegExp(r'\bDivider\s*\('),
    propertyNames: <String>['color'],
    reason: 'Divider color in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'ListTile',
    widgetStartPattern: RegExp(r'\bListTile\s*\('),
    propertyNames: <String>['iconColor', 'textColor', 'selectedColor'],
    reason: 'ListTile colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'Switch',
    widgetStartPattern: RegExp(r'\bSwitch\s*\('),
    propertyNames: <String>[
      'thumbColor',
      'trackColor',
      'activeColor',
      'activeTrackColor',
      'inactiveTrackColor',
    ],
    reason: 'Switch colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'Checkbox',
    widgetStartPattern: RegExp(r'\bCheckbox\s*\('),
    propertyNames: <String>['activeColor', 'checkColor', 'fillColor'],
    reason: 'Checkbox colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'Radio',
    widgetStartPattern: RegExp(r'\bRadio\s*<[^>]*>\s*\(|\bRadio\s*\('),
    propertyNames: <String>['activeColor', 'fillColor'],
    reason: 'Radio colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'Slider',
    widgetStartPattern: RegExp(r'\bSlider\s*\('),
    propertyNames: <String>['activeColor', 'inactiveColor'],
    reason: 'Slider colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'ProgressIndicator',
    widgetStartPattern: RegExp(
      r'\b(?:LinearProgressIndicator|CircularProgressIndicator)\s*\(',
    ),
    propertyNames: <String>['color', 'backgroundColor', 'valueColor'],
    reason:
        'ProgressIndicator colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'Dialog',
    widgetStartPattern: RegExp(r'\bDialog\s*\('),
    propertyNames: <String>['backgroundColor', 'surfaceTintColor'],
    reason: 'Dialog colors in UI files must come from component_themes.',
  ),
  _ForbiddenPropertyRule(
    widgetName: 'SnackBar',
    widgetStartPattern: RegExp(r'\bSnackBar\s*\('),
    propertyNames: <String>['backgroundColor', 'contentTextStyle'],
    reason: 'SnackBar colors in UI files must come from component_themes.',
  ),
];

final RegExp _widgetClassDeclarationPattern = RegExp(
  r'\bclass\s+\w+\s+extends\s+\w*Widget\b',
);

Future<void> main() async {
  final Directory root = Directory(ComponentThemeGuardConst.presentationRoot);
  if (!root.existsSync()) {
    stderr.writeln(
      'Missing `${ComponentThemeGuardConst.presentationRoot}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<ComponentThemeViolation> violations = <ComponentThemeViolation>[];
  final List<File> files = _collectSourceFiles(root);
  for (final File file in files) {
    final String path = _normalizePath(file.path);
    final List<String> lines = await file.readAsLines();
    if (!_isUiDesignFile(path: path, lines: lines)) {
      continue;
    }
    _checkFile(path: path, lines: lines, violations: violations);
  }

  if (violations.isEmpty) {
    stdout.writeln('Component theme usage contract passed.');
    return;
  }

  stderr.writeln('Component theme usage contract failed.');
  for (final ComponentThemeViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

void _checkFile({
  required String path,
  required List<String> lines,
  required List<ComponentThemeViolation> violations,
}) {
  final bool requiresThemeImport = _requiresCoreThemeImport(lines: lines);
  if (!requiresThemeImport) {
    _checkInlineOverrides(path: path, lines: lines, violations: violations);
    return;
  }

  final bool hasThemeImport = _hasCoreThemeImport(lines: lines);
  if (hasThemeImport) {
    _checkInlineOverrides(path: path, lines: lines, violations: violations);
    return;
  }

  violations.add(
    ComponentThemeViolation(
      filePath: path,
      lineNumber: 1,
      reason:
          'UI file with direct Material theme usage must import from `lib/core/themes/**`.',
      lineContent: path,
    ),
  );

  _checkInlineOverrides(path: path, lines: lines, violations: violations);
}

void _checkInlineOverrides({
  required String path,
  required List<String> lines,
  required List<ComponentThemeViolation> violations,
}) {
  for (int index = 0; index < lines.length; index++) {
    final String rawLine = lines[index];
    final String sourceLine = _stripLineCommentSmart(rawLine).trim();
    if (sourceLine.isEmpty) {
      continue;
    }

    for (final _ForbiddenPropertyRule rule in _forbiddenPropertyRules) {
      if (!rule.widgetStartPattern.hasMatch(sourceLine)) {
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
          final bool allowOverride = _isAllowOverrideLine(
            line: occurrence.lineContent,
            expression: occurrence.expression,
          );
          if (allowOverride) {
            continue;
          }
          final bool inlineColorOverride = _isInlineColorOverride(
            expression: occurrence.expression,
          );
          if (!inlineColorOverride) {
            continue;
          }
          violations.add(
            ComponentThemeViolation(
              filePath: path,
              lineNumber: occurrence.lineNumber,
              reason: '${rule.reason} (`${rule.widgetName}.$propertyName`)',
              lineContent: occurrence.lineContent,
            ),
          );
        }
      }
    }
  }
}

bool _requiresCoreThemeImport({required List<String> lines}) {
  for (final String rawLine in lines) {
    final String sourceLine = _stripLineCommentSmart(rawLine).trim();
    if (sourceLine.isEmpty) {
      continue;
    }
    final bool hasThemeAccess = _hasThemeAccessExpression(sourceLine);
    if (hasThemeAccess) {
      return true;
    }
    for (final _ForbiddenPropertyRule rule in _forbiddenPropertyRules) {
      if (rule.widgetStartPattern.hasMatch(sourceLine)) {
        return true;
      }
    }
  }
  return false;
}

bool _hasThemeAccessExpression(String sourceLine) {
  if (sourceLine.contains('Theme.of(context)')) {
    return true;
  }
  if (sourceLine.contains('context.theme')) {
    return true;
  }
  if (sourceLine.contains('context.colorScheme')) {
    return true;
  }
  if (sourceLine.contains('context.textTheme')) {
    return true;
  }
  return false;
}

bool _isAllowOverrideLine({required String line, required String expression}) {
  if (line.contains(ComponentThemeGuardConst.allowInlineOverrideMarker)) {
    return true;
  }
  if (expression.trim() == 'null') {
    return true;
  }
  return false;
}

bool _isInlineColorOverride({required String expression}) {
  final List<RegExp> inlineColorPatterns = <RegExp>[
    RegExp(r'\bcolorScheme\.'),
    RegExp(r'\bTheme\.of\(context\)\.colorScheme\.'),
    RegExp(r'\bColor\s*\('),
    RegExp(r'\bColors\.'),
  ];
  for (final RegExp pattern in inlineColorPatterns) {
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
  final RegExp propertyRegExp = RegExp(
    '\\b${RegExp.escape(propertyName)}\\s*:',
  );
  for (int index = blockStartIndex; index <= blockEndIndex; index++) {
    final String rawLine = lines[index];
    final String line = _stripLineCommentSmart(rawLine);
    final RegExpMatch? match = propertyRegExp.firstMatch(line);
    if (match == null) {
      continue;
    }
    final String expression = _collectPropertyExpression(
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

String _collectPropertyExpression({
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

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final String path = _normalizePath(entity.path);
    if (!path.endsWith(ComponentThemeGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(ComponentThemeGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(ComponentThemeGuardConst.freezedExtension)) {
      continue;
    }
    files.add(entity);
  }
  return files;
}

bool _isPresentationUiFile(String path) {
  if (path.startsWith(ComponentThemeGuardConst.sharedWidgetsRoot)) {
    return true;
  }
  if (!path.startsWith(ComponentThemeGuardConst.featurePrefix)) {
    return false;
  }
  if (path.contains(ComponentThemeGuardConst.featureScreensMarker)) {
    return true;
  }
  if (path.contains(ComponentThemeGuardConst.featureWidgetsMarker)) {
    return true;
  }
  return false;
}

bool _isUiDesignFile({required String path, required List<String> lines}) {
  if (!_isPresentationUiFile(path)) {
    return false;
  }
  if (path.contains(ComponentThemeGuardConst.providersMarker)) {
    return false;
  }
  if (_isLogicCompanionFile(path)) {
    return false;
  }
  if (_isBarrelFile(lines: lines)) {
    return false;
  }
  if (_containsUiDesignMarker(lines: lines)) {
    return true;
  }
  return false;
}

bool _isLogicCompanionFile(String path) {
  final List<String> segments = path.split('/');
  if (segments.isEmpty) {
    return false;
  }
  final String fileName = segments.last;
  if (fileName.endsWith(ComponentThemeGuardConst.modelSuffix)) {
    return true;
  }
  if (fileName.endsWith(ComponentThemeGuardConst.modelsSuffix)) {
    return true;
  }
  return false;
}

bool _isBarrelFile({required List<String> lines}) {
  bool hasDirectiveLine = false;
  for (final String rawLine in lines) {
    final String line = _stripLineCommentSmart(rawLine).trim();
    if (line.isEmpty) {
      continue;
    }
    final bool isDirectiveLine =
        line.startsWith(ComponentThemeGuardConst.exportPrefix) ||
        line.startsWith(ComponentThemeGuardConst.libraryPrefix) ||
        line.startsWith(ComponentThemeGuardConst.partPrefix);
    if (!isDirectiveLine) {
      return false;
    }
    hasDirectiveLine = true;
  }
  if (hasDirectiveLine) {
    return true;
  }
  return false;
}

bool _containsUiDesignMarker({required List<String> lines}) {
  for (final String rawLine in lines) {
    final String sourceLine = _stripLineCommentSmart(rawLine);
    if (sourceLine.contains(ComponentThemeGuardConst.widgetBuildMarker)) {
      return true;
    }
    if (sourceLine.contains(ComponentThemeGuardConst.showDialogMarker)) {
      return true;
    }
    if (sourceLine.contains(
      ComponentThemeGuardConst.showModalBottomSheetMarker,
    )) {
      return true;
    }
    if (_widgetClassDeclarationPattern.hasMatch(sourceLine)) {
      return true;
    }
  }
  return false;
}

bool _hasCoreThemeImport({required List<String> lines}) {
  for (final String rawLine in lines) {
    final String line = _stripLineCommentSmart(rawLine).trim();
    if (!line.startsWith(ComponentThemeGuardConst.importPrefix)) {
      continue;
    }
    if (!line.contains(ComponentThemeGuardConst.coreThemeImportMarker)) {
      continue;
    }
    return true;
  }
  return false;
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
