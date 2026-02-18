import 'dart:io';

/// UI Design Guard v3
///
/// Mục tiêu:
/// - Enforce các chuẩn UI/UX cơ bản cho layer UI (app/widgets, common/widgets, features/*/view).
/// - Chặn “magic numbers” theo các quy tắc thiết kế (spacing grid, button height, icon size, typography scale, touch target).
/// - Chặn hardcoded color (Color(0x..), '#RRGGBB', Colors.* trừ transparent/white/black).
/// - Chặn legacy Material widgets (ElevatedButton/BottomNavigationBar/ToggleButtons) để ép Material 3.
///
/// Triết lý:
/// - Fail-fast, không dùng else.
/// - Tối ưu hiệu năng bằng prefilter (contains) trước khi chạy RegExp.
/// - Không parse AST (vẫn là regex-based guard), nhưng giảm false-positive bằng ngữ cảnh.
///
/// Lưu ý:
/// - Guard hoạt động tốt nhất khi UI tokens đã được chuẩn hoá (AppSizes/AppSpacing/AppTypography/...).
/// - Nếu dự án của bạn đã “token-first”, có thể nâng rule lên mức “cấm literal hoàn toàn”.
class UiDesignGuardConst {
  const UiDesignGuardConst._();

  /// Root source directory.
  static const String libDirectory = 'lib';

  /// Dart file filters.
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';

  /// Comment prefix.
  static const String lineCommentPrefix = '//';

  /// UI layer markers.
  static const String commonWidgetsPrefix = 'lib/common/widgets/';
  static const String featurePrefix = 'lib/features/';
  static const String featureViewMarker = '/view/';
  static const String appWidgetsPrefix = 'lib/app/widgets/';

  /// Mobile breakpoint policy (dp).
  static const double mobileBreakpointMax = 600;

  /// Spacing grid values (8pt-ish grid).
  static const List<double> spacingGridValues = <double>[
    4,
    8,
    12,
    16,
    24,
    32,
    40,
  ];

  /// Recommended horizontal padding values (dp).
  static const List<double> horizontalPaddingValues = <double>[12, 16, 20];

  /// Button height range (dp).
  static const double buttonHeightMin = 40;
  static const double buttonHeightMax = 48;

  /// Icon size range (dp).
  static const double iconSizeMin = 20;
  static const double iconSizeMax = 28;

  /// AppBar height range (dp).
  static const double appBarHeightMin = 64;
  static const double appBarHeightMax = 80;

  /// Approved typography scale values (dp/sp).
  static const List<double> allowedTextSizes = <double>[12, 14, 16, 20, 24, 34];

  /// Minimum touch target (dp).
  static const double touchTargetMin = 48;

  /// Hard size literal threshold (dp) - nếu > ngưỡng thì flag.
  static const double hardcodedLargeSizeMax = 200;

  /// Marker to allow > hardcodedLargeSizeMax in a specific line.
  static const String allowLargeSizeMarker = 'ui-guard: allow-large-size';

  /// How many lines to look back to infer multi-line Icon(...) declarations.
  static const int iconLookbackLineCount = 10;

  /// How many lines to look around to infer SizedBox(...) and related contexts.
  static const int sizedBoxLookaroundLineCount = 12;

  /// Allowed Colors.* direct usage (minimal).
  static const Set<String> allowedMaterialColors = <String>{
    'transparent',
    'white',
    'black',
  };
}

/// A single violation record.
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

/// Rule interface for guard checks.
abstract class UiGuardRule {
  /// Human-readable name for logs/debugging.
  String get name;

  /// Check a specific source line in a given file.
  ///
  /// - [filePath] must be normalized with `/`.
  /// - [lineNumber] is 1-based.
  /// - [rawLine] is the original line (for reporting).
  /// - [sourceLine] is the same line without comments and trimmed.
  /// - [allLines] is full file content.
  /// - [index] is 0-based line index.
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  });
}

/// Entry point.
Future<void> main() async {
  final Directory libDir = Directory(UiDesignGuardConst.libDirectory);
  if (!libDir.existsSync()) {
    stderr.writeln('Missing `${UiDesignGuardConst.libDirectory}` directory.');
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(libDir);
  final List<UiDesignViolation> violations = <UiDesignViolation>[];

  final List<UiGuardRule> rules = <UiGuardRule>[
    const _LegacyComponentRule(),
    const _MobileBreakpointRule(),
    const _SpacingGridRule(),
    const _HorizontalPaddingRule(),
    const _ButtonHeightRule(),
    const _IconSizeRule(),
    const _AppBarHeightRule(),
    const _TypographyScaleRule(),
    const _TouchTargetRule(),
    const _HardcodedLargeSizeRule(),
    const _HardcodedColorRule(),
  ];

  for (final File file in sourceFiles) {
    final String normalizedPath = _normalizePath(file.path);
    if (!_isUiLayerFile(normalizedPath)) {
      continue;
    }

    final List<String> lines = await file.readAsLines();
    for (int i = 0; i < lines.length; i++) {
      final String rawLine = lines[i];
      final String sourceLine = _stripLineCommentSmart(rawLine).trim();
      if (sourceLine.isEmpty) {
        continue;
      }

      final int lineNumber = i + 1;
      for (final UiGuardRule rule in rules) {
        rule.checkLine(
          violations: violations,
          filePath: normalizedPath,
          lineNumber: lineNumber,
          rawLine: rawLine,
          sourceLine: sourceLine,
          allLines: lines,
          index: i,
        );
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('UI design guard v3 passed.');
    return;
  }

  stderr.writeln('UI design guard v3 failed.');
  for (final UiDesignViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

/// Collect Dart source files excluding generated/freezed outputs.
List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(UiDesignGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(UiDesignGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(UiDesignGuardConst.freezedExtension)) {
      continue;
    }

    files.add(entity);
  }
  return files;
}

/// Normalize filesystem path to `/`.
String _normalizePath(String path) => path.replaceAll('\\', '/');

/// Determine if a file is considered UI layer.
///
/// UI layer includes:
/// - lib/app/widgets/*
/// - lib/common/widgets/*
/// - lib/features/*/view/*
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

/// Strip `//` comments while respecting string literals.
///
/// This avoids false stripping when URLs or `//` exist inside quotes.
///
/// Limitation:
/// - This does not fully parse raw triple-quoted strings.
/// - But it is robust enough for most Flutter/Dart code lines.
String _stripLineCommentSmart(String sourceLine) {
  bool inSingleQuote = false;
  bool inDoubleQuote = false;
  bool escaped = false;

  for (int i = 0; i < sourceLine.length - 1; i++) {
    final String ch = sourceLine[i];

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

    if (ch != UiDesignGuardConst.lineCommentPrefix[0]) {
      continue;
    }
    if (sourceLine[i + 1] != UiDesignGuardConst.lineCommentPrefix[1]) {
      continue;
    }

    return sourceLine.substring(0, i);
  }

  return sourceLine;
}

/// Extract numeric group(1) from regex matches and parse to double.
Iterable<double> _extractNumbers(RegExp regExp, String sourceLine) sync* {
  final Iterable<RegExpMatch> matches = regExp.allMatches(sourceLine);
  for (final RegExpMatch match in matches) {
    final String? raw = match.group(1);
    if (raw == null) {
      continue;
    }
    final double? value = double.tryParse(raw);
    if (value == null) {
      continue;
    }
    yield value;
  }
}

/// Check whether current line is inside a SizedBox(...) declaration window.
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
    final String line = _stripLineCommentSmart(allLines[i]).trim();
    if (_Patterns.sizedBoxStart.hasMatch(line)) {
      return true;
    }
    if (i == currentIndex) {
      continue;
    }
    if (line.contains(');') || line.contains('}')) {
      return false;
    }
  }

  return false;
}

/// Check whether current line is in a SizedBox(...) that contains a Button child.
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
    final String line = _stripLineCommentSmart(allLines[i]).trim();
    if (_Patterns.sizedBoxStart.hasMatch(line)) {
      sizedBoxLineIndex = i;
      break;
    }
    if (i == currentIndex) {
      continue;
    }
    if (line.contains(');') || line.contains('}')) {
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
    final String line = _stripLineCommentSmart(allLines[i]).trim();
    if (_Patterns.buttonWidget.hasMatch(line)) {
      return true;
    }
    if (i == sizedBoxLineIndex) {
      continue;
    }
    if (line.contains(');')) {
      return false;
    }
  }

  return false;
}

/// Centralized regex patterns (compiled once).
class _Patterns {
  const _Patterns._();

  static final RegExp mobileBreakpoint = RegExp(
    r'\b(?:tabletBreakpoint|mobileBreakpoint|mobileMaxWidth)\s*[:=]\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp edgeInsetsHorizontal = RegExp(
    r'EdgeInsets\.symmetric\([^)]*horizontal\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp spacingLiteral = RegExp(
    r'\b(?:padding|margin|spacing|runSpacing|mainAxisSpacing|crossAxisSpacing)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp sizedBoxSpacingInline = RegExp(
    r'\bSizedBox\s*\([^)]*\b(?:height|width)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp sizedBoxSizeProperty = RegExp(
    r'^\s*(?:height|width)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp sizedBoxStart = RegExp(r'\bSizedBox\s*\(');

  static final RegExp buttonHeight = RegExp(
    r'\b(?:minimumSize|fixedSize)\s*:\s*(?:const\s+)?Size\([^,]+,\s*(\d+(?:\.\d+)?)\s*\)',
  );

  static final RegExp buttonHeightFrom = RegExp(
    r'Size\.fromHeight\(\s*(?:const\s+)?(\d+(?:\.\d+)?)\s*\)',
  );

  static final RegExp sizedBoxButtonHeightInline = RegExp(
    r'\bSizedBox\s*\([^)]*\bheight\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)'
    r'[^)]*\bchild\s*:\s*(?:const\s+)?(?:\w+\.)?(?:ElevatedButton|FilledButton|OutlinedButton|TextButton)\s*\(',
  );

  static final RegExp heightProperty = RegExp(
    r'^\s*height\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp buttonWidget = RegExp(
    r'\b(?:ElevatedButton|FilledButton|OutlinedButton|TextButton)\s*\(',
  );

  static final RegExp iconSizeInline = RegExp(
    r'Icon\([^)]*size\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp iconStart = RegExp(r'\bIcon\s*\(');

  static final RegExp iconSizeProperty = RegExp(
    r'^\s*size\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp appBarHeight = RegExp(
    r'\btoolbarHeight\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp fontSize = RegExp(
    r'\bfontSize\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp legacyComponent = RegExp(
    r'\b(?:ElevatedButton|BottomNavigationBar|ToggleButtons)\s*\(',
  );

  static final RegExp colorConstructor = RegExp(
    r'\bColor\(\s*0x[0-9A-Fa-f]+\s*\)',
  );

  static final RegExp colorHexString = RegExp(r'#[0-9A-Fa-f]{3,8}');

  static final RegExp materialColor = RegExp(
    r'\bColors\.([A-Za-z_][A-Za-z0-9_]*)',
  );

  static final RegExp touchTarget = RegExp(
    r'\b(?:minWidth|minHeight)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );

  static final RegExp largeSizeLiteral = RegExp(
    r'\b(?:width|height|size|radius|padding|margin|spacing)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
  );
}

/// Rule: forbid legacy Material components.
class _LegacyComponentRule implements UiGuardRule {
  const _LegacyComponentRule();

  @override
  String get name => 'legacy_component';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    if (!sourceLine.contains('Button') &&
        !sourceLine.contains('Navigation') &&
        !sourceLine.contains('Toggle')) {
      return;
    }
    if (!_Patterns.legacyComponent.hasMatch(sourceLine)) {
      return;
    }
    violations.add(
      UiDesignViolation(
        filePath: filePath,
        lineNumber: lineNumber,
        reason:
            'Use Material 3 components (`FilledButton`, `NavigationBar`, `SegmentedButton`) instead of legacy widgets.',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

/// Rule: mobile breakpoint must be <= 600dp.
class _MobileBreakpointRule implements UiGuardRule {
  const _MobileBreakpointRule();

  @override
  String get name => 'mobile_breakpoint';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    if (!sourceLine.contains('Breakpoint') &&
        !sourceLine.contains('MaxWidth')) {
      return;
    }

    final Iterable<double> values = _extractNumbers(
      _Patterns.mobileBreakpoint,
      sourceLine,
    );
    for (final double value in values) {
      if (value <= UiDesignGuardConst.mobileBreakpointMax) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Mobile breakpoint must be <= ${UiDesignGuardConst.mobileBreakpointMax.toInt()}dp.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

/// Rule: spacing must use approved grid values.
class _SpacingGridRule implements UiGuardRule {
  const _SpacingGridRule();

  @override
  String get name => 'spacing_grid';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    final bool mayContainSpacing =
        sourceLine.contains('padding') ||
        sourceLine.contains('margin') ||
        sourceLine.contains('spacing') ||
        sourceLine.contains('SizedBox') ||
        sourceLine.contains('runSpacing') ||
        sourceLine.contains('mainAxisSpacing') ||
        sourceLine.contains('crossAxisSpacing');

    if (!mayContainSpacing) {
      return;
    }

    final Set<double> values = <double>{
      ..._extractNumbers(_Patterns.spacingLiteral, sourceLine),
      ..._extractNumbers(_Patterns.sizedBoxSpacingInline, sourceLine),
    };

    final bool insideSizedBox = _isInsideSizedBoxDeclaration(
      allLines: allLines,
      currentIndex: index,
    );
    if (insideSizedBox) {
      values.addAll(
        _extractNumbers(_Patterns.sizedBoxSizeProperty, sourceLine),
      );
    }

    if (values.isEmpty) {
      return;
    }

    for (final double value in values) {
      if (UiDesignGuardConst.spacingGridValues.contains(value)) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Spacing must use approved grid values (${UiDesignGuardConst.spacingGridValues.join('/')}).',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

/// Rule: horizontal padding should be within approved values.
class _HorizontalPaddingRule implements UiGuardRule {
  const _HorizontalPaddingRule();

  @override
  String get name => 'horizontal_padding';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    if (!sourceLine.contains('EdgeInsets.symmetric') ||
        !sourceLine.contains('horizontal')) {
      return;
    }

    final Iterable<double> values = _extractNumbers(
      _Patterns.edgeInsetsHorizontal,
      sourceLine,
    );
    for (final double value in values) {
      if (UiDesignGuardConst.horizontalPaddingValues.contains(value)) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Horizontal padding should be one of (${UiDesignGuardConst.horizontalPaddingValues.join('/')}) dp.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

/// Rule: button height must be within min-max range.
class _ButtonHeightRule implements UiGuardRule {
  const _ButtonHeightRule();

  @override
  String get name => 'button_height';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    final bool mayContainButtonSizing =
        sourceLine.contains('minimumSize') ||
        sourceLine.contains('fixedSize') ||
        sourceLine.contains('Size.fromHeight') ||
        sourceLine.contains('TextButton') ||
        sourceLine.contains('FilledButton') ||
        sourceLine.contains('OutlinedButton') ||
        sourceLine.contains('ElevatedButton') ||
        sourceLine.contains('SizedBox') ||
        sourceLine.contains('height');

    if (!mayContainButtonSizing) {
      return;
    }

    final Set<double> values = <double>{
      ..._extractNumbers(_Patterns.buttonHeight, sourceLine),
      ..._extractNumbers(_Patterns.buttonHeightFrom, sourceLine),
      ..._extractNumbers(_Patterns.sizedBoxButtonHeightInline, sourceLine),
    };

    final bool insideButtonSizedBox = _isInsideButtonSizedBoxDeclaration(
      allLines: allLines,
      currentIndex: index,
    );
    if (insideButtonSizedBox) {
      values.addAll(_extractNumbers(_Patterns.heightProperty, sourceLine));
    }

    if (values.isEmpty) {
      return;
    }

    for (final double value in values) {
      if (value >= UiDesignGuardConst.buttonHeightMin &&
          value <= UiDesignGuardConst.buttonHeightMax) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Button height must be in ${UiDesignGuardConst.buttonHeightMin.toInt()}-${UiDesignGuardConst.buttonHeightMax.toInt()}dp.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

/// Rule: icon size should be within recommended range.
class _IconSizeRule implements UiGuardRule {
  const _IconSizeRule();

  @override
  String get name => 'icon_size';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    if (!sourceLine.contains('Icon')) {
      return;
    }

    // Single-line: Icon(... size: 24)
    final Iterable<double> inlineValues = _extractNumbers(
      _Patterns.iconSizeInline,
      sourceLine,
    );
    for (final double value in inlineValues) {
      if (value >= UiDesignGuardConst.iconSizeMin &&
          value <= UiDesignGuardConst.iconSizeMax) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Icon size should be in ${UiDesignGuardConst.iconSizeMin.toInt()}-${UiDesignGuardConst.iconSizeMax.toInt()}dp (24dp default).',
          lineContent: rawLine.trim(),
        ),
      );
    }

    // Multi-line: inside Icon( ... size: 24, )
    bool insideIconDeclaration = false;
    int lookbackStart = index - UiDesignGuardConst.iconLookbackLineCount;
    if (lookbackStart < 0) {
      lookbackStart = 0;
    }

    for (int i = index; i >= lookbackStart; i--) {
      final String prev = _stripLineCommentSmart(allLines[i]).trim();
      if (_Patterns.iconStart.hasMatch(prev)) {
        insideIconDeclaration = true;
        break;
      }
      if (prev.contains(');') || prev.contains('}')) {
        break;
      }
    }

    if (!insideIconDeclaration) {
      return;
    }

    final Iterable<double> propertyValues = _extractNumbers(
      _Patterns.iconSizeProperty,
      sourceLine,
    );
    for (final double value in propertyValues) {
      if (value >= UiDesignGuardConst.iconSizeMin &&
          value <= UiDesignGuardConst.iconSizeMax) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Icon size should be in ${UiDesignGuardConst.iconSizeMin.toInt()}-${UiDesignGuardConst.iconSizeMax.toInt()}dp (24dp default).',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

/// Rule: AppBar toolbarHeight must be within range.
class _AppBarHeightRule implements UiGuardRule {
  const _AppBarHeightRule();

  @override
  String get name => 'appbar_height';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    if (!sourceLine.contains('toolbarHeight')) {
      return;
    }

    final Iterable<double> values = _extractNumbers(
      _Patterns.appBarHeight,
      sourceLine,
    );
    for (final double value in values) {
      if (value >= UiDesignGuardConst.appBarHeightMin &&
          value <= UiDesignGuardConst.appBarHeightMax) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'AppBar height must be in ${UiDesignGuardConst.appBarHeightMin.toInt()}-${UiDesignGuardConst.appBarHeightMax.toInt()}dp.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

/// Rule: fontSize must use approved typography scale values.
class _TypographyScaleRule implements UiGuardRule {
  const _TypographyScaleRule();

  @override
  String get name => 'typography_scale';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    if (!sourceLine.contains('fontSize')) {
      return;
    }

    final Iterable<double> values = _extractNumbers(
      _Patterns.fontSize,
      sourceLine,
    );
    for (final double value in values) {
      if (UiDesignGuardConst.allowedTextSizes.contains(value)) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Text size must use approved typography scale (${UiDesignGuardConst.allowedTextSizes.join('/')}).',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

/// Rule: touch target must be at least min dp.
class _TouchTargetRule implements UiGuardRule {
  const _TouchTargetRule();

  @override
  String get name => 'touch_target';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    if (!sourceLine.contains('minWidth') && !sourceLine.contains('minHeight')) {
      return;
    }

    final Iterable<double> values = _extractNumbers(
      _Patterns.touchTarget,
      sourceLine,
    );
    for (final double value in values) {
      if (value >= UiDesignGuardConst.touchTargetMin) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Touch target must be at least ${UiDesignGuardConst.touchTargetMin.toInt()}dp.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

/// Rule: forbid very large hardcoded sizes (> threshold) unless marker exists on the same line.
class _HardcodedLargeSizeRule implements UiGuardRule {
  const _HardcodedLargeSizeRule();

  @override
  String get name => 'hardcoded_large_size';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    if (rawLine.contains(UiDesignGuardConst.allowLargeSizeMarker)) {
      return;
    }

    final bool mayContainLargeSize =
        sourceLine.contains('width') ||
        sourceLine.contains('height') ||
        sourceLine.contains('size') ||
        sourceLine.contains('radius') ||
        sourceLine.contains('padding') ||
        sourceLine.contains('margin') ||
        sourceLine.contains('spacing');

    if (!mayContainLargeSize) {
      return;
    }

    final Iterable<double> values = _extractNumbers(
      _Patterns.largeSizeLiteral,
      sourceLine,
    );
    for (final double value in values) {
      if (value <= UiDesignGuardConst.hardcodedLargeSizeMax) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Avoid hardcoded size > ${UiDesignGuardConst.hardcodedLargeSizeMax.toInt()}dp. Extract to tokens/constants. '
              'If truly required, add `${UiDesignGuardConst.allowLargeSizeMarker}` on the same line.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

/// Rule: forbid hardcoded colors in UI (Color(0x..), '#..', Colors.* except minimal set).
class _HardcodedColorRule implements UiGuardRule {
  const _HardcodedColorRule();

  @override
  String get name => 'hardcoded_color';

  @override
  void checkLine({
    required List<UiDesignViolation> violations,
    required String filePath,
    required int lineNumber,
    required String rawLine,
    required String sourceLine,
    required List<String> allLines,
    required int index,
  }) {
    final bool mayContainColor =
        sourceLine.contains('Color(') ||
        sourceLine.contains('#') ||
        sourceLine.contains('Colors.');
    if (!mayContainColor) {
      return;
    }

    if (_Patterns.colorConstructor.hasMatch(sourceLine)) {
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Do not hardcode colors in UI. Use Theme colorScheme or centralized tokens.',
          lineContent: rawLine.trim(),
        ),
      );
    }

    if (_Patterns.colorHexString.hasMatch(sourceLine)) {
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Do not hardcode hex colors in UI. Use Theme colorScheme or centralized tokens.',
          lineContent: rawLine.trim(),
        ),
      );
    }

    final Iterable<RegExpMatch> matches = _Patterns.materialColor.allMatches(
      sourceLine,
    );
    for (final RegExpMatch match in matches) {
      final String colorName = match.group(1) ?? '';
      if (UiDesignGuardConst.allowedMaterialColors.contains(colorName)) {
        continue;
      }
      violations.add(
        UiDesignViolation(
          filePath: filePath,
          lineNumber: lineNumber,
          reason:
              'Avoid direct `Colors.*` in UI. Use Theme colorScheme or centralized tokens.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}
