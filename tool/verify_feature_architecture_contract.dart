import 'dart:io';

class FeatureArchitectureGuardConst {
  const FeatureArchitectureGuardConst._();

  static const String presentationRoot = 'lib/presentation/features';
  static const String domainRoot = 'lib/domain/features';
  static const String dataRoot = 'lib/data/features';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';

  static const Set<String> ignoredFeatureNames = <String>{'features'};
}

class FeatureArchitectureViolation {
  const FeatureArchitectureViolation({
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

Future<void> main() async {
  final List<FeatureArchitectureViolation> violations =
      <FeatureArchitectureViolation>[];

  final Directory presentationRoot = Directory(
    FeatureArchitectureGuardConst.presentationRoot,
  );
  final Directory domainRoot = Directory(
    FeatureArchitectureGuardConst.domainRoot,
  );
  final Directory dataRoot = Directory(FeatureArchitectureGuardConst.dataRoot);

  if (!presentationRoot.existsSync()) {
    stderr.writeln(
      'Missing `${FeatureArchitectureGuardConst.presentationRoot}` directory.',
    );
    exitCode = 1;
    return;
  }
  if (!domainRoot.existsSync()) {
    stderr.writeln(
      'Missing `${FeatureArchitectureGuardConst.domainRoot}` directory.',
    );
    exitCode = 1;
    return;
  }
  if (!dataRoot.existsSync()) {
    stderr.writeln(
      'Missing `${FeatureArchitectureGuardConst.dataRoot}` directory.',
    );
    exitCode = 1;
    return;
  }

  final Set<String> featureNames = <String>{}
    ..addAll(_collectFeatureNames(presentationRoot))
    ..addAll(_collectFeatureNames(domainRoot))
    ..addAll(_collectFeatureNames(dataRoot));

  for (final String featureName in featureNames.toList()..sort()) {
    final String presentationDirPath =
        '${FeatureArchitectureGuardConst.presentationRoot}/$featureName';
    final String domainDirPath =
        '${FeatureArchitectureGuardConst.domainRoot}/$featureName';
    final String dataDirPath =
        '${FeatureArchitectureGuardConst.dataRoot}/$featureName';

    final Directory presentationDir = Directory(presentationDirPath);
    final Directory domainDir = Directory(domainDirPath);
    final Directory dataDir = Directory(dataDirPath);

    if (!presentationDir.existsSync()) {
      violations.add(
        FeatureArchitectureViolation(
          filePath: FeatureArchitectureGuardConst.presentationRoot,
          lineNumber: 1,
          reason: 'Feature must exist in presentation layer.',
          lineContent: presentationDirPath,
        ),
      );
      continue;
    }
    if (!domainDir.existsSync()) {
      violations.add(
        FeatureArchitectureViolation(
          filePath: FeatureArchitectureGuardConst.domainRoot,
          lineNumber: 1,
          reason: 'Feature must exist in domain layer.',
          lineContent: domainDirPath,
        ),
      );
    }
    if (!dataDir.existsSync()) {
      violations.add(
        FeatureArchitectureViolation(
          filePath: FeatureArchitectureGuardConst.dataRoot,
          lineNumber: 1,
          reason: 'Feature must exist in data layer.',
          lineContent: dataDirPath,
        ),
      );
    }

    _checkPresentationSurface(
      directory: presentationDir,
      featureName: featureName,
      violations: violations,
    );
    _checkLayerBoundaries(
      directory: domainDir,
      forbiddenImportSnippets: <String>[
        'package:learnwise/data/',
        'package:learnwise/presentation/',
        "'/data/",
        '"/data/',
        "'/presentation/",
        '"/presentation/',
      ],
      reason:
          'Domain layer must not depend on data/presentation layer imports.',
      violations: violations,
    );
    _checkLayerBoundaries(
      directory: dataDir,
      forbiddenImportSnippets: <String>[
        'package:learnwise/presentation/',
        "'/presentation/",
        '"/presentation/',
      ],
      reason: 'Data layer must not depend on presentation layer imports.',
      violations: violations,
    );
  }

  if (violations.isEmpty) {
    stdout.writeln('Feature architecture contract passed.');
    return;
  }

  stderr.writeln('Feature architecture contract failed.');
  for (final FeatureArchitectureViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

Set<String> _collectFeatureNames(Directory root) {
  final Set<String> featureNames = <String>{};
  for (final FileSystemEntity entity in root.listSync()) {
    if (entity is! Directory) {
      continue;
    }
    final String name = _basename(_normalizePath(entity.path));
    if (name.isEmpty) {
      continue;
    }
    if (FeatureArchitectureGuardConst.ignoredFeatureNames.contains(name)) {
      continue;
    }
    featureNames.add(name);
  }
  return featureNames;
}

void _checkPresentationSurface({
  required Directory directory,
  required String featureName,
  required List<FeatureArchitectureViolation> violations,
}) {
  final bool hasViewDir = Directory('${directory.path}/view').existsSync();
  final bool hasViewModelDir = Directory(
    '${directory.path}/viewmodel',
  ).existsSync();
  if (!hasViewDir && !hasViewModelDir) {
    violations.add(
      FeatureArchitectureViolation(
        filePath: _normalizePath(directory.path),
        lineNumber: 1,
        reason:
            'Presentation feature must contain at least one of `view/` or `viewmodel/`.',
        lineContent: featureName,
      ),
    );
  }

  _checkLayerBoundaries(
    directory: directory,
    forbiddenImportSnippets: <String>[
      'package:learnwise/data/features/',
      "'/data/features/",
      '"/data/features/',
    ],
    ignoredPathSnippets: <String>['/viewmodel/'],
    reason:
        'Presentation layer must not import data feature implementations directly.',
    violations: violations,
  );
}

void _checkLayerBoundaries({
  required Directory directory,
  required List<String> forbiddenImportSnippets,
  required String reason,
  required List<FeatureArchitectureViolation> violations,
  List<String> ignoredPathSnippets = const <String>[],
}) {
  if (!directory.existsSync()) {
    return;
  }

  final List<FileSystemEntity> entities = directory.listSync(recursive: true);
  for (final FileSystemEntity entity in entities) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    bool isIgnoredPath = false;
    for (final String ignoredPathSnippet in ignoredPathSnippets) {
      if (!path.contains(ignoredPathSnippet)) {
        continue;
      }
      isIgnoredPath = true;
      break;
    }
    if (isIgnoredPath) {
      continue;
    }
    if (!path.endsWith(FeatureArchitectureGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(FeatureArchitectureGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(FeatureArchitectureGuardConst.freezedExtension)) {
      continue;
    }

    final List<String> lines = entity.readAsLinesSync();
    for (int index = 0; index < lines.length; index++) {
      final String sourceLine = _stripLineComment(lines[index]).trim();
      if (!sourceLine.startsWith('import ')) {
        continue;
      }

      bool hasForbiddenImport = false;
      for (final String snippet in forbiddenImportSnippets) {
        if (!sourceLine.contains(snippet)) {
          continue;
        }
        hasForbiddenImport = true;
        break;
      }
      if (!hasForbiddenImport) {
        continue;
      }

      violations.add(
        FeatureArchitectureViolation(
          filePath: path,
          lineNumber: index + 1,
          reason: reason,
          lineContent: lines[index].trim(),
        ),
      );
    }
  }
}

String _basename(String path) {
  final List<String> segments = path.split('/');
  if (segments.isEmpty) {
    return '';
  }
  return segments.last;
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

String _stripLineComment(String line) {
  final int commentIndex = line.indexOf(
    FeatureArchitectureGuardConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return line;
  }
  return line.substring(0, commentIndex);
}
