import 'dart:io';

class SharedWidgetsM3CoverageConst {
  const SharedWidgetsM3CoverageConst._();

  static const String sharedWidgetsRoot = 'lib/presentation/shared/widgets';
  static const String manifestPath =
      'tool/contracts/shared_widgets_m3_manifest.txt';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';
}

class SharedWidgetsM3CoverageViolation {
  const SharedWidgetsM3CoverageViolation({
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

final RegExp _legacyWidgetRegExp = RegExp(
  r'\b(?:ElevatedButton|BottomNavigationBar|ToggleButtons)\s*\(',
);
final RegExp _hardcodedColorConstructorRegExp = RegExp(
  r'\bColor\(\s*0x[0-9A-Fa-f]+\s*\)',
);
final RegExp _hardcodedHexColorRegExp = RegExp(r'#[0-9A-Fa-f]{3,8}');
final RegExp _withOpacityRegExp = RegExp(r'\.withOpacity\s*\(');
final RegExp _materialColorRegExp = RegExp(r'\bColors\.([A-Za-z_]\w*)');

const Set<String> _allowedMaterialColors = <String>{'transparent'};

Future<void> main() async {
  final Directory widgetsRoot = Directory(
    SharedWidgetsM3CoverageConst.sharedWidgetsRoot,
  );
  if (!widgetsRoot.existsSync()) {
    stderr.writeln(
      'Missing `${SharedWidgetsM3CoverageConst.sharedWidgetsRoot}` directory.',
    );
    exitCode = 1;
    return;
  }

  final File manifestFile = File(SharedWidgetsM3CoverageConst.manifestPath);
  if (!manifestFile.existsSync()) {
    stderr.writeln(
      'Missing `${SharedWidgetsM3CoverageConst.manifestPath}` manifest.',
    );
    exitCode = 1;
    return;
  }

  final Set<String> actualFiles = _collectDartFiles(root: widgetsRoot);
  if (actualFiles.isEmpty) {
    stderr.writeln('No shared widget Dart files found to audit.');
    exitCode = 1;
    return;
  }

  final Set<String> manifestFiles = await _readManifest(file: manifestFile);

  final Set<String> missingFromManifest = actualFiles.difference(manifestFiles);
  final Set<String> staleManifestEntries = manifestFiles.difference(
    actualFiles,
  );

  final List<SharedWidgetsM3CoverageViolation> violations =
      <SharedWidgetsM3CoverageViolation>[];
  _appendManifestViolations(
    violations: violations,
    missingFromManifest: missingFromManifest,
    staleManifestEntries: staleManifestEntries,
  );

  final List<String> sortedFiles = actualFiles.toList()..sort();
  for (final String path in sortedFiles) {
    final List<String> lines = await File(path).readAsLines();
    _checkFile(path: path, lines: lines, violations: violations);
  }

  if (violations.isEmpty) {
    stdout.writeln(
      'Shared widgets M3 coverage contract passed '
      '(${actualFiles.length} file(s) audited).',
    );
    return;
  }

  stderr.writeln('Shared widgets M3 coverage contract failed.');
  for (final SharedWidgetsM3CoverageViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

Set<String> _collectDartFiles({required Directory root}) {
  final Set<String> files = <String>{};
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final String normalizedPath = _normalizePath(entity.path);
    if (!normalizedPath.endsWith(SharedWidgetsM3CoverageConst.dartExtension)) {
      continue;
    }
    if (normalizedPath.endsWith(
      SharedWidgetsM3CoverageConst.generatedExtension,
    )) {
      continue;
    }
    if (normalizedPath.endsWith(
      SharedWidgetsM3CoverageConst.freezedExtension,
    )) {
      continue;
    }
    files.add(normalizedPath);
  }
  return files;
}

Future<Set<String>> _readManifest({required File file}) async {
  final List<String> lines = await file.readAsLines();
  final Set<String> entries = <String>{};
  for (final String rawLine in lines) {
    final String trimmed = rawLine.trim();
    if (trimmed.isEmpty) {
      continue;
    }
    if (trimmed.startsWith('#')) {
      continue;
    }
    entries.add(_normalizePath(trimmed));
  }
  return entries;
}

void _appendManifestViolations({
  required List<SharedWidgetsM3CoverageViolation> violations,
  required Set<String> missingFromManifest,
  required Set<String> staleManifestEntries,
}) {
  final List<String> missing = missingFromManifest.toList()..sort();
  for (final String path in missing) {
    violations.add(
      SharedWidgetsM3CoverageViolation(
        filePath: SharedWidgetsM3CoverageConst.manifestPath,
        lineNumber: 1,
        reason:
            'Missing manifest entry for shared widget file. '
            'Add it to shared_widgets_m3_manifest.txt.',
        lineContent: path,
      ),
    );
  }

  final List<String> stale = staleManifestEntries.toList()..sort();
  for (final String path in stale) {
    violations.add(
      SharedWidgetsM3CoverageViolation(
        filePath: SharedWidgetsM3CoverageConst.manifestPath,
        lineNumber: 1,
        reason:
            'Stale manifest entry without corresponding file. '
            'Remove it from shared_widgets_m3_manifest.txt.',
        lineContent: path,
      ),
    );
  }
}

void _checkFile({
  required String path,
  required List<String> lines,
  required List<SharedWidgetsM3CoverageViolation> violations,
}) {
  for (int index = 0; index < lines.length; index++) {
    final int lineNumber = index + 1;
    final String rawLine = lines[index];
    final String sourceLine = _stripLineComment(rawLine).trim();
    if (sourceLine.isEmpty) {
      continue;
    }

    if (_legacyWidgetRegExp.hasMatch(sourceLine)) {
      violations.add(
        SharedWidgetsM3CoverageViolation(
          filePath: path,
          lineNumber: lineNumber,
          reason:
              'Legacy Material widget is not allowed in shared widgets. '
              'Use M3 component alternatives.',
          lineContent: rawLine.trim(),
        ),
      );
    }

    if (_withOpacityRegExp.hasMatch(sourceLine)) {
      violations.add(
        SharedWidgetsM3CoverageViolation(
          filePath: path,
          lineNumber: lineNumber,
          reason:
              'Use `.withValues(alpha: ...)` with centralized opacity tokens.',
          lineContent: rawLine.trim(),
        ),
      );
    }

    if (_hardcodedColorConstructorRegExp.hasMatch(sourceLine)) {
      violations.add(
        SharedWidgetsM3CoverageViolation(
          filePath: path,
          lineNumber: lineNumber,
          reason:
              'Hardcoded color is not allowed in shared widgets. '
              'Use Theme color roles or centralized theme constants.',
          lineContent: rawLine.trim(),
        ),
      );
    }

    if (_hardcodedHexColorRegExp.hasMatch(sourceLine)) {
      violations.add(
        SharedWidgetsM3CoverageViolation(
          filePath: path,
          lineNumber: lineNumber,
          reason:
              'Hex color literal is not allowed in shared widgets. '
              'Use Theme color roles or centralized theme constants.',
          lineContent: rawLine.trim(),
        ),
      );
    }

    final Iterable<RegExpMatch> materialColorMatches = _materialColorRegExp
        .allMatches(sourceLine);
    for (final RegExpMatch match in materialColorMatches) {
      final String colorName = match.group(1) ?? '';
      if (_allowedMaterialColors.contains(colorName)) {
        continue;
      }
      violations.add(
        SharedWidgetsM3CoverageViolation(
          filePath: path,
          lineNumber: lineNumber,
          reason:
              'Direct `Colors.*` usage is not allowed in shared widgets. '
              'Use Theme color roles.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    SharedWidgetsM3CoverageConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}
