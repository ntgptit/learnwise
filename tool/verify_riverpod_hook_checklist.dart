import 'dart:io';

/// Riverpod Hook checklist guard (ratchet mode).
///
/// Purpose:
/// - Apply riverpod_hook_checklist.md rules at project scale without breaking
///   legacy code immediately.
/// - Block new violations while allowing existing ones through a baseline file.
///
/// Usage:
/// - Check mode (CI): `dart run tool/verify_riverpod_hook_checklist.dart`
/// - Refresh baseline: `dart run tool/verify_riverpod_hook_checklist.dart --update-baseline`
class RiverpodHookChecklistConst {
  const RiverpodHookChecklistConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String baselinePath = 'tool/riverpod_hook_checklist_baseline.txt';
  static const String lineCommentPrefix = '//';
  static const String viewFolderMarker = '/view/';

  static const List<String> ignorePathContains = <String>[
    '/l10n/',
    '/generated/',
    '/gen/',
  ];

  static const String ruleConsumerStatefulWidget = 'RHC001';
  static const String ruleConsumerStateClass = 'RHC002';
  static const String ruleScreenConsumerWidget = 'RHC003';
  static const String ruleScreenStatefulWidget = 'RHC004';
  static const String ruleRepositoryProviderInView = 'RHC005';
  static const String ruleServiceProviderInView = 'RHC006';
  static const String ruleRepositoryInstantiationInView = 'RHC007';
  static const String ruleServiceInstantiationInView = 'RHC008';
}

class RiverpodHookChecklistViolation {
  const RiverpodHookChecklistViolation({
    required this.ruleId,
    required this.filePath,
    required this.lineNumber,
    required this.reason,
    required this.lineContent,
  });

  final String ruleId;
  final String filePath;
  final int lineNumber;
  final String reason;
  final String lineContent;

  String get baselineKey => '$ruleId|$filePath|${lineContent.trim()}';
}

final RegExp _consumerStatefulWidgetRegExp = RegExp(
  r'\bextends\s+ConsumerStatefulWidget\b',
);
final RegExp _consumerStateClassRegExp = RegExp(r'\bextends\s+ConsumerState<');
final RegExp _screenConsumerWidgetRegExp = RegExp(
  r'\bclass\s+\w*Screen\b[^{;=]*\bextends\s+ConsumerWidget\b',
);
final RegExp _screenStatefulWidgetRegExp = RegExp(
  r'\bclass\s+\w*Screen\b[^{;=]*\bextends\s+StatefulWidget\b',
);
final RegExp _repositoryProviderReadRegExp = RegExp(
  r'\bref\.read\(\s*\w*RepositoryProvider(?:\.notifier)?\s*\)',
);
final RegExp _serviceProviderReadRegExp = RegExp(
  r'\bref\.read\(\s*\w*ServiceProvider(?:\.notifier)?\s*\)',
);
final RegExp _repositoryInstantiationRegExp = RegExp(
  r'=\s*(?:const\s+)?\w*Repository\s*\(',
);
final RegExp _serviceInstantiationRegExp = RegExp(
  r'=\s*(?:const\s+)?\w*Service\s*\(',
);

Future<void> main(List<String> args) async {
  final bool updateBaseline = args.contains('--update-baseline');

  final Directory libDirectory = Directory(RiverpodHookChecklistConst.libDirectory);
  if (!libDirectory.existsSync()) {
    stderr.writeln('Missing `${RiverpodHookChecklistConst.libDirectory}` directory.');
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(libDirectory);
  final List<RiverpodHookChecklistViolation> violations = <RiverpodHookChecklistViolation>[];

  for (final File sourceFile in sourceFiles) {
    final String path = _normalizePath(sourceFile.path);
    if (_shouldIgnorePath(path)) {
      continue;
    }

    final List<String> lines = await sourceFile.readAsLines();
    final bool isViewFile = path.contains(RiverpodHookChecklistConst.viewFolderMarker);

    for (int i = 0; i < lines.length; i++) {
      final String rawLine = lines[i];
      final String line = _stripLineComment(rawLine).trim();
      if (line.isEmpty) {
        continue;
      }

      _collectConsumerWidgetViolations(
        path: path,
        line: line,
        rawLine: rawLine,
        lineNumber: i + 1,
        violations: violations,
      );

      if (!isViewFile) {
        continue;
      }

      _collectViewLayerViolations(
        path: path,
        line: line,
        rawLine: rawLine,
        lineNumber: i + 1,
        violations: violations,
      );
    }
  }

  final File baselineFile = File(RiverpodHookChecklistConst.baselinePath);
  final Set<String> currentKeys = violations.map((v) => v.baselineKey).toSet();

  if (updateBaseline) {
    await _writeBaseline(file: baselineFile, keys: currentKeys);
    stdout.writeln(
      'Riverpod hook checklist baseline updated (${currentKeys.length} entries).',
    );
    return;
  }

  final Set<String> baselineKeys = await _readBaseline(baselineFile);
  final List<RiverpodHookChecklistViolation> activeViolations = violations.where((
    violation,
  ) {
    return !baselineKeys.contains(violation.baselineKey);
  }).toList();

  final Set<String> staleBaselineEntries = baselineKeys.difference(currentKeys);

  if (activeViolations.isEmpty) {
    stdout.writeln('Riverpod hook checklist guard passed.');
    if (staleBaselineEntries.isNotEmpty) {
      stdout.writeln(
        'Stale baseline entries detected (${staleBaselineEntries.length}). '
        'Consider refreshing `${RiverpodHookChecklistConst.baselinePath}`.',
      );
    }
    return;
  }

  stderr.writeln('Riverpod hook checklist guard failed.');
  for (final RiverpodHookChecklistViolation violation in activeViolations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '[${violation.ruleId}] ${violation.reason} ${violation.lineContent.trim()}',
    );
  }
  exitCode = 1;
}

void _collectConsumerWidgetViolations({
  required String path,
  required String line,
  required String rawLine,
  required int lineNumber,
  required List<RiverpodHookChecklistViolation> violations,
}) {
  if (_consumerStatefulWidgetRegExp.hasMatch(line)) {
    violations.add(
      RiverpodHookChecklistViolation(
        ruleId: RiverpodHookChecklistConst.ruleConsumerStatefulWidget,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'ConsumerStatefulWidget is discouraged by checklist. Prefer HookConsumerWidget.',
        lineContent: rawLine,
      ),
    );
  }

  if (_consumerStateClassRegExp.hasMatch(line)) {
    violations.add(
      RiverpodHookChecklistViolation(
        ruleId: RiverpodHookChecklistConst.ruleConsumerStateClass,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'ConsumerState is discouraged by checklist. Prefer hook-based screen composition.',
        lineContent: rawLine,
      ),
    );
  }

  if (_screenConsumerWidgetRegExp.hasMatch(line)) {
    violations.add(
      RiverpodHookChecklistViolation(
        ruleId: RiverpodHookChecklistConst.ruleScreenConsumerWidget,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Screen-level ConsumerWidget should migrate to HookConsumerWidget.',
        lineContent: rawLine,
      ),
    );
  }

  if (_screenStatefulWidgetRegExp.hasMatch(line)) {
    violations.add(
      RiverpodHookChecklistViolation(
        ruleId: RiverpodHookChecklistConst.ruleScreenStatefulWidget,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Screen-level StatefulWidget should migrate to HookConsumerWidget + hooks.',
        lineContent: rawLine,
      ),
    );
  }
}

void _collectViewLayerViolations({
  required String path,
  required String line,
  required String rawLine,
  required int lineNumber,
  required List<RiverpodHookChecklistViolation> violations,
}) {
  if (_repositoryProviderReadRegExp.hasMatch(line)) {
    violations.add(
      RiverpodHookChecklistViolation(
        ruleId: RiverpodHookChecklistConst.ruleRepositoryProviderInView,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'View layer must not read repository provider directly. Use ViewModel actions/state.',
        lineContent: rawLine,
      ),
    );
  }

  if (_serviceProviderReadRegExp.hasMatch(line)) {
    violations.add(
      RiverpodHookChecklistViolation(
        ruleId: RiverpodHookChecklistConst.ruleServiceProviderInView,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'View layer must not read service provider directly. Route through ViewModel.',
        lineContent: rawLine,
      ),
    );
  }

  if (_repositoryInstantiationRegExp.hasMatch(line)) {
    violations.add(
      RiverpodHookChecklistViolation(
        ruleId: RiverpodHookChecklistConst.ruleRepositoryInstantiationInView,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Repository instantiation in view layer is forbidden. Use provider DI.',
        lineContent: rawLine,
      ),
    );
  }

  if (_serviceInstantiationRegExp.hasMatch(line)) {
    violations.add(
      RiverpodHookChecklistViolation(
        ruleId: RiverpodHookChecklistConst.ruleServiceInstantiationInView,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Service instantiation in view layer is forbidden. Use provider DI.',
        lineContent: rawLine,
      ),
    );
  }
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> sourceFiles = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(RiverpodHookChecklistConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(RiverpodHookChecklistConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(RiverpodHookChecklistConst.freezedExtension)) {
      continue;
    }
    sourceFiles.add(entity);
  }
  return sourceFiles;
}

bool _shouldIgnorePath(String path) {
  for (final String needle in RiverpodHookChecklistConst.ignorePathContains) {
    if (path.contains(needle)) {
      return true;
    }
  }
  return false;
}

Future<Set<String>> _readBaseline(File file) async {
  if (!file.existsSync()) {
    return <String>{};
  }

  final List<String> lines = await file.readAsLines();
  final Set<String> entries = <String>{};
  for (final String line in lines) {
    final String trimmed = line.trim();
    if (trimmed.isEmpty || trimmed.startsWith('#')) {
      continue;
    }
    entries.add(trimmed);
  }
  return entries;
}

Future<void> _writeBaseline({
  required File file,
  required Set<String> keys,
}) async {
  final List<String> sortedKeys = keys.toList()..sort();
  final String content = <String>[
    '# Riverpod hook checklist baseline',
    '# Auto-generated by: dart run tool/verify_riverpod_hook_checklist.dart --update-baseline',
    ...sortedKeys,
  ].join('\n');
  await file.writeAsString('$content\n');
}

String _stripLineComment(String line) {
  final int index = line.indexOf(RiverpodHookChecklistConst.lineCommentPrefix);
  if (index < 0) {
    return line;
  }
  return line.substring(0, index);
}

String _normalizePath(String path) => path.replaceAll('\\', '/');
