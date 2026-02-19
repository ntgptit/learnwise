import 'dart:io';

/// Theme Contract Guard (v2)
///
/// Mục tiêu
/// - Ép codebase tuân thủ kiến trúc theme thống nhất:
///   - Material 3 bắt buộc (light + dark)
///   - Có factory `static ThemeData light()` và `static ThemeData dark()`
///   - Có `lightColorScheme` + `darkColorScheme` trong `color_schemes.dart`
///   - `ColorScheme.fromSeed(...)` bắt buộc để palette nhất quán
///   - `MaterialApp` phải set `themeMode:`
///   - `dynamic_color` dependency là khuyến nghị mạnh:
///     - Nếu không dùng, phải có marker `theme-guard: allow-no-dynamic-color`
///
/// Điểm nâng cấp so với v1
/// - Strip comment trước khi check, tránh pass nhầm do comment.
/// - Check `useMaterial3: true` theo từng block `light()` và `dark()`
///   thay vì đếm số lần xuất hiện.
/// - Báo lỗi rõ hơn theo file + mục tiêu cần sửa.
///
/// Gợi ý tích hợp CI:
/// - Add vào .github/workflows/flutter_ci.yml như 1 step bắt buộc.
///
/// Lưu ý:
/// - Guard này chỉ kiểm tra contract tối thiểu của theme.
/// - Guard màu hard-coded (Color/Colors.*) nên tách thành guard riêng.
class ThemeContractConst {
  const ThemeContractConst._();

  static const String pubspecPath = 'pubspec.yaml';
  static const String appThemePath = 'lib/app/theme/app_theme.dart';
  static const String colorSchemesPath = 'lib/app/theme/color_schemes.dart';
  static const String mainPath = 'lib/main.dart';

  static const String allowNoDynamicColorMarker =
      'theme-guard: allow-no-dynamic-color';

  static const String lineCommentPrefix = '//';
}

/// Một vi phạm của Theme Contract.
class ThemeViolation {
  const ThemeViolation({
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

final RegExp _dynamicColorDependencyRegExp = RegExp(
  r'^\s*dynamic_color\s*:',
  multiLine: true,
);

final RegExp _lightThemeFactoryRegExp = RegExp(
  r'\bstatic\s+ThemeData\s+light\s*\(\s*\)\s*{',
);

final RegExp _darkThemeFactoryRegExp = RegExp(
  r'\bstatic\s+ThemeData\s+dark\s*\(\s*\)\s*{',
);

final RegExp _useMaterial3RegExp = RegExp(r'\buseMaterial3\s*:\s*true\b');
final RegExp _themeDataInvocationRegExp = RegExp(r'\bThemeData\s*\(');
final RegExp _sharedThemeBuilderCallRegExp = RegExp(r'\b_buildThemeData\s*\(');

final RegExp _themeModeRegExp = RegExp(r'\bthemeMode\s*:');

final RegExp _lightColorSchemeRegExp = RegExp(r'\blightColorScheme\b');
final RegExp _darkColorSchemeRegExp = RegExp(r'\bdarkColorScheme\b');

final RegExp _colorSchemeFromSeedRegExp = RegExp(
  r'\bColorScheme\.fromSeed\s*\(',
);

Future<void> main() async {
  final List<ThemeViolation> violations = <ThemeViolation>[];

  final File pubspecFile = File(ThemeContractConst.pubspecPath);
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Missing `${ThemeContractConst.pubspecPath}` file.');
    exitCode = 1;
    return;
  }

  final File appThemeFile = File(ThemeContractConst.appThemePath);
  if (!appThemeFile.existsSync()) {
    stderr.writeln('Missing `${ThemeContractConst.appThemePath}` file.');
    exitCode = 1;
    return;
  }

  final File colorSchemesFile = File(ThemeContractConst.colorSchemesPath);
  if (!colorSchemesFile.existsSync()) {
    stderr.writeln('Missing `${ThemeContractConst.colorSchemesPath}` file.');
    exitCode = 1;
    return;
  }

  final String pubspecContent = await pubspecFile.readAsString();
  final List<String> appThemeLines = await appThemeFile.readAsLines();
  final List<String> colorSchemesLines = await colorSchemesFile.readAsLines();

  final String appThemeSource = _joinWithoutLineComments(appThemeLines);
  final String colorSchemesSource = _joinWithoutLineComments(colorSchemesLines);

  _checkDynamicColorDependency(
    violations: violations,
    pubspecContent: pubspecContent,
    appThemeLines: appThemeLines,
  );

  _checkThemeFactories(violations: violations, appThemeSource: appThemeSource);

  _checkUseMaterial3InFactory(
    violations: violations,
    appThemeLines: appThemeLines,
    factoryName: 'light',
  );

  _checkUseMaterial3InFactory(
    violations: violations,
    appThemeLines: appThemeLines,
    factoryName: 'dark',
  );

  _checkColorSchemes(
    violations: violations,
    colorSchemesSource: colorSchemesSource,
  );

  _checkThemeModeInMain(
    violations: violations,
    mainFile: File(ThemeContractConst.mainPath),
  );

  if (violations.isEmpty) {
    stdout.writeln('Theme contract guard v2 passed.');
    return;
  }

  stderr.writeln('Theme contract guard v2 failed.');
  for (final ThemeViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

/// Check dynamic_color dependency.
/// - Nếu thiếu dependency, cần marker allow-no-dynamic-color trong app_theme.dart.
void _checkDynamicColorDependency({
  required List<ThemeViolation> violations,
  required String pubspecContent,
  required List<String> appThemeLines,
}) {
  final bool hasDynamicColorDependency = _dynamicColorDependencyRegExp.hasMatch(
    pubspecContent,
  );

  final bool allowNoDynamicColor = _fileContainsMarker(
    lines: appThemeLines,
    marker: ThemeContractConst.allowNoDynamicColorMarker,
  );

  if (hasDynamicColorDependency || allowNoDynamicColor) {
    return;
  }

  violations.add(
    const ThemeViolation(
      filePath: ThemeContractConst.pubspecPath,
      lineNumber: 1,
      reason:
          'Missing `dynamic_color` dependency. Add dependency or annotate explicit fallback with `theme-guard: allow-no-dynamic-color` in app_theme.dart.',
      lineContent: 'dynamic_color: ^x.y.z',
    ),
  );
}

/// Check theme factories existence: `static ThemeData light()` and `static ThemeData dark()`.
void _checkThemeFactories({
  required List<ThemeViolation> violations,
  required String appThemeSource,
}) {
  if (!_lightThemeFactoryRegExp.hasMatch(appThemeSource)) {
    violations.add(
      const ThemeViolation(
        filePath: ThemeContractConst.appThemePath,
        lineNumber: 1,
        reason:
            'Theme contract requires a light theme factory (`static ThemeData light() { ... }`).',
        lineContent: 'static ThemeData light() { ... }',
      ),
    );
  }

  if (!_darkThemeFactoryRegExp.hasMatch(appThemeSource)) {
    violations.add(
      const ThemeViolation(
        filePath: ThemeContractConst.appThemePath,
        lineNumber: 1,
        reason:
            'Theme contract requires a dark theme factory (`static ThemeData dark() { ... }`).',
        lineContent: 'static ThemeData dark() { ... }',
      ),
    );
  }
}

/// Check `useMaterial3: true` phải xuất hiện bên trong body của factory `static ThemeData <factoryName>()`.
///
/// Cách làm:
/// - Tìm dòng bắt đầu factory.
/// - Lấy block nội dung theo braces.
/// - Strip comment.
/// - Nếu không có `useMaterial3: true` → violation.
void _checkUseMaterial3InFactory({
  required List<ThemeViolation> violations,
  required List<String> appThemeLines,
  required String factoryName,
}) {
  final int startIndex = _findThemeFactoryStartIndex(
    lines: appThemeLines,
    factoryName: factoryName,
  );
  if (startIndex < 0) {
    // Nếu factory chưa tồn tại, violation đã được báo ở _checkThemeFactories.
    return;
  }

  final _BlockExtractResult block = _extractBraceBlock(
    lines: appThemeLines,
    startIndex: startIndex,
  );
  if (!block.isValid) {
    violations.add(
      ThemeViolation(
        filePath: ThemeContractConst.appThemePath,
        lineNumber: startIndex + 1,
        reason:
            'Unable to parse `$factoryName()` factory block braces. Ensure the method uses `{ ... }` braces.',
        lineContent: _safeLine(appThemeLines, startIndex),
      ),
    );
    return;
  }

  final String blockSource = _joinWithoutLineComments(block.lines);
  if (_useMaterial3RegExp.hasMatch(blockSource)) {
    return;
  }

  if (_factoryDelegatesToSharedThemeBuilder(blockSource)) {
    final String appThemeSource = _joinWithoutLineComments(appThemeLines);
    final bool hasThemeDataConstruction = _themeDataInvocationRegExp.hasMatch(
      appThemeSource,
    );
    final bool hasMaterial3 = _useMaterial3RegExp.hasMatch(appThemeSource);
    if (hasThemeDataConstruction && hasMaterial3) {
      return;
    }
  }

  violations.add(
    ThemeViolation(
      filePath: ThemeContractConst.appThemePath,
      lineNumber: startIndex + 1,
      reason:
          'Theme `$factoryName()` must enable `useMaterial3: true` inside ThemeData configuration.',
      lineContent: 'useMaterial3: true',
    ),
  );
}

bool _factoryDelegatesToSharedThemeBuilder(String blockSource) {
  return _sharedThemeBuilderCallRegExp.hasMatch(blockSource);
}

/// Check color schemes contract:
/// - must define `lightColorScheme` and `darkColorScheme`
/// - must use `ColorScheme.fromSeed(...)`
void _checkColorSchemes({
  required List<ThemeViolation> violations,
  required String colorSchemesSource,
}) {
  if (!_lightColorSchemeRegExp.hasMatch(colorSchemesSource)) {
    violations.add(
      const ThemeViolation(
        filePath: ThemeContractConst.colorSchemesPath,
        lineNumber: 1,
        reason: 'Theme contract requires `lightColorScheme` declaration.',
        lineContent: 'lightColorScheme',
      ),
    );
  }

  if (!_darkColorSchemeRegExp.hasMatch(colorSchemesSource)) {
    violations.add(
      const ThemeViolation(
        filePath: ThemeContractConst.colorSchemesPath,
        lineNumber: 1,
        reason: 'Theme contract requires `darkColorScheme` declaration.',
        lineContent: 'darkColorScheme',
      ),
    );
  }

  if (!_colorSchemeFromSeedRegExp.hasMatch(colorSchemesSource)) {
    violations.add(
      const ThemeViolation(
        filePath: ThemeContractConst.colorSchemesPath,
        lineNumber: 1,
        reason:
            'Theme contract requires `ColorScheme.fromSeed(...)` to keep palette generation consistent.',
        lineContent: 'ColorScheme.fromSeed(...)',
      ),
    );
  }
}

/// Check `themeMode:` exists in lib/main.dart (nếu file tồn tại).
void _checkThemeModeInMain({
  required List<ThemeViolation> violations,
  required File mainFile,
}) {
  if (!mainFile.existsSync()) {
    // Không bắt buộc hard fail nếu dự án chưa có main.dart theo layout khác.
    return;
  }

  final List<String> lines = mainFile.readAsLinesSync();
  final String source = _joinWithoutLineComments(lines);
  if (_themeModeRegExp.hasMatch(source)) {
    return;
  }

  violations.add(
    const ThemeViolation(
      filePath: ThemeContractConst.mainPath,
      lineNumber: 1,
      reason:
          'MaterialApp should set `themeMode:` to support light/dark switching.',
      lineContent: 'themeMode: ThemeMode.system,',
    ),
  );
}

/// Returns true if any line contains marker (không strip comment vì marker thường nằm trong comment).
bool _fileContainsMarker({
  required List<String> lines,
  required String marker,
}) {
  for (final String line in lines) {
    if (line.contains(marker)) {
      return true;
    }
  }
  return false;
}

/// Join file lines after removing line comments (`// ...`) and trimming.
/// This prevents false positives where patterns appear in comments.
String _joinWithoutLineComments(List<String> lines) {
  final StringBuffer buffer = StringBuffer();
  for (final String line in lines) {
    final String stripped = _stripLineComment(line).trimRight();
    if (stripped.isEmpty) {
      buffer.writeln();
      continue;
    }
    buffer.writeln(stripped);
  }
  return buffer.toString();
}

/// Strip single-line comment `//`.
String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    ThemeContractConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}

/// Find start line index for:
///   `static ThemeData <factoryName>() {`
int _findThemeFactoryStartIndex({
  required List<String> lines,
  required String factoryName,
}) {
  final RegExp startRegExp = RegExp(
    '\\bstatic\\s+ThemeData\\s+$factoryName\\s*\\(\\s*\\)\\s*{',
  );
  for (int i = 0; i < lines.length; i++) {
    final String line = _stripLineComment(lines[i]).trim();
    if (line.isEmpty) {
      continue;
    }
    if (startRegExp.hasMatch(line)) {
      return i;
    }
  }
  return -1;
}

/// Result of extracting a brace-delimited block from source lines.
class _BlockExtractResult {
  const _BlockExtractResult({required this.lines, required this.isValid});

  final List<String> lines;
  final bool isValid;
}

/// Extract a `{ ... }` block starting from `startIndex` line which contains the opening `{`.
/// This is a lightweight brace counter approach.
///
/// If braces can't be balanced, returns isValid=false.
_BlockExtractResult _extractBraceBlock({
  required List<String> lines,
  required int startIndex,
}) {
  final List<String> collected = <String>[];

  int braceCount = 0;
  bool started = false;

  for (int i = startIndex; i < lines.length; i++) {
    final String raw = lines[i];
    collected.add(raw);

    final String scanned = _stripLineComment(raw);
    for (int j = 0; j < scanned.length; j++) {
      final String ch = scanned[j];
      if (ch == '{') {
        braceCount++;
        started = true;
      } else if (ch == '}') {
        braceCount--;
      }
    }

    if (started && braceCount == 0) {
      return _BlockExtractResult(
        lines: List<String>.unmodifiable(collected),
        isValid: true,
      );
    }
  }

  return _BlockExtractResult(
    lines: List<String>.unmodifiable(collected),
    isValid: false,
  );
}

String _safeLine(List<String> lines, int index) {
  if (index < 0 || index >= lines.length) {
    return '';
  }
  return lines[index].trim();
}
