import 'dart:io';

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

  static const String spacingImportMarker = 'styles/spacing.dart';
  static const String radiusImportMarker = 'styles/radius.dart';
  static const String featureUiConstImportMarker = '_ui_const.dart';
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

final RegExp _stylePropertyNumericRegExp = RegExp(
  r'\b(?:horizontal|vertical|padding|margin|spacing|runSpacing|width|height|radius|fontSize|strokeWidth|top|left|right|bottom)\s*:\s*(?:const\s+)?\d+(?:\.\d+)?\b',
);
final RegExp _borderRadiusLiteralRegExp = RegExp(
  r'\bBorderRadius\.circular\(\s*\d+(?:\.\d+)?\s*\)',
);
final RegExp _radiusLiteralRegExp = RegExp(
  r'\bRadius\.circular\(\s*\d+(?:\.\d+)?\s*\)',
);
final RegExp _sizeFromHeightLiteralRegExp = RegExp(
  r'\bSize\.fromHeight\(\s*\d+(?:\.\d+)?\s*\)',
);
final RegExp _durationMillisecondsLiteralRegExp = RegExp(
  r'\bDuration\(\s*milliseconds\s*:\s*\d+\s*\)',
);

Future<void> main() async {
  final Directory libDir = Directory(UiConstantsGuardConst.libDirectory);
  if (!libDir.existsSync()) {
    stderr.writeln(
      'Missing `${UiConstantsGuardConst.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(libDir);
  final List<UiGuardViolation> violations = <UiGuardViolation>[];

  for (final File file in sourceFiles) {
    final String normalizedPath = file.path.replaceAll('\\', '/');
    final bool isFeatureUiConstFile = _isFeatureUiConstFile(normalizedPath);
    if (isFeatureUiConstFile) {
      violations.add(
        UiGuardViolation(
          filePath: normalizedPath,
          lineNumber: 1,
          reason:
              'Feature-level UI const file is forbidden. Use centralized constants in lib/common/styles/.',
          lineContent: normalizedPath,
        ),
      );
    }

    final List<String> lines = await file.readAsLines();
    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String sourceLine = _stripLineComment(rawLine).trim();
      if (sourceLine.isEmpty) {
        continue;
      }

      final bool isBannedImport = _containsBannedImport(sourceLine);
      if (isBannedImport) {
        violations.add(
          UiGuardViolation(
            filePath: normalizedPath,
            lineNumber: index + 1,
            reason:
                'Forbidden style import detected. Use centralized constants directly from lib/common/styles/.',
            lineContent: rawLine.trim(),
          ),
        );
      }

      final bool isUiFile = _isUiLayerFile(normalizedPath);
      if (!isUiFile) {
        continue;
      }

      final bool hasMagicUiNumber = _containsMagicUiNumber(sourceLine);
      if (!hasMagicUiNumber) {
        continue;
      }

      violations.add(
        UiGuardViolation(
          filePath: normalizedPath,
          lineNumber: index + 1,
          reason:
              'Magic UI numeric value detected. Replace with centralized constants (AppSizes/AppDurations/AppOpacities/AppScreenTokens).',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }

  if (violations.isEmpty) {
    stdout.writeln(
      'UI constants centralization guard passed: no feature UI const files or magic UI literals found.',
    );
    return;
  }

  stderr.writeln('UI constants centralization guard failed.');
  for (final UiGuardViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final String normalizedPath = entity.path.replaceAll('\\', '/');
    if (!normalizedPath.endsWith(UiConstantsGuardConst.dartExtension)) {
      continue;
    }
    if (normalizedPath.endsWith(UiConstantsGuardConst.generatedExtension)) {
      continue;
    }
    if (normalizedPath.endsWith(UiConstantsGuardConst.freezedExtension)) {
      continue;
    }

    files.add(entity);
  }
  return files;
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    UiConstantsGuardConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}

bool _isFeatureUiConstFile(String path) {
  if (!path.startsWith(UiConstantsGuardConst.featurePrefix)) {
    return false;
  }
  if (!path.endsWith(UiConstantsGuardConst.featureUiConstSuffix)) {
    return false;
  }
  return true;
}

bool _containsBannedImport(String sourceLine) {
  if (!sourceLine.startsWith('import ')) {
    return false;
  }
  if (sourceLine.contains(UiConstantsGuardConst.spacingImportMarker)) {
    return true;
  }
  if (sourceLine.contains(UiConstantsGuardConst.radiusImportMarker)) {
    return true;
  }
  if (sourceLine.contains(UiConstantsGuardConst.featureUiConstImportMarker)) {
    return true;
  }
  return false;
}

bool _isUiLayerFile(String path) {
  if (path.startsWith(UiConstantsGuardConst.commonWidgetsPrefix)) {
    return true;
  }
  if (!path.startsWith(UiConstantsGuardConst.featurePrefix)) {
    return false;
  }
  if (!path.contains(UiConstantsGuardConst.featureViewMarker)) {
    return false;
  }
  return true;
}

bool _containsMagicUiNumber(String sourceLine) {
  if (_stylePropertyNumericRegExp.hasMatch(sourceLine)) {
    return true;
  }
  if (_borderRadiusLiteralRegExp.hasMatch(sourceLine)) {
    return true;
  }
  if (_radiusLiteralRegExp.hasMatch(sourceLine)) {
    return true;
  }
  if (_sizeFromHeightLiteralRegExp.hasMatch(sourceLine)) {
    return true;
  }
  if (_durationMillisecondsLiteralRegExp.hasMatch(sourceLine)) {
    return true;
  }
  return false;
}
