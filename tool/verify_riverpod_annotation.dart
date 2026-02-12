import 'dart:io';

class RiverpodDiGuardConst {
  const RiverpodDiGuardConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';
  static const String refMountedPattern = r'\bref\.mounted\b';
  static const String mountedPattern = r'\bmounted\b';
  static const List<String> manualProviderTypes = <String>[
    'Provider',
    'StateProvider',
    'StateNotifierProvider',
    'ChangeNotifierProvider',
    'FutureProvider',
    'StreamProvider',
    'NotifierProvider',
    'AsyncNotifierProvider',
    'AutoDisposeProvider',
    'AutoDisposeStateProvider',
    'AutoDisposeStateNotifierProvider',
    'AutoDisposeChangeNotifierProvider',
    'AutoDisposeFutureProvider',
    'AutoDisposeStreamProvider',
    'AutoDisposeNotifierProvider',
    'AutoDisposeAsyncNotifierProvider',
  ];
}

class Violation {
  const Violation({
    required this.filePath,
    required this.lineNumber,
    required this.lineContent,
    required this.reason,
  });

  final String filePath;
  final int lineNumber;
  final String lineContent;
  final String reason;
}

final List<RegExp> _manualProviderRegExps = _buildManualProviderPatterns();
final RegExp _refMountedRegExp = RegExp(RiverpodDiGuardConst.refMountedPattern);
final RegExp _mountedRegExp = RegExp(RiverpodDiGuardConst.mountedPattern);

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
            reason: 'Manual provider declaration is forbidden.',
          ),
        );
      }

      if (_containsManualMounted(sourceLine)) {
        violations.add(
          Violation(
            filePath: file.path.replaceAll('\\', '/'),
            lineNumber: index + 1,
            lineContent: lines[index].trim(),
            reason:
                'Manual mounted check is forbidden. Use Riverpod lifecycle (`ref.mounted`) or redesign flow.',
          ),
        );
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln(
      'Riverpod DI guard passed: no manual provider or mounted usage found.',
    );
    return;
  }

  stderr.writeln('Riverpod DI guard failed.');
  stderr.writeln(
    'Use @riverpod/@Riverpod annotations and avoid manual mounted checks.',
  );
  for (final Violation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
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
  for (final RegExp regExp in _manualProviderRegExps) {
    if (regExp.hasMatch(line)) {
      return true;
    }
  }
  return false;
}

bool _containsManualMounted(String line) {
  if (!_mountedRegExp.hasMatch(line)) {
    return false;
  }
  if (_refMountedRegExp.hasMatch(line)) {
    return false;
  }
  return true;
}

List<RegExp> _buildManualProviderPatterns() {
  final List<RegExp> patterns = <RegExp>[];
  for (final String providerType in RiverpodDiGuardConst.manualProviderTypes) {
    patterns.add(RegExp('\\b$providerType\\s*<'));
    patterns.add(
      RegExp('\\b$providerType\\s*(?:\\.[A-Za-z_][A-Za-z0-9_]*)?\\s*\\('),
    );
  }
  return patterns;
}
