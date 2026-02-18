import 'dart:collection';
import 'dart:io';

class QualityContractConst {
  const QualityContractConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String lineCommentPrefix = '//';

  static const int maxFunctionLines = 30;
  static const int maxClassLines = 300;
  static const int maxFileLines = 400;

  static const String maxFileMarker = 'quality-guard: allow-large-file';
  static const String maxClassMarker = 'quality-guard: allow-large-class';
  static const String maxFunctionMarker = 'quality-guard: allow-long-function';
  static const String listChildrenMarker = 'quality-guard: allow-list-children';
  static const String cachePolicyMarker =
      'quality-guard: allow-unbounded-cache';
}

class QualityViolation {
  const QualityViolation({
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

final RegExp _publicClassRegExp = RegExp(
  r'^\s*(?:(?:abstract|base|final|sealed|interface)\s+)*class\s+([A-Za-z_][A-Za-z0-9_]*)\b',
);
final RegExp _functionSignatureRegExp = RegExp(
  r'^\s*(?:[A-Za-z_][A-Za-z0-9_<>\?\[\],\s]*\s+)?(?:[A-Za-z_][A-Za-z0-9_]*\.)?[A-Za-z_][A-Za-z0-9_]*\s*\([^;]*\)\s*(?:async\s*)?\{',
);
final RegExp _statefulStateClassRegExp = RegExp(
  r'\bclass\s+\w+\s+extends\s+State<',
);
final RegExp _resourceFieldRegExp = RegExp(
  r'\b(?:TextEditingController|ScrollController|PageController|AnimationController|FocusNode|Timer|StreamSubscription)\b',
);
final RegExp _disposeMethodRegExp = RegExp(r'\bvoid\s+dispose\s*\(');
final RegExp _disposeCallRegExp = RegExp(r'\.dispose\s*\(');
final RegExp _cancelCallRegExp = RegExp(r'\.cancel\s*\(');
final RegExp _timerTypeRegExp = RegExp(r'\bTimer\b');
final RegExp _subscriptionTypeRegExp = RegExp(r'\bStreamSubscription\b');
final RegExp _controllerTypeRegExp = RegExp(
  r'\b(?:TextEditingController|ScrollController|PageController|AnimationController|FocusNode)\b',
);
final RegExp _listViewRegExp = RegExp(r'\bListView\s*\(');
final RegExp _gridViewRegExp = RegExp(r'\bGridView\s*\(');
final RegExp _childrenPropertyRegExp = RegExp(r'\bchildren\s*:');
final RegExp _cacheFieldRegExp = RegExp(
  r'\b[A-Za-z_][A-Za-z0-9_]*cache\b',
  caseSensitive: false,
);
final RegExp _cachePolicyKeywordRegExp = RegExp(
  r'\b(?:ttl|max|evict|clearCache|clear\(|invalidate)\b',
  caseSensitive: false,
);
final RegExp _importExportPartRegExp = RegExp(
  r'''^\s*(?:import|export|part)\s+['"]([^'"]+)['"]''',
);
final RegExp _partOfRegExp = RegExp(r'^\s*part\s+of\s+');
final RegExp _awaitRegExp = RegExp(r'\bawait\b');
final RegExp _runAppRegExp = RegExp(r'\brunApp\s*\(');
final RegExp _jsonDecodeRegExp = RegExp(r'\bjsonDecode\s*\(');
final RegExp _computeOrIsolateRegExp = RegExp(
  r'\b(?:compute|Isolate\.run)\s*\(',
);

Future<void> main() async {
  final Directory libDirectory = Directory(QualityContractConst.libDirectory);
  if (!libDirectory.existsSync()) {
    stderr.writeln('Missing `${QualityContractConst.libDirectory}` directory.');
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(libDirectory);
  final Set<String> allPaths = sourceFiles
      .map((file) => _normalizePath(file.path))
      .toSet();
  final List<QualityViolation> violations = <QualityViolation>[];
  final Map<String, Set<String>> importGraph = <String, Set<String>>{};

  for (final File file in sourceFiles) {
    final String normalizedPath = _normalizePath(file.path);
    final List<String> lines = await file.readAsLines();
    final bool isGeneratedLikeFile = _isGeneratedLikeFile(normalizedPath);
    if (isGeneratedLikeFile) {
      importGraph[normalizedPath] = _extractInternalDependencies(
        path: normalizedPath,
        lines: lines,
        allPaths: allPaths,
      );
      continue;
    }

    final bool fileAllowsLargeSize = _fileContainsMarker(
      lines: lines,
      marker: QualityContractConst.maxFileMarker,
    );

    if (lines.length > QualityContractConst.maxFileLines &&
        !fileAllowsLargeSize) {
      violations.add(
        QualityViolation(
          filePath: normalizedPath,
          lineNumber: 1,
          reason:
              'File length exceeds ${QualityContractConst.maxFileLines} lines. Split file or add `${QualityContractConst.maxFileMarker}` with justification.',
          lineContent: '${lines.length} lines',
        ),
      );
    }

    _checkModelAnnotations(
      path: normalizedPath,
      lines: lines,
      violations: violations,
    );
    _checkRepositoryBoundary(
      path: normalizedPath,
      lines: lines,
      violations: violations,
    );
    _checkClassAndFunctionLength(
      path: normalizedPath,
      lines: lines,
      violations: violations,
    );
    _checkStatefulResourceDisposal(
      path: normalizedPath,
      lines: lines,
      violations: violations,
    );
    _checkUiPerformanceHeuristics(
      path: normalizedPath,
      lines: lines,
      violations: violations,
    );
    _checkCachePolicy(
      path: normalizedPath,
      lines: lines,
      violations: violations,
    );
    _checkStartupBudgetHeuristic(
      path: normalizedPath,
      lines: lines,
      violations: violations,
    );
    _checkIsolateHeuristic(
      path: normalizedPath,
      lines: lines,
      violations: violations,
    );

    importGraph[normalizedPath] = _extractInternalDependencies(
      path: normalizedPath,
      lines: lines,
      allPaths: allPaths,
    );
  }

  _checkUnusedFiles(
    allPaths: allPaths,
    importGraph: importGraph,
    violations: violations,
  );

  if (violations.isEmpty) {
    stdout.writeln('Code quality contract guard passed.');
    return;
  }

  stderr.writeln('Code quality contract guard failed.');
  for (final QualityViolation violation in violations) {
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
    if (!path.endsWith(QualityContractConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(QualityContractConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(QualityContractConst.freezedExtension)) {
      continue;
    }

    files.add(entity);
  }
  return files;
}

void _checkModelAnnotations({
  required String path,
  required List<String> lines,
  required List<QualityViolation> violations,
}) {
  if (!_isModelFile(path)) {
    return;
  }

  for (int index = 0; index < lines.length; index++) {
    final String sourceLine = _stripLineComment(lines[index]).trim();
    if (sourceLine.isEmpty) {
      continue;
    }

    final RegExpMatch? match = _publicClassRegExp.firstMatch(sourceLine);
    if (match == null) {
      continue;
    }

    final String className = match.group(1) ?? '';
    if (className.isEmpty) {
      continue;
    }
    if (className.startsWith('_')) {
      continue;
    }
    if (_isModelAnnotationExcludedClass(className)) {
      continue;
    }
    if (_hasNearbyModelAnnotation(lines: lines, declarationIndex: index)) {
      continue;
    }

    violations.add(
      QualityViolation(
        filePath: path,
        lineNumber: index + 1,
        reason:
            'Model class must be annotated with @immutable or @freezed for immutability coverage.',
        lineContent: lines[index].trim(),
      ),
    );
  }
}

void _checkRepositoryBoundary({
  required String path,
  required List<String> lines,
  required List<QualityViolation> violations,
}) {
  if (!_isPresentationOrViewModelFile(path)) {
    return;
  }

  for (int index = 0; index < lines.length; index++) {
    final String rawLine = lines[index];
    final String sourceLine = _stripLineComment(rawLine).trim();
    if (sourceLine.isEmpty) {
      continue;
    }

    if (!sourceLine.startsWith('import ')) {
      continue;
    }
    if (!_containsForbiddenNetworkImport(sourceLine)) {
      continue;
    }

    violations.add(
      QualityViolation(
        filePath: path,
        lineNumber: index + 1,
        reason:
            'View/ViewModel must not import network client directly. Route all I/O through repository layer.',
        lineContent: rawLine.trim(),
      ),
    );
  }
}

void _checkClassAndFunctionLength({
  required String path,
  required List<String> lines,
  required List<QualityViolation> violations,
}) {
  for (int index = 0; index < lines.length; index++) {
    final String sourceLine = _stripLineComment(lines[index]).trim();
    if (sourceLine.isEmpty) {
      continue;
    }

    if (_publicClassRegExp.hasMatch(sourceLine)) {
      final int? classEnd = _findBlockEnd(lines: lines, startLineIndex: index);
      if (classEnd == null) {
        continue;
      }

      final int classLength = classEnd - index + 1;
      if (classLength <= QualityContractConst.maxClassLines) {
        continue;
      }
      if (lines[index].contains(QualityContractConst.maxClassMarker)) {
        continue;
      }
      if (_fileContainsMarker(
        lines: lines,
        marker: QualityContractConst.maxClassMarker,
      )) {
        continue;
      }

      violations.add(
        QualityViolation(
          filePath: path,
          lineNumber: index + 1,
          reason:
              'Class length exceeds ${QualityContractConst.maxClassLines} lines. Split class or add `${QualityContractConst.maxClassMarker}` with justification.',
          lineContent: '$classLength lines',
        ),
      );
    }

    if (!_looksLikeFunctionSignature(sourceLine)) {
      continue;
    }
    final int? functionEnd = _findBlockEnd(lines: lines, startLineIndex: index);
    if (functionEnd == null) {
      continue;
    }

    final int functionLength = functionEnd - index + 1;
    if (functionLength <= QualityContractConst.maxFunctionLines) {
      continue;
    }
    if (lines[index].contains(QualityContractConst.maxFunctionMarker)) {
      continue;
    }
    if (_fileContainsMarker(
      lines: lines,
      marker: QualityContractConst.maxFunctionMarker,
    )) {
      continue;
    }

    violations.add(
      QualityViolation(
        filePath: path,
        lineNumber: index + 1,
        reason:
            'Function length exceeds ${QualityContractConst.maxFunctionLines} lines. Extract smaller units or add `${QualityContractConst.maxFunctionMarker}` with justification.',
        lineContent: '$functionLength lines',
      ),
    );
  }
}

void _checkStatefulResourceDisposal({
  required String path,
  required List<String> lines,
  required List<QualityViolation> violations,
}) {
  final String entireSource = lines.join('\n');
  if (!_statefulStateClassRegExp.hasMatch(entireSource)) {
    return;
  }
  if (!_resourceFieldRegExp.hasMatch(entireSource)) {
    return;
  }

  if (!_disposeMethodRegExp.hasMatch(entireSource)) {
    violations.add(
      QualityViolation(
        filePath: path,
        lineNumber: 1,
        reason:
            'Stateful widget with disposable resources must implement dispose().',
        lineContent: path,
      ),
    );
    return;
  }

  if (_timerTypeRegExp.hasMatch(entireSource) &&
      !_cancelCallRegExp.hasMatch(entireSource)) {
    violations.add(
      QualityViolation(
        filePath: path,
        lineNumber: 1,
        reason: 'Timer usage detected without cancel() in dispose lifecycle.',
        lineContent: path,
      ),
    );
  }

  if (_subscriptionTypeRegExp.hasMatch(entireSource) &&
      !_cancelCallRegExp.hasMatch(entireSource)) {
    violations.add(
      QualityViolation(
        filePath: path,
        lineNumber: 1,
        reason:
            'StreamSubscription usage detected without cancel() in dispose lifecycle.',
        lineContent: path,
      ),
    );
  }

  if (_controllerTypeRegExp.hasMatch(entireSource) &&
      !_disposeCallRegExp.hasMatch(entireSource)) {
    violations.add(
      QualityViolation(
        filePath: path,
        lineNumber: 1,
        reason:
            'Controller/FocusNode usage detected without dispose() call for resources.',
        lineContent: path,
      ),
    );
  }
}

void _checkUiPerformanceHeuristics({
  required String path,
  required List<String> lines,
  required List<QualityViolation> violations,
}) {
  if (!_isUiFile(path)) {
    return;
  }

  for (int index = 0; index < lines.length; index++) {
    final String rawLine = lines[index];
    final String sourceLine = _stripLineComment(rawLine).trim();
    if (sourceLine.isEmpty) {
      continue;
    }
    if (rawLine.contains(QualityContractConst.listChildrenMarker)) {
      continue;
    }

    if (_listViewRegExp.hasMatch(sourceLine) ||
        _gridViewRegExp.hasMatch(sourceLine)) {
      if (!_windowContainsChildren(lines: lines, anchorIndex: index)) {
        continue;
      }

      violations.add(
        QualityViolation(
          filePath: path,
          lineNumber: index + 1,
          reason:
              'Prefer lazy list/grid (builder/pagination) instead of children: for scalable performance.',
          lineContent: rawLine.trim(),
        ),
      );
    }
  }
}

void _checkCachePolicy({
  required String path,
  required List<String> lines,
  required List<QualityViolation> violations,
}) {
  if (!_isRepositoryOrServiceFile(path)) {
    return;
  }

  final String source = lines.join('\n');
  if (!_cacheFieldRegExp.hasMatch(source)) {
    return;
  }
  if (source.contains(QualityContractConst.cachePolicyMarker)) {
    return;
  }
  if (_cachePolicyKeywordRegExp.hasMatch(source)) {
    return;
  }

  violations.add(
    QualityViolation(
      filePath: path,
      lineNumber: 1,
      reason:
          'Cache-like field detected without eviction/TTL policy. Add bounded cache policy or `${QualityContractConst.cachePolicyMarker}` with justification.',
      lineContent: path,
    ),
  );
}

void _checkStartupBudgetHeuristic({
  required String path,
  required List<String> lines,
  required List<QualityViolation> violations,
}) {
  if (path != 'lib/main.dart') {
    return;
  }

  int runAppLine = -1;
  for (int index = 0; index < lines.length; index++) {
    final String sourceLine = _stripLineComment(lines[index]).trim();
    if (!_runAppRegExp.hasMatch(sourceLine)) {
      continue;
    }
    runAppLine = index;
    break;
  }
  if (runAppLine < 0) {
    return;
  }

  int awaitCountBeforeRunApp = 0;
  for (int index = 0; index < runAppLine; index++) {
    final String sourceLine = _stripLineComment(lines[index]).trim();
    if (!_awaitRegExp.hasMatch(sourceLine)) {
      continue;
    }
    awaitCountBeforeRunApp++;
  }
  if (awaitCountBeforeRunApp <= 1) {
    return;
  }

  violations.add(
    QualityViolation(
      filePath: path,
      lineNumber: runAppLine + 1,
      reason:
          'Startup budget risk: multiple awaited tasks before runApp. Keep cold start under ~3s by deferring non-critical work.',
      lineContent: 'await before runApp: $awaitCountBeforeRunApp',
    ),
  );
}

void _checkIsolateHeuristic({
  required String path,
  required List<String> lines,
  required List<QualityViolation> violations,
}) {
  if (!_isRepositoryOrServiceFile(path) && !path.contains('/viewmodel/')) {
    return;
  }

  final String source = lines.join('\n');
  if (!_jsonDecodeRegExp.hasMatch(source)) {
    return;
  }
  if (_computeOrIsolateRegExp.hasMatch(source)) {
    return;
  }

  violations.add(
    QualityViolation(
      filePath: path,
      lineNumber: 1,
      reason:
          'Heavy JSON parsing detected without compute()/Isolate.run(). Consider isolate offloading for smoother 60 FPS UI.',
      lineContent: path,
    ),
  );
}

Set<String> _extractInternalDependencies({
  required String path,
  required List<String> lines,
  required Set<String> allPaths,
}) {
  final Set<String> dependencies = <String>{};

  for (final String rawLine in lines) {
    final String sourceLine = _stripLineComment(rawLine).trim();
    if (sourceLine.isEmpty) {
      continue;
    }
    if (_partOfRegExp.hasMatch(sourceLine)) {
      continue;
    }

    final RegExpMatch? match = _importExportPartRegExp.firstMatch(sourceLine);
    if (match == null) {
      continue;
    }

    final String uri = match.group(1) ?? '';
    if (uri.isEmpty) {
      continue;
    }
    if (uri.startsWith('dart:')) {
      continue;
    }

    final String? resolvedPath = _resolveImportPath(fromPath: path, uri: uri);
    if (resolvedPath == null) {
      continue;
    }
    if (!allPaths.contains(resolvedPath)) {
      continue;
    }
    dependencies.add(resolvedPath);
  }

  return dependencies;
}

void _checkUnusedFiles({
  required Set<String> allPaths,
  required Map<String, Set<String>> importGraph,
  required List<QualityViolation> violations,
}) {
  final Set<String> roots = <String>{};
  if (allPaths.contains('lib/main.dart')) {
    roots.add('lib/main.dart');
  }
  for (final String path in allPaths) {
    if (_isPotentialEntrypoint(path)) {
      roots.add(path);
    }
  }

  final Set<String> reachable = <String>{};
  final Queue<String> queue = Queue<String>();
  for (final String root in roots) {
    reachable.add(root);
    queue.add(root);
  }

  while (queue.isNotEmpty) {
    final String current = queue.removeFirst();
    final Set<String> deps = importGraph[current] ?? <String>{};
    for (final String dep in deps) {
      if (reachable.contains(dep)) {
        continue;
      }
      reachable.add(dep);
      queue.add(dep);
    }
  }

  for (final String path in allPaths.toList()..sort()) {
    if (reachable.contains(path)) {
      continue;
    }
    if (_isExcludedFromUnusedCheck(path)) {
      continue;
    }

    violations.add(
      QualityViolation(
        filePath: path,
        lineNumber: 1,
        reason:
            'Potentially unused Dart file. Remove/merge or connect it to the import graph.',
        lineContent: path,
      ),
    );
  }
}

bool _isModelFile(String path) {
  if (path.startsWith('lib/core/model/')) {
    return true;
  }
  if (path.startsWith('lib/features/') && path.contains('/model/')) {
    return true;
  }
  return false;
}

bool _isPresentationOrViewModelFile(String path) {
  if (path.contains('/view/')) {
    return true;
  }
  if (path.contains('/viewmodel/')) {
    return true;
  }
  return false;
}

bool _isRepositoryOrServiceFile(String path) {
  if (path.contains('/repository/')) {
    return true;
  }
  if (path.contains('/service/')) {
    return true;
  }
  return false;
}

bool _isUiFile(String path) {
  if (path.startsWith('lib/common/widgets/')) {
    return true;
  }
  if (path.contains('/view/')) {
    return true;
  }
  return false;
}

bool _hasNearbyModelAnnotation({
  required List<String> lines,
  required int declarationIndex,
}) {
  int checked = 0;
  for (int index = declarationIndex - 1; index >= 0; index--) {
    final String sourceLine = _stripLineComment(lines[index]).trim();
    if (sourceLine.isEmpty) {
      continue;
    }
    if (sourceLine.startsWith('@immutable')) {
      return true;
    }
    if (sourceLine.startsWith('@freezed')) {
      return true;
    }
    if (sourceLine.startsWith('@Freezed')) {
      return true;
    }
    checked++;
    if (checked >= 3) {
      return false;
    }
  }
  return false;
}

bool _containsForbiddenNetworkImport(String sourceLine) {
  if (sourceLine.contains('package:dio/dio.dart')) {
    return true;
  }
  if (sourceLine.contains('/core/network/')) {
    return true;
  }
  if (sourceLine.contains('api_client.dart')) {
    return true;
  }
  return false;
}

bool _looksLikeFunctionSignature(String sourceLine) {
  if (!_functionSignatureRegExp.hasMatch(sourceLine)) {
    return false;
  }
  if (sourceLine.startsWith('if ')) {
    return false;
  }
  if (sourceLine.startsWith('if(')) {
    return false;
  }
  if (sourceLine.startsWith('for ')) {
    return false;
  }
  if (sourceLine.startsWith('for(')) {
    return false;
  }
  if (sourceLine.startsWith('while ')) {
    return false;
  }
  if (sourceLine.startsWith('while(')) {
    return false;
  }
  if (sourceLine.startsWith('switch ')) {
    return false;
  }
  if (sourceLine.startsWith('switch(')) {
    return false;
  }
  if (sourceLine.startsWith('catch ')) {
    return false;
  }
  if (sourceLine.startsWith('catch(')) {
    return false;
  }
  return true;
}

int? _findBlockEnd({required List<String> lines, required int startLineIndex}) {
  int openBraces = 0;
  bool foundOpening = false;
  for (int lineIndex = startLineIndex; lineIndex < lines.length; lineIndex++) {
    final String line = lines[lineIndex];
    for (int charIndex = 0; charIndex < line.length; charIndex++) {
      final String char = line[charIndex];
      if (char == '{') {
        openBraces++;
        foundOpening = true;
      }
      if (char == '}') {
        openBraces--;
        if (foundOpening && openBraces == 0) {
          return lineIndex;
        }
      }
    }
  }
  return null;
}

bool _windowContainsChildren({
  required List<String> lines,
  required int anchorIndex,
}) {
  final int windowEnd = anchorIndex + 8;
  for (int index = anchorIndex; index <= windowEnd; index++) {
    if (index >= lines.length) {
      return false;
    }
    final String sourceLine = _stripLineComment(lines[index]).trim();
    if (_childrenPropertyRegExp.hasMatch(sourceLine)) {
      return true;
    }
  }
  return false;
}

bool _fileContainsMarker({
  required List<String> lines,
  required String marker,
}) {
  for (final String line in lines) {
    if (!line.contains(marker)) {
      continue;
    }
    return true;
  }
  return false;
}

bool _isPotentialEntrypoint(String path) {
  if (path.startsWith('lib/main_')) {
    return true;
  }
  if (path.endsWith('/main.dart')) {
    return true;
  }
  return false;
}

bool _isExcludedFromUnusedCheck(String path) {
  if (path.endsWith('.g.dart')) {
    return true;
  }
  if (path.endsWith('.freezed.dart')) {
    return true;
  }
  if (path.endsWith('/widgets.dart')) {
    return true;
  }
  if (path.endsWith('/route_names.dart')) {
    return true;
  }
  if (path.contains('/l10n/')) {
    return true;
  }
  return false;
}

bool _isGeneratedLikeFile(String path) {
  if (path.startsWith('lib/l10n/app_localizations')) {
    return true;
  }
  return false;
}

bool _isModelAnnotationExcludedClass(String className) {
  if (className.endsWith('Constants')) {
    return true;
  }
  if (className.endsWith('Exception')) {
    return true;
  }
  if (className.endsWith('Args')) {
    return true;
  }
  return false;
}

String? _resolveImportPath({required String fromPath, required String uri}) {
  if (uri.startsWith('package:learnwise/')) {
    final String subPath = uri.replaceFirst('package:learnwise/', '');
    return _normalizePath('lib/$subPath');
  }
  if (uri.startsWith('package:')) {
    return null;
  }
  if (uri.startsWith('dart:')) {
    return null;
  }

  String workingUri = uri;
  if (workingUri.startsWith('./')) {
    workingUri = workingUri.substring(2);
  }

  final int slashIndex = fromPath.lastIndexOf('/');
  if (slashIndex < 0) {
    return null;
  }
  final String directoryPath = fromPath.substring(0, slashIndex);
  return _normalizePath('$directoryPath/$workingUri');
}

String _stripLineComment(String sourceLine) {
  final int commentIndex = sourceLine.indexOf(
    QualityContractConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return sourceLine;
  }
  return sourceLine.substring(0, commentIndex);
}

String _normalizePath(String path) {
  final String slashPath = path.replaceAll('\\', '/');
  final List<String> segments = slashPath.split('/');
  final List<String> normalized = <String>[];

  for (final String segment in segments) {
    if (segment.isEmpty || segment == '.') {
      continue;
    }
    if (segment == '..') {
      if (normalized.isEmpty) {
        continue;
      }
      normalized.removeLast();
      continue;
    }
    normalized.add(segment);
  }

  return normalized.join('/');
}
