import 'dart:io';

class RiverpodDiGuardConst {
  const RiverpodDiGuardConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';
  static const String providerGenericPattern = r'\bProvider\s*<';
  static const String providerFactoryPattern = r'\bProvider\s*\(';
}

class Violation {
  const Violation({
    required this.filePath,
    required this.lineNumber,
    required this.lineContent,
  });

  final String filePath;
  final int lineNumber;
  final String lineContent;
}

final RegExp _providerGenericRegExp = RegExp(
  RiverpodDiGuardConst.providerGenericPattern,
);
final RegExp _providerFactoryRegExp = RegExp(
  RiverpodDiGuardConst.providerFactoryPattern,
);

Future<void> main() async {
  final Directory libDir = Directory(RiverpodDiGuardConst.libDirectory);
  if (!libDir.existsSync()) {
    stderr.writeln('Missing `${RiverpodDiGuardConst.libDirectory}` directory.');
    exitCode = 1;
    return;
  }

  final List<File> dartFiles = _collectSourceFiles(libDir);
  final List<Violation> violations = <Violation>[];

  for (final File file in dartFiles) {
    final List<String> lines = await file.readAsLines();
    for (int index = 0; index < lines.length; index++) {
      final String sourceLine = _stripLineComment(lines[index]).trim();
      if (sourceLine.isEmpty) {
        continue;
      }

      if (_containsManualProvider(sourceLine)) {
        violations.add(
          Violation(
            filePath: file.path.replaceAll('\\', '/'),
            lineNumber: index + 1,
            lineContent: lines[index].trim(),
          ),
        );
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('Riverpod DI guard passed: no manual Provider usage found.');
    return;
  }

  stderr.writeln('Riverpod DI guard failed.');
  stderr.writeln(
    'Use @riverpod/@Riverpod annotations instead of manual Provider(...) declarations.',
  );
  for (final Violation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  final List<FileSystemEntity> entities = root.listSync(recursive: true);
  for (final FileSystemEntity entity in entities) {
    if (entity is! File) {
      continue;
    }

    final String filePath = entity.path;
    if (!filePath.endsWith(RiverpodDiGuardConst.dartExtension)) {
      continue;
    }
    if (filePath.endsWith(RiverpodDiGuardConst.generatedExtension)) {
      continue;
    }
    if (filePath.endsWith(RiverpodDiGuardConst.freezedExtension)) {
      continue;
    }

    files.add(entity);
  }
  return files;
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    RiverpodDiGuardConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}

bool _containsManualProvider(String line) {
  if (_providerGenericRegExp.hasMatch(line)) {
    return true;
  }
  if (_providerFactoryRegExp.hasMatch(line)) {
    return true;
  }
  return false;
}
