import 'dart:io';

/// UI Constants Centralization Guard (v2)
///
/// Mục tiêu:
/// - Cấm feature-level `_ui_const.dart`
/// - Cấm magic UI number trong view layer
/// - Cấm hard-coded spacing, radius, fontSize, elevation, opacity, duration
/// - Bắt buộc sử dụng centralized tokens:
///     - AppSizes
///     - AppDurations
///     - AppOpacities
///     - AppScreenTokens
///
/// Phạm vi áp dụng:
/// - lib/common/widgets/
/// - lib/features/**/view/
///
/// Bỏ qua:
/// - .g.dart
/// - .freezed.dart
class UiConstantsGuardConst {
  const UiConstantsGuardConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';

  static const String commonWidgetsPrefix = 'lib/common/widgets/';
  static const String featurePrefix = 'lib/features/';
  static const String featureViewMarker = '/view/';
  static const String featureUiConstSuffix = '_ui_const.dart';
}

class UiGuardViolation {
  const UiGuardViolation({
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

/// EdgeInsets numeric literals
final RegExp _edgeInsetsLiteralRegExp = RegExp(
  r'\bEdgeInsets\.(?:all|symmetric|only)\([^)]*\b\d+(?:\.\d+)?\b',
);

/// Width/height numeric literal (in widget declarations)
final RegExp _widthHeightLiteralRegExp = RegExp(
  r'\b(?:width|height)\s*:\s*(?:const\s+)?\d+(?:\.\d+)?\b',
);

/// TextStyle fontSize
final RegExp _fontSizeLiteralRegExp = RegExp(
  r'\bfontSize\s*:\s*(?:const\s+)?\d+(?:\.\d+)?',
);

/// BorderRadius
final RegExp _borderRadiusLiteralRegExp = RegExp(
  r'\bBorderRadius\.circular\(\s*\d+(?:\.\d+)?\s*\)',
);

/// Radius
final RegExp _radiusLiteralRegExp = RegExp(
  r'\bRadius\.circular\(\s*\d+(?:\.\d+)?\s*\)',
);

/// Duration milliseconds
final RegExp _durationLiteralRegExp = RegExp(
  r'\bDuration\(\s*milliseconds\s*:\s*\d+\s*\)',
);

/// Elevation literal
final RegExp _elevationLiteralRegExp = RegExp(
  r'\belevation\s*:\s*(?:const\s+)?\d+(?:\.\d+)?',
);

/// Opacity literal
final RegExp _opacityLiteralRegExp = RegExp(
  r'\bopacity\s*:\s*(?:const\s+)?0?\.\d+',
);

Future<void> main() async {
  final Directory root = Directory(UiConstantsGuardConst.libDirectory);

  if (!root.existsSync()) {
    stderr.writeln(
      'Missing `${UiConstantsGuardConst.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(root);
  final List<UiGuardViolation> violations = <UiGuardViolation>[];

  for (final File file in sourceFiles) {
    final String path = _normalizePath(file.path);

    if (_isFeatureUiConstFile(path)) {
      violations.add(
        UiGuardViolation(
          filePath: path,
          lineNumber: 1,
          reason:
              'Feature-level _ui_const.dart is forbidden. Use centralized tokens.',
          lineContent: path,
        ),
      );
    }

    if (!_isUiLayerFile(path)) {
      continue;
    }

    final List<String> lines = await file.readAsLines();

    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String sourceLine = _stripLineComment(rawLine).trim();

      if (sourceLine.isEmpty) {
        continue;
      }

      if (_containsMagicUiLiteral(sourceLine)) {
        violations.add(
          UiGuardViolation(
            filePath: path,
            lineNumber: index + 1,
            reason: 'Magic UI literal detected. Use centralized design tokens.',
            lineContent: rawLine.trim(),
          ),
        );
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('UI constants guard v2 passed.');
    return;
  }

  stderr.writeln('UI constants guard v2 failed.');
  for (final UiGuardViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '${violation.reason} ${violation.lineContent}',
    );
  }

  exitCode = 1;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];

  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;

    final String path = _normalizePath(entity.path);

    if (!path.endsWith(UiConstantsGuardConst.dartExtension)) continue;
    if (path.endsWith(UiConstantsGuardConst.generatedExtension)) continue;
    if (path.endsWith(UiConstantsGuardConst.freezedExtension)) continue;

    files.add(entity);
  }

  return files;
}

bool _isFeatureUiConstFile(String path) {
  return path.startsWith(UiConstantsGuardConst.featurePrefix) &&
      path.endsWith(UiConstantsGuardConst.featureUiConstSuffix);
}

bool _isUiLayerFile(String path) {
  if (path.startsWith(UiConstantsGuardConst.commonWidgetsPrefix)) {
    return true;
  }

  if (!path.startsWith(UiConstantsGuardConst.featurePrefix)) {
    return false;
  }

  return path.contains(UiConstantsGuardConst.featureViewMarker);
}

bool _containsMagicUiLiteral(String line) {
  if (_edgeInsetsLiteralRegExp.hasMatch(line)) return true;
  if (_widthHeightLiteralRegExp.hasMatch(line)) return true;
  if (_fontSizeLiteralRegExp.hasMatch(line)) return true;
  if (_borderRadiusLiteralRegExp.hasMatch(line)) return true;
  if (_radiusLiteralRegExp.hasMatch(line)) return true;
  if (_durationLiteralRegExp.hasMatch(line)) return true;
  if (_elevationLiteralRegExp.hasMatch(line)) return true;
  if (_opacityLiteralRegExp.hasMatch(line)) return true;

  return false;
}

String _stripLineComment(String sourceLine) {
  final int index = sourceLine.indexOf(UiConstantsGuardConst.lineCommentPrefix);
  if (index < 0) return sourceLine;
  return sourceLine.substring(0, index);
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
