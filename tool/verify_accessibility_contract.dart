import 'dart:io';

/// Accessibility Contract Guard (Extended Version)
///
/// Enforces baseline accessibility + interactive element policies.
/// Intended to fail CI when accessibility contract is violated.
///
/// Enforced rules:
/// - Touch target >= 44dp
/// - At least one Semantics usage
/// - Reduce motion support
/// - Dynamic text scaling support
/// - IconButton must have tooltip
/// - No direct textScaleFactor override
/// - Interactive widgets must provide semantic affordance
class AccessibilityContractConst {
  const AccessibilityContractConst._();

  static const String libDirectory = 'lib';
  static const String commonWidgetsPrefix = 'lib/common/widgets/';
  static const String featurePrefix = 'lib/features/';
  static const String featureViewMarker = '/view/';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';
  static const double touchTargetMin = 44;

  static const String allowNoTextScaleMarker =
      'a11y-guard: allow-no-text-scaling';
}

class AccessibilityViolation {
  const AccessibilityViolation({
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

final RegExp _touchTargetRegExp = RegExp(
  r'\b(?:minWidth|minHeight|width|height)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);

final RegExp _semanticsRegExp = RegExp(r'\bSemantics\s*\(');
final RegExp _reduceMotionRegExp = RegExp(
  r'\bMediaQuery\.disableAnimationsOf\s*\(',
);
final RegExp _textScalingRegExp = RegExp(
  r'\bMediaQuery\.(?:textScalerOf|maybeTextScalerOf|textScaleFactorOf|maybeTextScaleFactorOf)\s*\(',
);

final RegExp _textScaleOverrideRegExp = RegExp(r'\btextScaleFactor\s*:');

final RegExp _iconButtonRegExp = RegExp(r'\bIconButton\s*\(');

final RegExp _interactiveWidgetRegExp = RegExp(
  r'\b(?:GestureDetector|InkWell|FloatingActionButton|ElevatedButton|TextButton|OutlinedButton)\s*\(',
);

Future<void> main() async {
  final Directory libDirectory = Directory(
    AccessibilityContractConst.libDirectory,
  );

  if (!libDirectory.existsSync()) {
    stderr.writeln('Missing lib directory.');
    exitCode = 1;
    return;
  }

  final List<File> files = _collectSourceFiles(libDirectory);
  final List<AccessibilityViolation> violations = [];

  int semanticsCount = 0;
  bool hasReduceMotionSupport = false;
  bool hasTextScaleSupport = false;
  bool allowNoTextScale = false;

  for (final file in files) {
    final String path = _normalizePath(file.path);
    final List<String> lines = await file.readAsLines();
    final bool isUiFile = _isUiFile(path);

    for (int i = 0; i < lines.length; i++) {
      final rawLine = lines[i];
      final sourceLine = _stripLineComment(rawLine).trim();

      if (sourceLine.isEmpty) continue;

      if (sourceLine.contains(
        AccessibilityContractConst.allowNoTextScaleMarker,
      )) {
        allowNoTextScale = true;
      }

      if (_semanticsRegExp.hasMatch(sourceLine)) {
        semanticsCount++;
      }

      if (_reduceMotionRegExp.hasMatch(sourceLine)) {
        hasReduceMotionSupport = true;
      }

      if (_textScalingRegExp.hasMatch(sourceLine)) {
        hasTextScaleSupport = true;
      }

      if (!isUiFile) continue;

      // ---------- Touch target rule ----------
      final matches = _touchTargetRegExp.allMatches(sourceLine);

      for (final match in matches) {
        final double? value = double.tryParse(match.group(1) ?? '');

        if (value == null) continue;
        if (value >= AccessibilityContractConst.touchTargetMin) continue;

        violations.add(
          AccessibilityViolation(
            filePath: path,
            lineNumber: i + 1,
            reason:
                'Touch target must be >= '
                '${AccessibilityContractConst.touchTargetMin.toInt()}dp.',
            lineContent: rawLine.trim(),
          ),
        );
      }

      // ---------- Text scale override rule ----------
      if (_textScaleOverrideRegExp.hasMatch(sourceLine) && !allowNoTextScale) {
        violations.add(
          AccessibilityViolation(
            filePath: path,
            lineNumber: i + 1,
            reason: 'Direct textScaleFactor override is not allowed.',
            lineContent: rawLine.trim(),
          ),
        );
      }

      // ---------- IconButton tooltip rule ----------
      if (_iconButtonRegExp.hasMatch(sourceLine) &&
          !sourceLine.contains('tooltip')) {
        violations.add(
          AccessibilityViolation(
            filePath: path,
            lineNumber: i + 1,
            reason: 'IconButton must provide a tooltip for accessibility.',
            lineContent: rawLine.trim(),
          ),
        );
      }

      // ---------- Interactive semantic rule ----------
      if (_interactiveWidgetRegExp.hasMatch(sourceLine) &&
          !sourceLine.contains('semanticLabel') &&
          !sourceLine.contains('tooltip')) {
        violations.add(
          AccessibilityViolation(
            filePath: path,
            lineNumber: i + 1,
            reason:
                'Interactive widget must provide semantic label or tooltip.',
            lineContent: rawLine.trim(),
          ),
        );
      }
    }
  }

  if (semanticsCount == 0) {
    violations.add(
      const AccessibilityViolation(
        filePath: 'lib',
        lineNumber: 1,
        reason: 'No Semantics usage detected in project.',
        lineContent: 'Semantics(...)',
      ),
    );
  }

  if (!hasReduceMotionSupport) {
    violations.add(
      const AccessibilityViolation(
        filePath: 'lib',
        lineNumber: 1,
        reason: 'Missing reduce-motion support.',
        lineContent: 'MediaQuery.disableAnimationsOf(context)',
      ),
    );
  }

  if (!hasTextScaleSupport && !allowNoTextScale) {
    violations.add(
      const AccessibilityViolation(
        filePath: 'lib',
        lineNumber: 1,
        reason: 'Missing dynamic text scaling support.',
        lineContent: 'MediaQuery.textScalerOf(context)',
      ),
    );
  }

  if (violations.isEmpty) {
    stdout.writeln('Accessibility guard passed.');
    return;
  }

  stderr.writeln('Accessibility guard failed.');
  for (final v in violations) {
    stderr.writeln(
      '${v.filePath}:${v.lineNumber}: ${v.reason} ${v.lineContent}',
    );
  }

  exitCode = 1;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = [];
  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;

    final path = _normalizePath(entity.path);

    if (!path.endsWith(AccessibilityContractConst.dartExtension)) continue;
    if (path.endsWith(AccessibilityContractConst.generatedExtension)) continue;
    if (path.endsWith(AccessibilityContractConst.freezedExtension)) continue;

    files.add(entity);
  }
  return files;
}

String _normalizePath(String path) => path.replaceAll('\\', '/');

String _stripLineComment(String line) {
  final index = line.indexOf(AccessibilityContractConst.lineCommentPrefix);
  if (index < 0) return line;
  return line.substring(0, index);
}

bool _isUiFile(String path) {
  if (path.startsWith(AccessibilityContractConst.commonWidgetsPrefix)) {
    return true;
  }
  if (!path.startsWith(AccessibilityContractConst.featurePrefix)) {
    return false;
  }
  if (!path.contains(AccessibilityContractConst.featureViewMarker)) {
    return false;
  }
  return true;
}
