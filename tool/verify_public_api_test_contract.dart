import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:yaml/yaml.dart';

class PublicApiTestGuardConst {
  const PublicApiTestGuardConst._();

  static const String libDirectory = 'lib';
  static const String testDirectory = 'test';
  static const String integrationTestDirectory = 'integration_test';
  static const String configPath = 'test_guard.yaml';
  static const String baselinePath = 'tool/public_api_test_baseline.txt';

  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';

  static const String coverMarkerPrefix = 'test-guard: covers';
  static const String allowUntestedMarkerPrefix =
      'test-guard: allow-untested-public-method';

  static const double defaultMinCoveragePercent = 40;
}

class PublicApiGuardConfig {
  const PublicApiGuardConfig({
    required this.minCoveragePercent,
    required this.scopedPathMarkers,
  });

  final double minCoveragePercent;
  final List<String> scopedPathMarkers;

  static PublicApiGuardConfig defaults() {
    return const PublicApiGuardConfig(
      minCoveragePercent: PublicApiTestGuardConst.defaultMinCoveragePercent,
      scopedPathMarkers: <String>[
        '/repository/',
        '/service/',
        '/viewmodel/',
        '/engine/',
      ],
    );
  }

  static PublicApiGuardConfig loadOrDefault() {
    final File configFile = File(PublicApiTestGuardConst.configPath);
    if (!configFile.existsSync()) {
      return defaults();
    }

    final dynamic document = loadYaml(configFile.readAsStringSync());
    if (document is! YamlMap) {
      return defaults();
    }

    double minCoveragePercent = defaults().minCoveragePercent;
    final dynamic minCoverageRaw = document['minPublicMethodCoveragePercent'];
    if (minCoverageRaw is num) {
      minCoveragePercent = minCoverageRaw.toDouble();
    }

    List<String> scopedPathMarkers = defaults().scopedPathMarkers;
    final dynamic scopeRaw = document['scopedPathMarkers'];
    if (scopeRaw is YamlList) {
      final List<String> parsed = scopeRaw.whereType<String>().toList();
      if (parsed.isNotEmpty) {
        scopedPathMarkers = parsed;
      }
    }

    return PublicApiGuardConfig(
      minCoveragePercent: minCoveragePercent,
      scopedPathMarkers: scopedPathMarkers,
    );
  }
}

class PublicApiTarget {
  const PublicApiTarget({
    required this.filePath,
    required this.lineNumber,
    required this.className,
    required this.methodName,
  });

  final String filePath;
  final int lineNumber;
  final String className;
  final String methodName;

  String get id => '$className.$methodName';
}

class PublicApiTestViolation {
  const PublicApiTestViolation({
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

class _CoverageEvidence {
  const _CoverageEvidence({
    required this.explicitTargetIds,
    required this.invocationNames,
  });

  final Set<String> explicitTargetIds;
  final Set<String> invocationNames;
}

class _CoverageSummary {
  const _CoverageSummary({
    required this.totalTargets,
    required this.coveredTargets,
    required this.uncoveredTargets,
  });

  final int totalTargets;
  final int coveredTargets;
  final List<PublicApiTarget> uncoveredTargets;

  double get coveredPercent {
    if (totalTargets == 0) {
      return 100;
    }

    return (coveredTargets * 100) / totalTargets;
  }
}

Future<void> main(List<String> args) async {
  final bool writeBaseline = args.contains('--write-baseline');
  final PublicApiGuardConfig config = PublicApiGuardConfig.loadOrDefault();

  final Directory libDirectory = Directory(
    PublicApiTestGuardConst.libDirectory,
  );
  if (!libDirectory.existsSync()) {
    stderr.writeln(
      'Missing `${PublicApiTestGuardConst.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<PublicApiTarget> targets = await _collectPublicApiTargets(
    libDirectory: libDirectory,
    config: config,
  );
  if (targets.isEmpty) {
    stdout.writeln(
      'Public API test contract guard skipped: no scoped methods found.',
    );
    return;
  }

  final _CoverageEvidence evidence = await _collectCoverageEvidence();
  final _CoverageSummary summary = _buildCoverageSummary(
    targets: targets,
    evidence: evidence,
  );

  if (writeBaseline) {
    final File baselineFile = File(PublicApiTestGuardConst.baselinePath);
    _writeBaseline(
      baselineFile: baselineFile,
      uncoveredTargets: summary.uncoveredTargets,
    );
    stdout.writeln(
      'Wrote baseline with ${summary.uncoveredTargets.length} uncovered targets '
      'to `${PublicApiTestGuardConst.baselinePath}`.',
    );
    return;
  }

  final File baselineFile = File(PublicApiTestGuardConst.baselinePath);
  final Set<String> baselineIds = _loadBaseline(baselineFile);
  final List<PublicApiTarget> regressionTargets = _collectRegressionTargets(
    uncoveredTargets: summary.uncoveredTargets,
    baselineIds: baselineIds,
  );
  final Set<String> staleBaselineIds = _collectStaleBaselineIds(
    uncoveredTargets: summary.uncoveredTargets,
    baselineIds: baselineIds,
  );

  final List<PublicApiTestViolation> violations = <PublicApiTestViolation>[];
  _collectCoverageThresholdViolation(
    summary: summary,
    config: config,
    violations: violations,
  );
  _collectRegressionViolations(
    regressionTargets: regressionTargets,
    violations: violations,
  );

  _printSummary(
    summary: summary,
    config: config,
    staleBaselineIds: staleBaselineIds,
  );
  if (violations.isEmpty) {
    stdout.writeln('Public API test contract guard passed.');
    return;
  }

  stderr.writeln('Public API test contract guard failed.');
  for (final PublicApiTestViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '${violation.reason} ${violation.lineContent}',
    );
  }

  exitCode = 1;
}

Future<List<PublicApiTarget>> _collectPublicApiTargets({
  required Directory libDirectory,
  required PublicApiGuardConfig config,
}) async {
  final List<PublicApiTarget> targets = <PublicApiTarget>[];
  final List<File> sourceFiles = _collectSourceFiles(libDirectory);

  for (final File sourceFile in sourceFiles) {
    final String normalizedPath = _normalizePath(sourceFile.path);
    if (!_isScopedPath(normalizedPath, config.scopedPathMarkers)) {
      continue;
    }

    final String sourceText = await sourceFile.readAsString();
    final List<String> lines = sourceText.split('\n');
    final Set<String> allowListedTargetIds = _collectAllowListedTargetIds(
      lines,
    );

    final parsed = parseString(
      content: sourceText,
      path: normalizedPath,
      throwIfDiagnostics: false,
    );
    final CompilationUnit unit = parsed.unit;
    final LineInfo lineInfo = parsed.lineInfo;

    for (final Declaration declaration in unit.declarations) {
      if (declaration is! ClassDeclaration) {
        continue;
      }

      final String className = declaration.name.lexeme;
      if (_isPrivateSymbol(className)) {
        continue;
      }

      for (final ClassMember member in declaration.members) {
        if (member is! MethodDeclaration) {
          continue;
        }
        if (!_isTargetMethod(member)) {
          continue;
        }

        final int lineNumber = _lineFromOffset(lineInfo, member.offset);
        final PublicApiTarget target = PublicApiTarget(
          filePath: normalizedPath,
          lineNumber: lineNumber,
          className: className,
          methodName: member.name.lexeme,
        );

        if (allowListedTargetIds.contains(target.id)) {
          continue;
        }
        if (_hasInlineAllowMarker(lines: lines, lineNumber: lineNumber)) {
          continue;
        }

        targets.add(target);
      }
    }
  }

  return targets;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(PublicApiTestGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(PublicApiTestGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(PublicApiTestGuardConst.freezedExtension)) {
      continue;
    }

    files.add(entity);
  }

  return files;
}

bool _isScopedPath(String path, List<String> scopedMarkers) {
  for (final String marker in scopedMarkers) {
    if (path.contains(marker)) {
      return true;
    }
  }
  return false;
}

bool _isPrivateSymbol(String symbol) {
  return symbol.startsWith('_');
}

bool _isTargetMethod(MethodDeclaration method) {
  if (method.isGetter || method.isSetter || method.isOperator) {
    return false;
  }

  final String methodName = method.name.lexeme;
  if (_isPrivateSymbol(methodName)) {
    return false;
  }
  if (_isExcludedMethodName(methodName)) {
    return false;
  }
  if (_hasOverrideAnnotation(method)) {
    return false;
  }

  return true;
}

bool _hasOverrideAnnotation(MethodDeclaration method) {
  for (final Annotation annotation in method.metadata) {
    final String annotationName = annotation.name.name;
    if (annotationName == 'override') {
      return true;
    }
  }
  return false;
}

bool _isExcludedMethodName(String methodName) {
  const Set<String> excludedMethodNames = <String>{
    'toString',
    'noSuchMethod',
    '==',
  };
  return excludedMethodNames.contains(methodName);
}

Set<String> _collectAllowListedTargetIds(List<String> lines) {
  final Set<String> targetIds = <String>{};
  final RegExp specificAllowMarkerRegExp = RegExp(
    r'test-guard:\s*allow-untested-public-method\s+([A-Za-z_][A-Za-z0-9_]*\.[A-Za-z_][A-Za-z0-9_]*)',
  );

  for (final String line in lines) {
    for (final RegExpMatch match in specificAllowMarkerRegExp.allMatches(
      line,
    )) {
      final String? targetId = match.group(1);
      if (targetId == null) {
        continue;
      }
      targetIds.add(targetId);
    }
  }

  return targetIds;
}

bool _hasInlineAllowMarker({
  required List<String> lines,
  required int lineNumber,
}) {
  final int lineIndex = lineNumber - 1;
  final int startIndex = lineIndex - 2;
  final int safeStartIndex = startIndex < 0 ? 0 : startIndex;
  final int safeEndIndex = lineIndex;

  for (int index = safeStartIndex; index <= safeEndIndex; index++) {
    final String line = lines[index];
    if (!line.contains(PublicApiTestGuardConst.allowUntestedMarkerPrefix)) {
      continue;
    }
    return true;
  }

  return false;
}

Future<_CoverageEvidence> _collectCoverageEvidence() async {
  final Set<String> explicitTargetIds = <String>{};
  final Set<String> invocationNames = <String>{};

  final List<File> testFiles = <File>[];
  _appendDartFilesIfExists(
    directory: Directory(PublicApiTestGuardConst.testDirectory),
    files: testFiles,
  );
  _appendDartFilesIfExists(
    directory: Directory(PublicApiTestGuardConst.integrationTestDirectory),
    files: testFiles,
  );

  final RegExp coverMarkerRegExp = RegExp(
    r'test-guard:\s*covers\s+([A-Za-z_][A-Za-z0-9_]*)\.([A-Za-z_][A-Za-z0-9_]*)',
  );
  final RegExp invocationRegExp = RegExp(r'\b([a-z][A-Za-z0-9_]*)\s*\(');

  for (final File file in testFiles) {
    final List<String> lines = await file.readAsLines();
    for (final String line in lines) {
      _collectExplicitCoverMarkers(
        line: line,
        regExp: coverMarkerRegExp,
        output: explicitTargetIds,
      );
      _collectInvocationNames(
        line: line,
        regExp: invocationRegExp,
        output: invocationNames,
      );
    }
  }

  return _CoverageEvidence(
    explicitTargetIds: explicitTargetIds,
    invocationNames: invocationNames,
  );
}

void _appendDartFilesIfExists({
  required Directory directory,
  required List<File> files,
}) {
  if (!directory.existsSync()) {
    return;
  }

  final List<File> collected = _collectSourceFiles(directory);
  files.addAll(collected);
}

void _collectExplicitCoverMarkers({
  required String line,
  required RegExp regExp,
  required Set<String> output,
}) {
  for (final RegExpMatch match in regExp.allMatches(line)) {
    final String? className = match.group(1);
    final String? methodName = match.group(2);
    if (className == null || methodName == null) {
      continue;
    }
    output.add('$className.$methodName');
  }
}

void _collectInvocationNames({
  required String line,
  required RegExp regExp,
  required Set<String> output,
}) {
  final String strippedLine = _stripLineComment(line).trim();
  if (strippedLine.isEmpty) {
    return;
  }

  for (final RegExpMatch match in regExp.allMatches(strippedLine)) {
    final String? invocationName = match.group(1);
    if (invocationName == null) {
      continue;
    }
    if (_isIgnoredInvocationName(invocationName)) {
      continue;
    }
    output.add(invocationName);
  }
}

bool _isIgnoredInvocationName(String invocationName) {
  const Set<String> ignoredNames = <String>{
    'if',
    'for',
    'while',
    'switch',
    'test',
    'testWidgets',
    'group',
    'expect',
    'setUp',
    'tearDown',
    'pumpWidget',
    'pumpAndSettle',
    'find',
    'print',
  };
  return ignoredNames.contains(invocationName);
}

_CoverageSummary _buildCoverageSummary({
  required List<PublicApiTarget> targets,
  required _CoverageEvidence evidence,
}) {
  int coveredTargets = 0;
  final List<PublicApiTarget> uncoveredTargets = <PublicApiTarget>[];

  for (final PublicApiTarget target in targets) {
    if (evidence.explicitTargetIds.contains(target.id)) {
      coveredTargets++;
      continue;
    }
    if (evidence.invocationNames.contains(target.methodName)) {
      coveredTargets++;
      continue;
    }

    uncoveredTargets.add(target);
  }

  return _CoverageSummary(
    totalTargets: targets.length,
    coveredTargets: coveredTargets,
    uncoveredTargets: uncoveredTargets,
  );
}

Set<String> _loadBaseline(File baselineFile) {
  if (!baselineFile.existsSync()) {
    return <String>{};
  }

  final Set<String> baselineIds = <String>{};
  final List<String> lines = baselineFile.readAsLinesSync();
  for (final String line in lines) {
    final String normalized = line.trim();
    if (normalized.isEmpty) {
      continue;
    }
    if (normalized.startsWith('#')) {
      continue;
    }
    baselineIds.add(normalized);
  }
  return baselineIds;
}

void _writeBaseline({
  required File baselineFile,
  required List<PublicApiTarget> uncoveredTargets,
}) {
  final List<String> sortedTargetIds =
      uncoveredTargets.map((target) => target.id).toSet().toList()..sort();

  final String content = sortedTargetIds.join('\n');
  baselineFile.writeAsStringSync('$content\n');
}

List<PublicApiTarget> _collectRegressionTargets({
  required List<PublicApiTarget> uncoveredTargets,
  required Set<String> baselineIds,
}) {
  final List<PublicApiTarget> regressionTargets = <PublicApiTarget>[];
  for (final PublicApiTarget target in uncoveredTargets) {
    if (baselineIds.contains(target.id)) {
      continue;
    }
    regressionTargets.add(target);
  }
  return regressionTargets;
}

Set<String> _collectStaleBaselineIds({
  required List<PublicApiTarget> uncoveredTargets,
  required Set<String> baselineIds,
}) {
  final Set<String> uncoveredIds = uncoveredTargets
      .map((target) => target.id)
      .toSet();
  final Set<String> stale = <String>{};
  for (final String baselineId in baselineIds) {
    if (uncoveredIds.contains(baselineId)) {
      continue;
    }
    stale.add(baselineId);
  }
  return stale;
}

void _collectCoverageThresholdViolation({
  required _CoverageSummary summary,
  required PublicApiGuardConfig config,
  required List<PublicApiTestViolation> violations,
}) {
  final double coveredPercent = summary.coveredPercent;
  if (coveredPercent >= config.minCoveragePercent) {
    return;
  }

  violations.add(
    PublicApiTestViolation(
      filePath: PublicApiTestGuardConst.libDirectory,
      lineNumber: 1,
      reason:
          'Public API coverage below threshold '
          '(${coveredPercent.toStringAsFixed(2)}% < ${config.minCoveragePercent.toStringAsFixed(2)}%).',
      lineContent:
          'covered=${summary.coveredTargets}, total=${summary.totalTargets}',
    ),
  );
}

void _collectRegressionViolations({
  required List<PublicApiTarget> regressionTargets,
  required List<PublicApiTestViolation> violations,
}) {
  for (final PublicApiTarget target in regressionTargets) {
    violations.add(
      PublicApiTestViolation(
        filePath: target.filePath,
        lineNumber: target.lineNumber,
        reason:
            'New untested public method not present in baseline. '
            'Add tests/marker `${PublicApiTestGuardConst.coverMarkerPrefix} ${target.id}` '
            'or explicitly allow with `${PublicApiTestGuardConst.allowUntestedMarkerPrefix} ${target.id}`.',
        lineContent: target.id,
      ),
    );
  }
}

void _printSummary({
  required _CoverageSummary summary,
  required PublicApiGuardConfig config,
  required Set<String> staleBaselineIds,
}) {
  stdout.writeln(
    'Public API coverage summary: '
    '${summary.coveredTargets}/${summary.totalTargets} '
    '(${summary.coveredPercent.toStringAsFixed(2)}%), '
    'threshold=${config.minCoveragePercent.toStringAsFixed(2)}%.',
  );

  if (staleBaselineIds.isEmpty) {
    return;
  }

  final List<String> sortedStaleIds = staleBaselineIds.toList()..sort();
  stdout.writeln(
    'Stale baseline entries detected (${sortedStaleIds.length}). '
    'Consider cleaning `${PublicApiTestGuardConst.baselinePath}`.',
  );
  for (final String staleId in sortedStaleIds) {
    stdout.writeln('  - $staleId');
  }
}

int _lineFromOffset(LineInfo lineInfo, int offset) {
  return lineInfo.getLocation(offset).lineNumber;
}

String _stripLineComment(String line) {
  final int index = line.indexOf('//');
  if (index < 0) {
    return line;
  }
  return line.substring(0, index);
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
