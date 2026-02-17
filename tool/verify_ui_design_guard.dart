import 'dart:io';

class UiDesignGuardConst {
  const UiDesignGuardConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';

  static const String commonWidgetsPrefix = 'lib/common/widgets/';
  static const String featurePrefix = 'lib/features/';
  static const String featureViewMarker = '/view/';
  static const String appWidgetsPrefix = 'lib/app/widgets/';

  static const double mobileBreakpointMax = 600;
  static const List<double> spacingGridValues = <double>[
    4,
    8,
    12,
    16,
    24,
    32,
    40,
  ];
  static const List<double> horizontalPaddingValues = <double>[12, 16, 20];
  static const double buttonHeightMin = 40;
  static const double buttonHeightMax = 48;
  static const double iconSizeMin = 20;
  static const double iconSizeMax = 28;
  static const double appBarHeightMin = 64;
  static const double appBarHeightMax = 80;
  static const List<double> allowedTextSizes = <double>[12, 14, 16, 20, 24, 34];
  static const double touchTargetMin = 48;
  static const double hardcodedLargeSizeMax = 200;
  static const String allowLargeSizeMarker = 'ui-guard: allow-large-size';
  static const int iconLookbackLineCount = 10;
  static const int sizedBoxLookaroundLineCount = 12;
  static const Set<String> allowedMaterialColors = <String>{
    'transparent',
    'white',
    'black',
  };
}

class UiDesignViolation {
  const UiDesignViolation({
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

final RegExp _mobileBreakpointRegExp = RegExp(
  r'\b(?:tabletBreakpoint|mobileBreakpoint|mobileMaxWidth)\s*[:=]\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _edgeInsetsHorizontalLiteralRegExp = RegExp(
  r'EdgeInsets\.symmetric\([^)]*horizontal\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _spacingLiteralRegExp = RegExp(
  r'\b(?:padding|margin|spacing|runSpacing|mainAxisSpacing|crossAxisSpacing)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _sizedBoxSpacingInlineRegExp = RegExp(
  r'\bSizedBox\s*\([^)]*\b(?:height|width)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _sizedBoxSizePropertyRegExp = RegExp(
  r'^\s*(?:height|width)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _sizedBoxStartRegExp = RegExp(r'\bSizedBox\s*\(');
final RegExp _buttonHeightRegExp = RegExp(
  r'\b(?:minimumSize|fixedSize)\s*:\s*(?:const\s+)?Size\([^,]+,\s*(\d+(?:\.\d+)?)\s*\)',
);
final RegExp _buttonHeightFromRegExp = RegExp(
  r'Size\.fromHeight\(\s*(?:const\s+)?(\d+(?:\.\d+)?)\s*\)',
);
final RegExp _sizedBoxButtonHeightInlineRegExp = RegExp(
  r'\bSizedBox\s*\([^)]*\bheight\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)'
  r'[^)]*\bchild\s*:\s*(?:const\s+)?(?:\w+\.)?(?:ElevatedButton|FilledButton|OutlinedButton|TextButton)\s*\(',
);
final RegExp _heightPropertyRegExp = RegExp(
  r'^\s*height\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _buttonWidgetRegExp = RegExp(
  r'\b(?:ElevatedButton|FilledButton|OutlinedButton|TextButton)\s*\(',
);
final RegExp _iconSizeRegExp = RegExp(
  r'Icon\([^)]*size\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _iconStartRegExp = RegExp(r'\bIcon\s*\(');
final RegExp _iconSizePropertyRegExp = RegExp(
  r'^\s*size\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _appBarHeightRegExp = RegExp(
  r'\btoolbarHeight\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _fontSizeRegExp = RegExp(
  r'\bfontSize\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _legacyComponentRegExp = RegExp(
  r'\b(?:ElevatedButton|BottomNavigationBar|ToggleButtons)\s*\(',
);
final RegExp _colorConstructorRegExp = RegExp(
  r'\bColor\(\s*0x[0-9A-Fa-f]+\s*\)',
);
final RegExp _colorHexStringRegExp = RegExp(r'#[0-9A-Fa-f]{3,8}');
final RegExp _materialColorRegExp = RegExp(
  r'\bColors\.([A-Za-z_][A-Za-z0-9_]*)',
);
final RegExp _touchTargetRegExp = RegExp(
  r'\b(?:minWidth|minHeight)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _largeSizeLiteralRegExp = RegExp(
  r'\b(?:width|height|size|radius|padding|margin|spacing)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);

Future<void> main() async {
  final Directory libDir = Directory(UiDesignGuardConst.libDirectory);
  if (!libDir.existsSync()) {
    stderr.writeln('Missing `${UiDesignGuardConst.libDirectory}` directory.');
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(libDir);
  final List<UiDesignViolation> violations = <UiDesignViolation>[];

  for (final File file in sourceFiles) {
    final String normalizedPath = file.path.replaceAll('\\', '/');
    final bool isUiFile = _isUiLayerFile(normalizedPath);
    if (!isUiFile) {
      continue;
    }

    final List<String> lines = await file.readAsLines();
    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String sourceLine = _stripLineComment(rawLine).trim();
      if (sourceLine.isEmpty) {
        continue;
      }

      _checkLegacyComponentUsage(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
      );
      _checkMobileBreakpoint(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
      );
      _checkSpacingGrid(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
        allLines: lines,
        currentIndex: index,
      );
      _checkHorizontalPadding(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
      );
      _checkButtonHeight(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
        allLines: lines,
        currentIndex: index,
      );
      _checkIconSize(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
        allLines: lines,
        currentIndex: index,
      );
      _checkAppBarHeight(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
      );
      _checkTextSize(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
      );
      _checkTouchTarget(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
      );
      _checkHardcodedLargeSize(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
      );
      _checkHardcodedColor(
        violations: violations,
        path: normalizedPath,
        rawLine: rawLine,
        sourceLine: sourceLine,
        lineNumber: index + 1,
      );
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('UI design guard passed.');
    return;
  }

  stderr.writeln('UI design guard failed.');
  for (final UiDesignViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

void _checkLegacyComponentUsage({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
}) {
  if (!_legacyComponentRegExp.hasMatch(sourceLine)) {
    return;
  }
  violations.add(
    UiDesignViolation(
      filePath: path,
      lineNumber: lineNumber,
      reason:
          'Use Material 3 components (`FilledButton`, `NavigationBar`, `SegmentedButton`) instead of legacy widgets.',
      lineContent: rawLine.trim(),
    ),
  );
}

void _checkMobileBreakpoint({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
}) {
  final Iterable<RegExpMatch> matches = _mobileBreakpointRegExp.allMatches(
    sourceLine,
  );
  for (final RegExpMatch match in matches) {
    final double? value = double.tryParse(match.group(1) ?? '');
    if (value == null) {
      continue;
    }
    if (value <= UiDesignGuardConst.mobileBreakpointMax) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Mobile breakpoint must be <= ${UiDesignGuardConst.mobileBreakpointMax.toInt()}dp.',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

void _checkSpacingGrid({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
  required List<String> allLines,
  required int currentIndex,
}) {
  final Set<double> values = <double>{
    ..._extractNumbers(_spacingLiteralRegExp, sourceLine),
    ..._extractNumbers(_sizedBoxSpacingInlineRegExp, sourceLine),
  };
  final bool insideSizedBox = _isInsideSizedBoxDeclaration(
    allLines: allLines,
    currentIndex: currentIndex,
  );
  if (insideSizedBox) {
    values.addAll(_extractNumbers(_sizedBoxSizePropertyRegExp, sourceLine));
  }
  for (final double value in values) {
    if (UiDesignGuardConst.spacingGridValues.contains(value)) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason: 'Spacing must use 8-point grid (4/8/12/16/24/32/40).',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

void _checkHorizontalPadding({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
}) {
  final Iterable<RegExpMatch> matches = _edgeInsetsHorizontalLiteralRegExp
      .allMatches(sourceLine);
  for (final RegExpMatch match in matches) {
    final double? value = double.tryParse(match.group(1) ?? '');
    if (value == null) {
      continue;
    }
    if (UiDesignGuardConst.horizontalPaddingValues.contains(value)) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Horizontal padding should stay in 16-20dp for screen layouts (12dp only when scaling down).',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

void _checkButtonHeight({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
  required List<String> allLines,
  required int currentIndex,
}) {
  final Set<double> values = <double>{
    ..._extractNumbers(_buttonHeightRegExp, sourceLine),
    ..._extractNumbers(_buttonHeightFromRegExp, sourceLine),
    ..._extractNumbers(_sizedBoxButtonHeightInlineRegExp, sourceLine),
  };
  final bool insideButtonSizedBox = _isInsideButtonSizedBoxDeclaration(
    allLines: allLines,
    currentIndex: currentIndex,
  );
  if (insideButtonSizedBox) {
    values.addAll(_extractNumbers(_heightPropertyRegExp, sourceLine));
  }
  if (values.isEmpty) {
    return;
  }

  for (final double value in values) {
    if ((value >= UiDesignGuardConst.buttonHeightMin) &&
        (value <= UiDesignGuardConst.buttonHeightMax)) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Button height must be in ${UiDesignGuardConst.buttonHeightMin.toInt()}-${UiDesignGuardConst.buttonHeightMax.toInt()}dp.',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

void _checkIconSize({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
  required List<String> allLines,
  required int currentIndex,
}) {
  // Check single-line Icon declarations
  final Iterable<double> values = _extractNumbers(_iconSizeRegExp, sourceLine);
  for (final double value in values) {
    if ((value >= UiDesignGuardConst.iconSizeMin) &&
        (value <= UiDesignGuardConst.iconSizeMax)) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Icon size should be in ${UiDesignGuardConst.iconSizeMin.toInt()}-${UiDesignGuardConst.iconSizeMax.toInt()}dp (24dp default).',
        lineContent: rawLine.trim(),
      ),
    );
  }

  // Check multi-line Icon declarations
  // Look back up to N lines to find Icon( declaration
  bool insideIconDeclaration = false;
  for (
    int i = currentIndex;
    i >= 0 && i > currentIndex - UiDesignGuardConst.iconLookbackLineCount;
    i--
  ) {
    final String prevLine = _stripLineComment(allLines[i]).trim();
    if (_iconStartRegExp.hasMatch(prevLine)) {
      insideIconDeclaration = true;
      break;
    }
    if (prevLine.contains(');') || prevLine.contains('}')) {
      // Hit end of another statement, stop searching
      break;
    }
  }

  if (insideIconDeclaration) {
    final Iterable<double> propertyValues = _extractNumbers(
      _iconSizePropertyRegExp,
      sourceLine,
    );
    for (final double value in propertyValues) {
      if ((value >= UiDesignGuardConst.iconSizeMin) &&
          (value <= UiDesignGuardConst.iconSizeMax)) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: path,
          lineNumber: lineNumber,
          reason:
              'Icon size should be in ${UiDesignGuardConst.iconSizeMin.toInt()}-${UiDesignGuardConst.iconSizeMax.toInt()}dp (24dp default).',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

void _checkAppBarHeight({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
}) {
  final Iterable<double> values = _extractNumbers(
    _appBarHeightRegExp,
    sourceLine,
  );
  for (final double value in values) {
    if ((value >= UiDesignGuardConst.appBarHeightMin) &&
        (value <= UiDesignGuardConst.appBarHeightMax)) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'AppBar height must be in ${UiDesignGuardConst.appBarHeightMin.toInt()}-${UiDesignGuardConst.appBarHeightMax.toInt()}dp.',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

void _checkTextSize({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
}) {
  final Iterable<double> values = _extractNumbers(_fontSizeRegExp, sourceLine);
  for (final double value in values) {
    if (UiDesignGuardConst.allowedTextSizes.contains(value)) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Text size must use approved typography scale tokens (12/14/16/20/24/34).',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

void _checkTouchTarget({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
}) {
  final Iterable<double> values = _extractNumbers(
    _touchTargetRegExp,
    sourceLine,
  );
  for (final double value in values) {
    if (value >= UiDesignGuardConst.touchTargetMin) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Touch target must be at least ${UiDesignGuardConst.touchTargetMin.toInt()}dp.',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

void _checkHardcodedLargeSize({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
}) {
  if (rawLine.contains(UiDesignGuardConst.allowLargeSizeMarker)) {
    return;
  }

  final Iterable<double> values = _extractNumbers(
    _largeSizeLiteralRegExp,
    sourceLine,
  );
  for (final double value in values) {
    if (value <= UiDesignGuardConst.hardcodedLargeSizeMax) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Avoid hardcoded size > ${UiDesignGuardConst.hardcodedLargeSizeMax.toInt()}dp. Extract to constants and justify with `${UiDesignGuardConst.allowLargeSizeMarker}` when required.',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

void _checkHardcodedColor({
  required List<UiDesignViolation> violations,
  required String path,
  required String rawLine,
  required String sourceLine,
  required int lineNumber,
}) {
  if (_colorConstructorRegExp.hasMatch(sourceLine)) {
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Do not hardcode colors in UI. Use Theme colorScheme or centralized constants.',
        lineContent: rawLine.trim(),
      ),
    );
  }

  if (_colorHexStringRegExp.hasMatch(sourceLine)) {
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Do not hardcode color hex in UI. Use Theme colorScheme or centralized constants.',
        lineContent: rawLine.trim(),
      ),
    );
  }

  final Iterable<RegExpMatch> matches = _materialColorRegExp.allMatches(
    sourceLine,
  );
  for (final RegExpMatch match in matches) {
    final String colorName = match.group(1) ?? '';
    if (UiDesignGuardConst.allowedMaterialColors.contains(colorName)) {
      continue;
    }
    violations.add(
      UiDesignViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Avoid direct `Colors.*` in UI. Use Theme colorScheme or centralized color constants.',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

Iterable<double> _extractNumbers(RegExp regExp, String sourceLine) sync* {
  final Iterable<RegExpMatch> matches = regExp.allMatches(sourceLine);
  for (final RegExpMatch match in matches) {
    final String? rawValue = match.group(1);
    if (rawValue == null) {
      continue;
    }
    final double? value = double.tryParse(rawValue);
    if (value == null) {
      continue;
    }
    yield value;
  }
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final String normalizedPath = entity.path.replaceAll('\\', '/');
    if (!normalizedPath.endsWith(UiDesignGuardConst.dartExtension)) {
      continue;
    }
    if (normalizedPath.endsWith(UiDesignGuardConst.generatedExtension)) {
      continue;
    }
    if (normalizedPath.endsWith(UiDesignGuardConst.freezedExtension)) {
      continue;
    }

    files.add(entity);
  }
  return files;
}

String _stripLineComment(String sourceLine) {
  bool inSingleQuote = false;
  bool inDoubleQuote = false;
  bool escaped = false;
  for (int index = 0; index < sourceLine.length - 1; index++) {
    final String char = sourceLine[index];
    if (escaped) {
      escaped = false;
      continue;
    }
    if ((inSingleQuote || inDoubleQuote) && char == r'\') {
      escaped = true;
      continue;
    }
    if (!inDoubleQuote && char == '\'') {
      inSingleQuote = !inSingleQuote;
      continue;
    }
    if (!inSingleQuote && char == '"') {
      inDoubleQuote = !inDoubleQuote;
      continue;
    }
    if (inSingleQuote || inDoubleQuote) {
      continue;
    }
    if (char != UiDesignGuardConst.lineCommentPrefix[0]) {
      continue;
    }
    if (sourceLine[index + 1] != UiDesignGuardConst.lineCommentPrefix[1]) {
      continue;
    }
    return sourceLine.substring(0, index);
  }
  return sourceLine;
}

bool _isUiLayerFile(String path) {
  if (path.startsWith(UiDesignGuardConst.appWidgetsPrefix)) {
    return true;
  }
  if (path.startsWith(UiDesignGuardConst.commonWidgetsPrefix)) {
    return true;
  }
  if (!path.startsWith(UiDesignGuardConst.featurePrefix)) {
    return false;
  }
  if (!path.contains(UiDesignGuardConst.featureViewMarker)) {
    return false;
  }
  return true;
}

bool _isInsideSizedBoxDeclaration({
  required List<String> allLines,
  required int currentIndex,
}) {
  int startIndex =
      currentIndex - UiDesignGuardConst.sizedBoxLookaroundLineCount;
  if (startIndex < 0) {
    startIndex = 0;
  }
  for (int i = currentIndex; i >= startIndex; i--) {
    final String candidateLine = _stripLineComment(allLines[i]).trim();
    if (_sizedBoxStartRegExp.hasMatch(candidateLine)) {
      return true;
    }
    if (i == currentIndex) {
      continue;
    }
    if (candidateLine.contains(');') || candidateLine.contains('}')) {
      return false;
    }
  }
  return false;
}

bool _isInsideButtonSizedBoxDeclaration({
  required List<String> allLines,
  required int currentIndex,
}) {
  int startIndex =
      currentIndex - UiDesignGuardConst.sizedBoxLookaroundLineCount;
  if (startIndex < 0) {
    startIndex = 0;
  }
  int sizedBoxLineIndex = -1;
  for (int i = currentIndex; i >= startIndex; i--) {
    final String candidateLine = _stripLineComment(allLines[i]).trim();
    if (_sizedBoxStartRegExp.hasMatch(candidateLine)) {
      sizedBoxLineIndex = i;
      break;
    }
    if (i == currentIndex) {
      continue;
    }
    if (candidateLine.contains(');') || candidateLine.contains('}')) {
      return false;
    }
  }
  if (sizedBoxLineIndex < 0) {
    return false;
  }

  int endIndex =
      sizedBoxLineIndex + UiDesignGuardConst.sizedBoxLookaroundLineCount;
  if (endIndex >= allLines.length) {
    endIndex = allLines.length - 1;
  }
  for (int i = sizedBoxLineIndex; i <= endIndex; i++) {
    final String candidateLine = _stripLineComment(allLines[i]).trim();
    if (_buttonWidgetRegExp.hasMatch(candidateLine)) {
      return true;
    }
    if (i == sizedBoxLineIndex) {
      continue;
    }
    if (candidateLine.contains(');')) {
      return false;
    }
  }
  return false;
}
