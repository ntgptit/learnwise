import 'dart:io';

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
  r'\b(?:minWidth|minHeight)\s*:\s*(?:const\s+)?(\d+(?:\.\d+)?)',
);
final RegExp _semanticsRegExp = RegExp(r'\bSemantics\s*\(');
final RegExp _reduceMotionRegExp = RegExp(
  r'\bMediaQuery\.disableAnimationsOf\s*\(',
);
final RegExp _textScalingRegExp = RegExp(
  r'\bMediaQuery\.(?:textScalerOf|maybeTextScalerOf|textScaleFactorOf|maybeTextScaleFactorOf)\s*\(',
);

Future<void> main() async {
  final Directory libDirectory = Directory(
    AccessibilityContractConst.libDirectory,
  );
  if (!libDirectory.existsSync()) {
    stderr.writeln(
      'Missing `${AccessibilityContractConst.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<File> files = _collectSourceFiles(libDirectory);
  final List<AccessibilityViolation> violations = <AccessibilityViolation>[];

  int semanticsCount = 0;
  bool hasReduceMotionSupport = false;
  bool hasTextScaleSupport = false;
  bool allowNoTextScale = false;

  for (final File file in files) {
    final String path = _normalizePath(file.path);
    final List<String> lines = await file.readAsLines();
    final bool isUiFile = _isUiFile(path);

    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String sourceLine = _stripLineComment(rawLine).trim();
      if (sourceLine.isEmpty) {
        continue;
      }

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

      if (!isUiFile) {
        continue;
      }

      final Iterable<RegExpMatch> matches = _touchTargetRegExp.allMatches(
        sourceLine,
      );
      for (final RegExpMatch match in matches) {
        final double? value = double.tryParse(match.group(1) ?? '');
        if (value == null) {
          continue;
        }
        if (value >= AccessibilityContractConst.touchTargetMin) {
          continue;
        }
        violations.add(
          AccessibilityViolation(
            filePath: path,
            lineNumber: index + 1,
            reason:
                'Touch target must be at least ${AccessibilityContractConst.touchTargetMin.toInt()}dp.',
            lineContent: rawLine.trim(),
          ),
        );
      }
    }
  }

  if (semanticsCount == 0) {
    violations.add(
      const AccessibilityViolation(
        filePath: AccessibilityContractConst.commonWidgetsPrefix,
        lineNumber: 1,
        reason:
            'No `Semantics` usage detected. Provide semantic labels/hints for accessible navigation.',
        lineContent: 'Semantics(...)',
      ),
    );
  }

  if (!hasReduceMotionSupport) {
    violations.add(
      const AccessibilityViolation(
        filePath: AccessibilityContractConst.libDirectory,
        lineNumber: 1,
        reason:
            'Missing reduce-motion support. Respect `MediaQuery.disableAnimationsOf(context)` for motion-sensitive users.',
        lineContent: 'MediaQuery.disableAnimationsOf(context)',
      ),
    );
  }

  if (!hasTextScaleSupport && !allowNoTextScale) {
    violations.add(
      const AccessibilityViolation(
        filePath: AccessibilityContractConst.libDirectory,
        lineNumber: 1,
        reason:
            'Missing dynamic text scaling support. Use MediaQuery text scaler APIs or add `a11y-guard: allow-no-text-scaling` with justification.',
        lineContent: 'MediaQuery.textScalerOf(context)',
      ),
    );
  }

  if (violations.isEmpty) {
    stdout.writeln('Accessibility contract guard passed.');
    return;
  }

  stderr.writeln('Accessibility contract guard failed.');
  for (final AccessibilityViolation violation in violations) {
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

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(AccessibilityContractConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(AccessibilityContractConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(AccessibilityContractConst.freezedExtension)) {
      continue;
    }
    files.add(entity);
  }
  return files;
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    AccessibilityContractConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
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
