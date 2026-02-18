import 'dart:io';

/// Riverpod DI contract guard (v2).
///
/// Goals:
/// 1) Enforce using Riverpod annotations (@riverpod / @Riverpod) instead of
///    manual provider declarations (Provider/StateProvider/...).
/// 2) Forbid `mounted` checks inside Riverpod notifier files (because the right
///    check is `ref.mounted`).
/// 3) Avoid false positives:
///    - Allow `mounted` usage in Flutter `State` classes.
///    - Ignore generated files (*.g.dart, *.freezed.dart).
///    - Ignore comment-only matches and `import` lines.
/// 4) Provide strict mode:
///    - Strict: require annotation in /viewmodel/, /service/, /repository/
///      when Riverpod types are used.
///
/// Notes:
/// - This guard is regex-based for speed and simplicity.
/// - If you later want 0 false positives, switch to analyzer AST.
class RiverpodDiGuardConstV2 {
  const RiverpodDiGuardConstV2._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';

  static const List<String> scopedDirs = <String>[
    '/viewmodel/',
    '/service/',
    '/repository/',
  ];

  static const List<String> ignorePathContains = <String>[
    '/l10n/',
    '/generated/',
    '/gen/',
  ];

  /// Provider types that must NOT appear as manual declarations.
  static const List<String> forbiddenManualProviderTypes = <String>[
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

  /// Legacy classes we don't want in a Riverpod-annotation-first codebase.
  static const List<String> forbiddenLegacyNotifierBases = <String>[
    'StateNotifier',
    'ChangeNotifier',
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

final RegExp _riverpodAnnotationRegExp = RegExp(
  r'^\s*@(?:riverpod|Riverpod)\b',
);
final RegExp _riverpodGeneratedPartRegExp = RegExp(
  r"^\s*part\s+'[^']+\.g\.dart'\s*;",
);
final RegExp _mountedWordRegExp = RegExp(r'\bmounted\b');
final RegExp _refMountedRegExp = RegExp(r'\bref\.mounted\b');
final RegExp _flutterStateClassRegExp = RegExp(
  r'\bclass\s+\w+\s+extends\s+State<',
);
final RegExp _riverpodNotifierClassRegExp = RegExp(
  r'\bclass\s+\w+\s+extends\s+_\$\w+',
);

final List<RegExp> _manualProviderDeclRegExps =
    _buildManualProviderDeclPatterns();
final List<RegExp> _legacyNotifierRegExps = _buildLegacyNotifierPatterns();

Future<void> main(List<String> args) async {
  final bool strict = args.contains('--strict');

  final Directory libDir = Directory(RiverpodDiGuardConstV2.libDirectory);
  if (!libDir.existsSync()) {
    stderr.writeln(
      'Missing `${RiverpodDiGuardConstV2.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<File> dartFiles = _collectSourceFiles(libDir);
  final List<Violation> violations = <Violation>[];

  for (final File file in dartFiles) {
    final String path = _normalizePath(file.path);

    if (_shouldIgnorePath(path)) {
      continue;
    }

    final List<String> lines = await file.readAsLines();

    final _FileSignals signals = _scanFileSignals(lines: lines);

    // Rule A: Forbid manual provider declarations (anywhere in lib).
    // But ignore pure import/export/part lines to reduce noise.
    _checkManualProviders(path: path, lines: lines, violations: violations);

    // Rule B: Forbid legacy notifier bases (StateNotifier/ChangeNotifier)
    // inside scoped logic folders.
    _checkLegacyNotifierBases(path: path, lines: lines, violations: violations);

    // Rule C: Forbid `mounted` inside Riverpod notifier/annotation files.
    // Allow `mounted` in Flutter `State` classes.
    _checkMountedInRiverpodFiles(
      path: path,
      lines: lines,
      signals: signals,
      violations: violations,
    );

    // Rule D (strict): In scoped folders, if Riverpod is used (Notifier extends _$),
    // require @riverpod/@Riverpod annotation in file.
    if (strict) {
      _checkStrictAnnotationRequirement(
        path: path,
        signals: signals,
        violations: violations,
      );
    }
  }

  if (violations.isEmpty) {
    stdout.writeln(
      strict
          ? 'Riverpod DI guard v2 passed (strict).'
          : 'Riverpod DI guard v2 passed.',
    );
    return;
  }

  stderr.writeln(
    strict
        ? 'Riverpod DI guard v2 failed (strict).'
        : 'Riverpod DI guard v2 failed.',
  );
  stderr.writeln(
    'Fix guidance:\n'
    '- Replace manual Provider(...) with @riverpod/@Riverpod + generated providers.\n'
    '- In notifiers, use `ref.mounted` (or cancel work via ref.onDispose) instead of `mounted`.\n'
    '- Avoid StateNotifier/ChangeNotifier in scoped logic; prefer Notifier/AsyncNotifier.\n',
  );

  for (final Violation v in violations) {
    stderr.writeln(
      '${v.filePath}:${v.lineNumber}: ${v.reason} ${v.lineContent}',
    );
  }
  exitCode = 1;
}

class _FileSignals {
  const _FileSignals({
    required this.hasRiverpodAnnotation,
    required this.hasRiverpodGeneratedPart,
    required this.hasRiverpodNotifierClass,
    required this.hasFlutterStateClass,
    required this.isInScopedDir,
  });

  final bool hasRiverpodAnnotation;
  final bool hasRiverpodGeneratedPart;
  final bool hasRiverpodNotifierClass;
  final bool hasFlutterStateClass;
  final bool isInScopedDir;
}

_FileSignals _scanFileSignals({required List<String> lines}) {
  bool hasAnno = false;
  bool hasPart = false;
  bool hasNotifier = false;
  bool hasFlutterState = false;

  for (final String raw in lines) {
    final String line = _stripLineComment(raw).trim();
    if (line.isEmpty) {
      continue;
    }
    if (!hasAnno && _riverpodAnnotationRegExp.hasMatch(line)) {
      hasAnno = true;
    }
    if (!hasPart && _riverpodGeneratedPartRegExp.hasMatch(line)) {
      hasPart = true;
    }
    if (!hasNotifier && _riverpodNotifierClassRegExp.hasMatch(line)) {
      hasNotifier = true;
    }
    if (!hasFlutterState && _flutterStateClassRegExp.hasMatch(line)) {
      hasFlutterState = true;
    }
    if (hasAnno && hasPart && hasNotifier && hasFlutterState) {
      break;
    }
  }

  // isInScopedDir is computed by caller (needs path), keep false here.
  return _FileSignals(
    hasRiverpodAnnotation: hasAnno,
    hasRiverpodGeneratedPart: hasPart,
    hasRiverpodNotifierClass: hasNotifier,
    hasFlutterStateClass: hasFlutterState,
    isInScopedDir: false,
  );
}

void _checkManualProviders({
  required String path,
  required List<String> lines,
  required List<Violation> violations,
}) {
  for (int i = 0; i < lines.length; i++) {
    final String raw = lines[i];
    final String line = _stripLineComment(raw).trim();
    if (line.isEmpty) continue;

    if (_isIgnorableDirectiveLine(line)) continue;

    if (_isImportExportPartLine(line)) continue;

    if (_matchesAny(line, _manualProviderDeclRegExps)) {
      violations.add(
        Violation(
          filePath: path,
          lineNumber: i + 1,
          lineContent: raw.trim(),
          reason:
              'Manual provider declaration is forbidden. Use @riverpod/@Riverpod.',
        ),
      );
    }
  }
}

void _checkLegacyNotifierBases({
  required String path,
  required List<String> lines,
  required List<Violation> violations,
}) {
  if (!_isInScopedDir(path)) {
    return;
  }

  for (int i = 0; i < lines.length; i++) {
    final String raw = lines[i];
    final String line = _stripLineComment(raw).trim();
    if (line.isEmpty) continue;

    if (_isImportExportPartLine(line)) continue;

    if (_matchesAny(line, _legacyNotifierRegExps)) {
      violations.add(
        Violation(
          filePath: path,
          lineNumber: i + 1,
          lineContent: raw.trim(),
          reason:
              'Legacy notifier base detected. Prefer Notifier/AsyncNotifier + @riverpod.',
        ),
      );
    }
  }
}

void _checkMountedInRiverpodFiles({
  required String path,
  required List<String> lines,
  required _FileSignals signals,
  required List<Violation> violations,
}) {
  final bool isRiverpodFile =
      signals.hasRiverpodAnnotation || signals.hasRiverpodNotifierClass;

  // Allow mounted in Flutter State classes (Widget lifecycle).
  // Only ban mounted if file is Riverpod-related and NOT a Flutter State file.
  if (!isRiverpodFile) {
    return;
  }
  if (signals.hasFlutterStateClass) {
    return;
  }

  for (int i = 0; i < lines.length; i++) {
    final String raw = lines[i];
    final String line = _stripLineComment(raw).trim();
    if (line.isEmpty) continue;

    if (!_mountedWordRegExp.hasMatch(line)) continue;

    // ref.mounted is allowed.
    if (_refMountedRegExp.hasMatch(line)) continue;

    violations.add(
      Violation(
        filePath: path,
        lineNumber: i + 1,
        lineContent: raw.trim(),
        reason:
            '`mounted` is forbidden in Riverpod notifier files. Use `ref.mounted` or ref.onDispose cancellation.',
      ),
    );
  }
}

void _checkStrictAnnotationRequirement({
  required String path,
  required _FileSignals signals,
  required List<Violation> violations,
}) {
  if (!_isInScopedDir(path)) {
    return;
  }

  // If file defines a notifier class (extends _$...), require annotation.
  if (!signals.hasRiverpodNotifierClass) {
    return;
  }
  if (signals.hasRiverpodAnnotation) {
    return;
  }

  violations.add(
    Violation(
      filePath: path,
      lineNumber: 1,
      lineContent: path,
      reason:
          'Strict mode: Riverpod notifier file must include @riverpod/@Riverpod annotation.',
    ),
  );
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;

    final String path = _normalizePath(entity.path);

    if (!path.endsWith(RiverpodDiGuardConstV2.dartExtension)) continue;
    if (path.endsWith(RiverpodDiGuardConstV2.generatedExtension)) continue;
    if (path.endsWith(RiverpodDiGuardConstV2.freezedExtension)) continue;

    files.add(entity);
  }
  return files;
}

bool _shouldIgnorePath(String path) {
  for (final String needle in RiverpodDiGuardConstV2.ignorePathContains) {
    if (path.contains(needle)) return true;
  }
  return false;
}

bool _isInScopedDir(String path) {
  for (final String dir in RiverpodDiGuardConstV2.scopedDirs) {
    if (path.contains(dir)) return true;
  }
  return false;
}

bool _isImportExportPartLine(String line) {
  return line.startsWith('import ') ||
      line.startsWith('export ') ||
      line.startsWith('part ');
}

bool _isIgnorableDirectiveLine(String line) {
  // Add future markers here if you want allowlist/ignore per-file.
  // Example: // riverpod-di-guard: ignore
  return false;
}

bool _matchesAny(String line, List<RegExp> regExps) {
  for (final RegExp re in regExps) {
    if (re.hasMatch(line)) return true;
  }
  return false;
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    RiverpodDiGuardConstV2.lineCommentPrefix,
  );
  if (commentIndex < 0) return sourceLine;
  return sourceLine.substring(0, commentIndex);
}

String _normalizePath(String path) => path.replaceAll('\\', '/');

List<RegExp> _buildManualProviderDeclPatterns() {
  final List<RegExp> patterns = <RegExp>[];
  for (final String providerType
      in RiverpodDiGuardConstV2.forbiddenManualProviderTypes) {
    // Matches:
    // - Provider(...)
    // - Provider.family(...)
    // - Provider.autoDispose(...)
    // - final x = Provider(...)
    // - Provider<...>
    //
    // We intentionally avoid matching import lines by skipping them in caller.
    patterns.add(RegExp('\\b$providerType\\b\\s*<'));
    patterns.add(
      RegExp('\\b$providerType\\b\\s*(?:\\.[A-Za-z_][A-Za-z0-9_]*)*\\s*\\('),
    );
    patterns.add(
      RegExp('\\b$providerType\\b\\s*(?:\\.[A-Za-z_][A-Za-z0-9_]*)*\\s*\\.'),
    ); // chained usage
  }
  return patterns;
}

List<RegExp> _buildLegacyNotifierPatterns() {
  final List<RegExp> patterns = <RegExp>[];
  for (final String base
      in RiverpodDiGuardConstV2.forbiddenLegacyNotifierBases) {
    patterns.add(RegExp('\\bextends\\s+$base\\b'));
    patterns.add(RegExp('\\bwith\\s+$base\\b'));
    patterns.add(RegExp('\\b$base\\b\\s*<')); // generic usage
    patterns.add(RegExp('\\b$base\\b\\s*\\(')); // constructor usage
  }
  return patterns;
}
