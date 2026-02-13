import 'dart:io';

class NavigationContractConst {
  const NavigationContractConst._();

  static const String libDirectory = 'lib';
  static const String pubspecPath = 'pubspec.yaml';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String commonWidgetsPrefix = 'lib/common/widgets/';
  static const String lineCommentPrefix = '//';
}

class NavigationViolation {
  const NavigationViolation({
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

final RegExp _navigatorRegExp = RegExp(r'\bNavigator\.');
final RegExp _materialPageRouteRegExp = RegExp(
  r'\bMaterialPageRoute\s*(?:<[^>]+>)?\s*\(',
);
final RegExp _onGenerateRouteRegExp = RegExp(r'\bonGenerateRoute\b');
final RegExp _goRouterImportRegExp = RegExp(
  r'''import\s+['"]package:go_router/go_router\.dart['"]''',
);
final RegExp _goRouterDependencyRegExp = RegExp(
  r'^\s*go_router\s*:',
  multiLine: true,
);

Future<void> main() async {
  final List<NavigationViolation> violations = <NavigationViolation>[];

  final File pubspecFile = File(NavigationContractConst.pubspecPath);
  if (!pubspecFile.existsSync()) {
    stderr.writeln('Missing `${NavigationContractConst.pubspecPath}` file.');
    exitCode = 1;
    return;
  }

  final String pubspecContent = await pubspecFile.readAsString();
  if (!_goRouterDependencyRegExp.hasMatch(pubspecContent)) {
    violations.add(
      const NavigationViolation(
        filePath: NavigationContractConst.pubspecPath,
        lineNumber: 1,
        reason:
            'go_router dependency is required. Add go_router to dependencies.',
        lineContent: 'go_router: ^x.y.z',
      ),
    );
  }

  final Directory libDirectory = Directory(
    NavigationContractConst.libDirectory,
  );
  if (!libDirectory.existsSync()) {
    stderr.writeln(
      'Missing `${NavigationContractConst.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<File> dartFiles = _collectSourceFiles(libDirectory);
  bool hasGoRouterImport = false;

  for (final File file in dartFiles) {
    final String normalizedPath = _normalizePath(file.path);
    final bool isCommonWidget = normalizedPath.startsWith(
      NavigationContractConst.commonWidgetsPrefix,
    );
    final List<String> lines = await file.readAsLines();

    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String sourceLine = _stripLineComment(rawLine).trim();
      if (sourceLine.isEmpty) {
        continue;
      }

      if (_goRouterImportRegExp.hasMatch(sourceLine)) {
        hasGoRouterImport = true;
      }

      if (isCommonWidget) {
        continue;
      }

      if (_navigatorRegExp.hasMatch(sourceLine)) {
        violations.add(
          NavigationViolation(
            filePath: normalizedPath,
            lineNumber: index + 1,
            reason:
                'Navigator.* is forbidden outside lib/common/widgets. Use go_router context.go/context.push.',
            lineContent: rawLine.trim(),
          ),
        );
      }

      if (_materialPageRouteRegExp.hasMatch(sourceLine)) {
        violations.add(
          NavigationViolation(
            filePath: normalizedPath,
            lineNumber: index + 1,
            reason:
                'MaterialPageRoute is forbidden. Configure routes with go_router.',
            lineContent: rawLine.trim(),
          ),
        );
      }

      if (_onGenerateRouteRegExp.hasMatch(sourceLine)) {
        violations.add(
          NavigationViolation(
            filePath: normalizedPath,
            lineNumber: index + 1,
            reason:
                'onGenerateRoute is forbidden. Configure declarative routing with go_router.',
            lineContent: rawLine.trim(),
          ),
        );
      }
    }
  }

  if (!hasGoRouterImport) {
    violations.add(
      const NavigationViolation(
        filePath: 'lib',
        lineNumber: 1,
        reason:
            'No go_router import found in source files. Add package:go_router/go_router.dart and configure routing.',
        lineContent: "import 'package:go_router/go_router.dart';",
      ),
    );
  }

  if (violations.isEmpty) {
    stdout.writeln('Navigation + go_router contract guard passed.');
    return;
  }

  stderr.writeln('Navigation + go_router contract guard failed.');
  for (final NavigationViolation violation in violations) {
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
    if (!path.endsWith(NavigationContractConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(NavigationContractConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(NavigationContractConst.freezedExtension)) {
      continue;
    }

    files.add(entity);
  }
  return files;
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    NavigationContractConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
