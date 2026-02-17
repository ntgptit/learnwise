import 'dart:io';

class ThemeContractConst {
  const ThemeContractConst._();

  static const String pubspecPath = 'pubspec.yaml';
  static const String appThemePath = 'lib/app/theme/app_theme.dart';
  static const String colorSchemesPath = 'lib/app/theme/color_schemes.dart';

  static const String allowNoDynamicColorMarker =
      'theme-guard: allow-no-dynamic-color';
}

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
final RegExp _useMaterial3RegExp = RegExp(r'\buseMaterial3\s*:\s*true\b');
final RegExp _lightThemeFactoryRegExp = RegExp(
  r'\bstatic\s+ThemeData\s+light\s*\(',
);
final RegExp _darkThemeFactoryRegExp = RegExp(
  r'\bstatic\s+ThemeData\s+dark\s*\(',
);
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
  final String appThemeSource = await appThemeFile.readAsString();
  final String colorSchemesSource = await colorSchemesFile.readAsString();

  final bool hasDynamicColorDependency = _dynamicColorDependencyRegExp.hasMatch(
    pubspecContent,
  );
  final bool allowNoDynamicColor = appThemeSource.contains(
    ThemeContractConst.allowNoDynamicColorMarker,
  );
  if (!hasDynamicColorDependency && !allowNoDynamicColor) {
    violations.add(
      const ThemeViolation(
        filePath: ThemeContractConst.pubspecPath,
        lineNumber: 1,
        reason:
            'Missing `dynamic_color` dependency. Add dependency or annotate an explicit fallback with `theme-guard: allow-no-dynamic-color`.',
        lineContent: 'dynamic_color: ^x.y.z',
      ),
    );
  }

  final int useMaterial3Count = _useMaterial3RegExp
      .allMatches(appThemeSource)
      .length;
  if (useMaterial3Count < 2) {
    violations.add(
      const ThemeViolation(
        filePath: ThemeContractConst.appThemePath,
        lineNumber: 1,
        reason:
            'Theme must enable `useMaterial3: true` for both light and dark themes.',
        lineContent: 'useMaterial3: true',
      ),
    );
  }

  if (!_lightThemeFactoryRegExp.hasMatch(appThemeSource)) {
    violations.add(
      const ThemeViolation(
        filePath: ThemeContractConst.appThemePath,
        lineNumber: 1,
        reason:
            'Theme contract requires a light theme factory (`static ThemeData light()`).',
        lineContent: 'static ThemeData light()',
      ),
    );
  }

  if (!_darkThemeFactoryRegExp.hasMatch(appThemeSource)) {
    violations.add(
      const ThemeViolation(
        filePath: ThemeContractConst.appThemePath,
        lineNumber: 1,
        reason:
            'Theme contract requires a dark theme factory (`static ThemeData dark()`).',
        lineContent: 'static ThemeData dark()',
      ),
    );
  }

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
            'Theme contract requires `ColorScheme.fromSeed` to keep palette generation consistent.',
        lineContent: 'ColorScheme.fromSeed(...)',
      ),
    );
  }

  final File mainFile = File('lib/main.dart');
  if (mainFile.existsSync()) {
    final String mainSource = await mainFile.readAsString();
    if (!_themeModeRegExp.hasMatch(mainSource)) {
      violations.add(
        const ThemeViolation(
          filePath: 'lib/main.dart',
          lineNumber: 1,
          reason:
              'MaterialApp should set `themeMode` to support light/dark switching.',
          lineContent: 'themeMode: ...',
        ),
      );
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('Theme contract guard passed.');
    return;
  }

  stderr.writeln('Theme contract guard failed.');
  for (final ThemeViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}
