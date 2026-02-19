// verify_code_quality_contract.dart
//
// Dev dependencies needed (pubspec.yaml):
// dev_dependencies:
//   analyzer: ^6.4.1
//   yaml: ^3.1.2
//
// Run:
//   dart run tool/verify_code_quality_contract.dart

import 'dart:collection';
import 'dart:convert';
import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';
import 'package:yaml/yaml.dart';

class QualityContractConst {
  const QualityContractConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';

  static const String lineCommentPrefix = '//';

  static const String maxFileMarker = 'quality-guard: allow-large-file';
  static const String maxClassMarker = 'quality-guard: allow-large-class';
  static const String maxFunctionMarker = 'quality-guard: allow-long-function';
  static const String listChildrenMarker = 'quality-guard: allow-list-children';
  static const String cachePolicyMarker =
      'quality-guard: allow-unbounded-cache';
}

enum Severity {
  info,
  warning,
  error;

  String get label => switch (this) {
    Severity.info => 'INFO',
    Severity.warning => 'WARN',
    Severity.error => 'ERROR',
  };
}

class QualityConfig {
  const QualityConfig({
    required this.maxFunctionLines,
    required this.maxClassLines,
    required this.maxFileLines,
    required this.maxNestingDepth,
    required this.maxConstructorParams,
    required this.maxWidgetChildrenInline,
    required this.maxViewModelPublicMethods,
    required this.startupMaxAwaitBeforeRunApp,
    required this.jsonDecodeWarnThreshold,
    required this.jsonDecodeLoopWarnThreshold,
    required this.unusedRoots,
    required this.ignoredUnusedPaths,
  });

  final int maxFunctionLines;
  final int maxClassLines;
  final int maxFileLines;
  final int maxNestingDepth;
  final int maxConstructorParams;
  final int maxWidgetChildrenInline;
  final int maxViewModelPublicMethods;
  final int startupMaxAwaitBeforeRunApp;
  final int jsonDecodeWarnThreshold;
  final int jsonDecodeLoopWarnThreshold;
  final List<String> unusedRoots;
  final List<String> ignoredUnusedPaths;

  static QualityConfig defaults() {
    return const QualityConfig(
      maxFunctionLines: 35,
      maxClassLines: 300,
      maxFileLines: 400,
      maxNestingDepth: 3,
      maxConstructorParams: 4,
      maxWidgetChildrenInline: 5,
      maxViewModelPublicMethods: 10,
      startupMaxAwaitBeforeRunApp: 1,
      jsonDecodeWarnThreshold: 3,
      jsonDecodeLoopWarnThreshold: 1,
      unusedRoots: <String>['lib/main.dart'],
      ignoredUnusedPaths: <String>[
        // common exclusions
        '/l10n/',
        '/generated/',
      ],
    );
  }

  static QualityConfig loadOrDefault() {
    final File configFile = File('quality_guard.yaml');
    if (!configFile.existsSync()) {
      return QualityConfig.defaults();
    }

    final dynamic doc = loadYaml(configFile.readAsStringSync());
    if (doc is! YamlMap) {
      return QualityConfig.defaults();
    }

    int readInt(String key, int fallback) {
      final dynamic v = doc[key];
      if (v is int) return v;
      if (v is String) return int.tryParse(v) ?? fallback;
      return fallback;
    }

    List<String> readList(String key, List<String> fallback) {
      final dynamic v = doc[key];
      if (v is YamlList) {
        return v.whereType<String>().toList(growable: false);
      }
      return fallback;
    }

    return QualityConfig(
      maxFunctionLines: readInt(
        'maxFunctionLines',
        QualityConfig.defaults().maxFunctionLines,
      ),
      maxClassLines: readInt(
        'maxClassLines',
        QualityConfig.defaults().maxClassLines,
      ),
      maxFileLines: readInt(
        'maxFileLines',
        QualityConfig.defaults().maxFileLines,
      ),
      maxNestingDepth: readInt(
        'maxNestingDepth',
        QualityConfig.defaults().maxNestingDepth,
      ),
      maxConstructorParams: readInt(
        'maxConstructorParams',
        QualityConfig.defaults().maxConstructorParams,
      ),
      maxWidgetChildrenInline: readInt(
        'maxWidgetChildrenInline',
        QualityConfig.defaults().maxWidgetChildrenInline,
      ),
      maxViewModelPublicMethods: readInt(
        'maxViewModelPublicMethods',
        QualityConfig.defaults().maxViewModelPublicMethods,
      ),
      startupMaxAwaitBeforeRunApp: readInt(
        'startupMaxAwaitBeforeRunApp',
        QualityConfig.defaults().startupMaxAwaitBeforeRunApp,
      ),
      jsonDecodeWarnThreshold: readInt(
        'jsonDecodeWarnThreshold',
        QualityConfig.defaults().jsonDecodeWarnThreshold,
      ),
      jsonDecodeLoopWarnThreshold: readInt(
        'jsonDecodeLoopWarnThreshold',
        QualityConfig.defaults().jsonDecodeLoopWarnThreshold,
      ),
      unusedRoots: readList(
        'unusedRoots',
        QualityConfig.defaults().unusedRoots,
      ),
      ignoredUnusedPaths: readList(
        'ignoredUnusedPaths',
        QualityConfig.defaults().ignoredUnusedPaths,
      ),
    );
  }
}

class QualityViolation {
  const QualityViolation({
    required this.filePath,
    required this.lineNumber,
    required this.severity,
    required this.rule,
    required this.reason,
    required this.lineContent,
  });

  final String filePath;
  final int lineNumber;
  final Severity severity;
  final String rule;
  final String reason;
  final String lineContent;

  String toConsoleLine() {
    return '$filePath:$lineNumber: [${severity.label}] $rule - $reason :: $lineContent';
  }

  Map<String, Object?> toJson() {
    return <String, Object?>{
      'file': filePath,
      'line': lineNumber,
      'severity': severity.label,
      'rule': rule,
      'reason': reason,
      'content': lineContent,
    };
  }
}

class QualityContext {
  QualityContext({required this.config, required this.allPaths});

  final QualityConfig config;
  final Set<String> allPaths;

  final List<QualityViolation> violations = <QualityViolation>[];
  final Map<String, Set<String>> importGraph = <String, Set<String>>{};
}

class FileContext {
  FileContext({
    required this.path,
    required this.lines,
    required this.unit,
    required this.lineInfo,
    required this.sourceText,
    required this.isGeneratedLikeFile,
  });

  final String path;
  final List<String> lines;
  final CompilationUnit unit;
  final LineInfo lineInfo;
  final String sourceText;
  final bool isGeneratedLikeFile;

  bool containsMarker(String marker) => sourceText.contains(marker);
}

abstract class QualityRule {
  String get name;
  void check(QualityContext ctx, FileContext file);
}

Future<void> main() async {
  final QualityConfig config = QualityConfig.loadOrDefault();

  final Directory libDir = Directory(QualityContractConst.libDirectory);
  if (!libDir.existsSync()) {
    stderr.writeln('Missing `${QualityContractConst.libDirectory}` directory.');
    exitCode = 1;
    return;
  }

  final List<File> files = _collectSourceFiles(libDir);
  final Set<String> allPaths = files.map((f) => _normalizePath(f.path)).toSet();

  final QualityContext ctx = QualityContext(config: config, allPaths: allPaths);

  final List<QualityRule> rules = <QualityRule>[
    FileLengthRule(),
    ModelAnnotationRule(),
    RepositoryBoundaryRule(),
    ClassAndFunctionLengthRule(),
    NestingDepthRule(),
    ConstructorParamsRule(),
    WidgetChildrenInlineRule(),
    ViewModelPublicMethodsRule(),
    StatefulDisposalRule(),
    UiChildrenPerformanceRule(),
    CachePolicyRule(),
    StartupBudgetRule(),
    IsolateJsonRule(),
  ];

  for (final File file in files) {
    final String path = _normalizePath(file.path);
    final String text = await file.readAsString();
    final List<String> lines = const LineSplitter().convert(text);
    final bool isGeneratedLikeFile = _isGeneratedLikeFile(path);

    final parsed = parseString(
      content: text,
      path: path,
      throwIfDiagnostics: false,
    );

    final FileContext fc = FileContext(
      path: path,
      lines: lines,
      unit: parsed.unit,
      lineInfo: parsed.lineInfo,
      sourceText: text,
      isGeneratedLikeFile: isGeneratedLikeFile,
    );

    // Build import graph even for generated-like (for unused check)
    ctx.importGraph[path] = _extractInternalDependencies(
      fromPath: path,
      unit: fc.unit,
      allPaths: allPaths,
    );

    if (isGeneratedLikeFile) {
      continue;
    }

    for (final QualityRule rule in rules) {
      rule.check(ctx, fc);
    }
  }

  UnusedFilesRule().checkUnused(
    ctx,
    config: config,
    allPaths: allPaths,
    importGraph: ctx.importGraph,
  );

  if (ctx.violations.isEmpty) {
    stdout.writeln('Code quality contract guard passed.');
    return;
  }

  final List<QualityViolation> blockingViolations = _collectBlockingViolations(
    violations: ctx.violations,
  );
  stderr.writeln('Code quality contract guard report (strict mode).');
  for (final QualityViolation v in ctx.violations) {
    stderr.writeln(v.toConsoleLine());
  }

  // Optional: write JSON report (CI friendly)
  final File jsonReport = File('quality_guard_report.json');
  jsonReport.writeAsStringSync(
    const JsonEncoder.withIndent(
      '  ',
    ).convert(ctx.violations.map((v) => v.toJson()).toList()),
  );

  if (blockingViolations.isEmpty) {
    stdout.writeln(
      'No blocking violations in strict mode. '
      'Error count: ${_countBySeverity(ctx.violations, Severity.error)}, '
      'warning count: ${_countBySeverity(ctx.violations, Severity.warning)}, '
      'info count: ${_countBySeverity(ctx.violations, Severity.info)}.',
    );
    return;
  }

  stderr.writeln(
    'Blocking violations: ${blockingViolations.length}. '
    'Mode: strict.',
  );
  exitCode = 1;
}

List<QualityViolation> _collectBlockingViolations({
  required List<QualityViolation> violations,
}) {
  return violations
      .where(
        (v) => v.severity == Severity.warning || v.severity == Severity.error,
      )
      .toList(growable: false);
}

int _countBySeverity(List<QualityViolation> violations, Severity severity) {
  return violations.where((v) => v.severity == severity).length;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(QualityContractConst.dartExtension)) continue;

    // ignore generated outputs
    if (path.endsWith(QualityContractConst.generatedExtension)) continue;
    if (path.endsWith(QualityContractConst.freezedExtension)) continue;

    files.add(entity);
  }
  return files;
}

bool _isGeneratedLikeFile(String path) {
  // allow adding more patterns later
  if (path.startsWith('lib/l10n/app_localizations')) return true;
  return false;
}

Set<String> _extractInternalDependencies({
  required String fromPath,
  required CompilationUnit unit,
  required Set<String> allPaths,
}) {
  final Set<String> deps = <String>{};

  for (final Directive d in unit.directives) {
    if (d is PartOfDirective) continue;

    final String? uri = switch (d) {
      ImportDirective() => d.uri.stringValue,
      ExportDirective() => d.uri.stringValue,
      PartDirective() => d.uri.stringValue,
      _ => null,
    };
    if (uri == null || uri.isEmpty) continue;
    if (uri.startsWith('dart:')) continue;

    final String? resolved = _resolveImportPath(fromPath: fromPath, uri: uri);
    if (resolved == null) continue;
    if (!allPaths.contains(resolved)) continue;

    deps.add(resolved);
  }

  return deps;
}

String? _resolveImportPath({required String fromPath, required String uri}) {
  if (uri.startsWith('package:learnwise/')) {
    final String subPath = uri.replaceFirst('package:learnwise/', '');
    return _normalizePath('lib/$subPath');
  }
  if (uri.startsWith('package:')) return null;
  if (uri.startsWith('dart:')) return null;

  String working = uri;
  if (working.startsWith('./')) working = working.substring(2);

  final int slash = fromPath.lastIndexOf('/');
  if (slash < 0) return null;

  final String dir = fromPath.substring(0, slash);
  return _normalizePath('$dir/$working');
}

bool _isModelFile(String path) {
  if (path.startsWith('lib/core/model/')) return true;
  if (path.startsWith('lib/features/') && path.contains('/model/')) return true;
  return false;
}

bool _isPresentationOrViewModelFile(String path) {
  if (path.contains('/view/')) return true;
  if (path.contains('/viewmodel/')) return true;
  return false;
}

bool _isRepositoryOrServiceFile(String path) {
  if (path.contains('/repository/')) return true;
  if (path.contains('/service/')) return true;
  return false;
}

bool _isUiFile(String path) {
  if (path.startsWith('lib/common/widgets/')) return true;
  if (path.contains('/view/')) return true;
  return false;
}

bool _isPotentialEntrypoint(String path) {
  if (path.startsWith('lib/main_')) return true;
  if (path.endsWith('/main.dart')) return true;
  return false;
}

bool _isExcludedFromUnusedCheck(String path, QualityConfig config) {
  if (path.endsWith('.g.dart')) return true;
  if (path.endsWith('.freezed.dart')) return true;
  if (path.endsWith('/widgets.dart')) return true;
  if (path.endsWith('/route_names.dart')) return true;
  if (path.contains('/l10n/')) return true;

  for (final String frag in config.ignoredUnusedPaths) {
    if (frag.isNotEmpty && path.contains(frag)) return true;
  }
  return false;
}

int _lineFromOffset(LineInfo info, int offset) {
  return info.getLocation(offset).lineNumber;
}

String _lineContentAt(List<String> lines, int lineNumber) {
  if (lineNumber <= 0) return '';
  if (lineNumber > lines.length) return '';
  return lines[lineNumber - 1].trim();
}

String _normalizePath(String path) {
  final String slashPath = path.replaceAll('\\', '/');
  final List<String> segments = slashPath.split('/');
  final List<String> normalized = <String>[];

  for (final String segment in segments) {
    if (segment.isEmpty || segment == '.') continue;
    if (segment == '..') {
      if (normalized.isNotEmpty) normalized.removeLast();
      continue;
    }
    normalized.add(segment);
  }

  return normalized.join('/');
}

//
// ===================== RULES =====================
//

class FileLengthRule implements QualityRule {
  @override
  String get name => 'FileLengthRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    if (file.containsMarker(QualityContractConst.maxFileMarker)) return;

    final int len = file.lines.length;
    if (len <= ctx.config.maxFileLines) return;

    ctx.violations.add(
      QualityViolation(
        filePath: file.path,
        lineNumber: 1,
        severity: Severity.warning,
        rule: name,
        reason:
            'File length exceeds ${ctx.config.maxFileLines} lines. Split file or add `${QualityContractConst.maxFileMarker}` with justification.',
        lineContent: '$len lines',
      ),
    );
  }
}

class ModelAnnotationRule implements QualityRule {
  @override
  String get name => 'ModelAnnotationRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    if (!_isModelFile(file.path)) return;

    for (final Declaration decl in file.unit.declarations) {
      if (decl is! ClassDeclaration) continue;

      final String className = decl.name.lexeme;
      if (className.startsWith('_')) continue;
      if (_isModelAnnotationExcludedClass(className)) continue;

      final NodeList<Annotation> meta = decl.metadata;
      final bool ok = meta.any((a) {
        final String n = a.name.name;
        return n == 'immutable' || n == 'freezed' || n == 'Freezed';
      });
      if (ok) continue;

      final int line = _lineFromOffset(file.lineInfo, decl.offset);
      ctx.violations.add(
        QualityViolation(
          filePath: file.path,
          lineNumber: line,
          severity: Severity.error,
          rule: name,
          reason:
              'Model class must be annotated with @immutable or @freezed for immutability coverage.',
          lineContent: _lineContentAt(file.lines, line),
        ),
      );
    }
  }

  bool _isModelAnnotationExcludedClass(String className) {
    if (className.endsWith('Constants')) return true;
    if (className.endsWith('Exception')) return true;
    if (className.endsWith('Args')) return true;
    return false;
  }
}

class RepositoryBoundaryRule implements QualityRule {
  @override
  String get name => 'RepositoryBoundaryRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    if (!_isPresentationOrViewModelFile(file.path)) return;

    for (final Directive d in file.unit.directives) {
      if (d is! ImportDirective) continue;
      final String? uri = d.uri.stringValue;
      if (uri == null) continue;

      if (_isForbiddenNetworkImport(uri)) {
        final int line = _lineFromOffset(file.lineInfo, d.offset);
        ctx.violations.add(
          QualityViolation(
            filePath: file.path,
            lineNumber: line,
            severity: Severity.error,
            rule: name,
            reason:
                'View/ViewModel must not import network client directly. Route all I/O through repository layer.',
            lineContent: _lineContentAt(file.lines, line),
          ),
        );
      }
    }
  }

  bool _isForbiddenNetworkImport(String uri) {
    if (uri.contains('package:dio/dio.dart')) return true;
    if (uri.contains('/core/network/')) return true;
    if (uri.contains('api_client.dart')) return true;
    return false;
  }
}

class ClassAndFunctionLengthRule implements QualityRule {
  @override
  String get name => 'ClassAndFunctionLengthRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    _checkClasses(ctx, file);
    _checkFunctions(ctx, file);
  }

  void _checkClasses(QualityContext ctx, FileContext file) {
    if (file.containsMarker(QualityContractConst.maxClassMarker)) {
      // file-level allow
      return;
    }

    for (final Declaration decl in file.unit.declarations) {
      if (decl is! ClassDeclaration) continue;

      // class-level allow marker on same line (best effort)
      final int startLine = _lineFromOffset(file.lineInfo, decl.offset);
      if (_lineContentAt(
        file.lines,
        startLine,
      ).contains(QualityContractConst.maxClassMarker)) {
        continue;
      }

      final int endLine = _lineFromOffset(file.lineInfo, decl.endToken.offset);
      final int len = endLine - startLine + 1;

      if (len <= ctx.config.maxClassLines) continue;

      ctx.violations.add(
        QualityViolation(
          filePath: file.path,
          lineNumber: startLine,
          severity: Severity.warning,
          rule: name,
          reason:
              'Class length exceeds ${ctx.config.maxClassLines} lines. Split class or add `${QualityContractConst.maxClassMarker}` with justification.',
          lineContent: '$len lines',
        ),
      );
    }
  }

  void _checkFunctions(QualityContext ctx, FileContext file) {
    if (file.containsMarker(QualityContractConst.maxFunctionMarker)) {
      // file-level allow
      return;
    }

    final _FunctionCollector collector = _FunctionCollector();
    file.unit.accept(collector);

    for (final _FunctionNode fn in collector.nodes) {
      final int startLine = _lineFromOffset(file.lineInfo, fn.offset);
      final int endLine = _lineFromOffset(file.lineInfo, fn.endOffset);
      final int len = endLine - startLine + 1;

      if (len <= ctx.config.maxFunctionLines) continue;

      // function-level allow marker on the signature line (best effort)
      if (_lineContentAt(
        file.lines,
        startLine,
      ).contains(QualityContractConst.maxFunctionMarker)) {
        continue;
      }

      ctx.violations.add(
        QualityViolation(
          filePath: file.path,
          lineNumber: startLine,
          severity: Severity.warning,
          rule: name,
          reason:
              'Function length exceeds ${ctx.config.maxFunctionLines} lines. Extract smaller units or add `${QualityContractConst.maxFunctionMarker}` with justification.',
          lineContent: '$len lines',
        ),
      );
    }
  }
}

class _FunctionNode {
  const _FunctionNode({required this.offset, required this.endOffset});

  final int offset;
  final int endOffset;
}

class _FunctionCollector extends RecursiveAstVisitor<void> {
  final List<_FunctionNode> nodes = <_FunctionNode>[];

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final FunctionExpression body = node.functionExpression;
    final FunctionBody fb = body.body;
    if (fb is BlockFunctionBody) {
      nodes.add(
        _FunctionNode(offset: node.offset, endOffset: fb.block.endToken.offset),
      );
    }
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final FunctionBody fb = node.body;
    if (fb is BlockFunctionBody) {
      nodes.add(
        _FunctionNode(offset: node.offset, endOffset: fb.block.endToken.offset),
      );
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final FunctionBody fb = node.body;
    if (fb is BlockFunctionBody) {
      nodes.add(
        _FunctionNode(offset: node.offset, endOffset: fb.block.endToken.offset),
      );
    }
    super.visitConstructorDeclaration(node);
  }
}

class NestingDepthRule implements QualityRule {
  @override
  String get name => 'NestingDepthRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    final _ExecutableCollector collector = _ExecutableCollector();
    file.unit.accept(collector);

    for (final _ExecutableNode executable in collector.nodes) {
      final _ControlNestingVisitor visitor = _ControlNestingVisitor();
      executable.block.accept(visitor);

      if (visitor.maxDepth <= ctx.config.maxNestingDepth) {
        continue;
      }

      final int line = _lineFromOffset(file.lineInfo, executable.offset);
      ctx.violations.add(
        QualityViolation(
          filePath: file.path,
          lineNumber: line,
          severity: Severity.warning,
          rule: name,
          reason:
              'Nesting depth exceeds ${ctx.config.maxNestingDepth}. Flatten control flow with early returns.',
          lineContent: 'depth=${visitor.maxDepth}',
        ),
      );
    }
  }
}

class ConstructorParamsRule implements QualityRule {
  @override
  String get name => 'ConstructorParamsRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    final String path = file.path;
    if (_isUiFile(path)) {
      return;
    }
    if (_isModelFile(path)) {
      return;
    }

    final bool isScopedPath =
        path.contains('/viewmodel/') ||
        path.contains('/service/') ||
        path.contains('/repository/');
    if (!isScopedPath) {
      return;
    }

    for (final Declaration declaration in file.unit.declarations) {
      if (declaration is! ClassDeclaration) {
        continue;
      }

      for (final ClassMember member in declaration.members) {
        if (member is! ConstructorDeclaration) {
          continue;
        }

        final int paramCount = member.parameters.parameters.length;
        if (paramCount <= ctx.config.maxConstructorParams) {
          continue;
        }

        final int line = _lineFromOffset(file.lineInfo, member.offset);
        ctx.violations.add(
          QualityViolation(
            filePath: file.path,
            lineNumber: line,
            severity: Severity.warning,
            rule: name,
            reason:
                'Constructor has more than ${ctx.config.maxConstructorParams} parameters. Consider parameter object/builder.',
            lineContent: 'params=$paramCount',
          ),
        );
      }
    }
  }
}

class WidgetChildrenInlineRule implements QualityRule {
  @override
  String get name => 'WidgetChildrenInlineRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    if (!_isUiFile(file.path)) {
      return;
    }

    final _WidgetChildrenInlineVisitor visitor = _WidgetChildrenInlineVisitor();
    file.unit.accept(visitor);

    for (final _WidgetChildrenInlineFinding finding in visitor.findings) {
      if (finding.childrenCount <= ctx.config.maxWidgetChildrenInline) {
        continue;
      }

      final int line = _lineFromOffset(file.lineInfo, finding.offset);
      ctx.violations.add(
        QualityViolation(
          filePath: file.path,
          lineNumber: line,
          severity: Severity.warning,
          rule: name,
          reason:
              'Inline widget children exceeds ${ctx.config.maxWidgetChildrenInline}. Extract child builders/widgets.',
          lineContent:
              '${finding.widgetType}.children=${finding.childrenCount}',
        ),
      );
    }
  }
}

class ViewModelPublicMethodsRule implements QualityRule {
  @override
  String get name => 'ViewModelPublicMethodsRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    if (!file.path.contains('/viewmodel/')) {
      return;
    }

    for (final Declaration declaration in file.unit.declarations) {
      if (declaration is! ClassDeclaration) {
        continue;
      }

      final String className = declaration.name.lexeme;
      if (className.startsWith('_')) {
        continue;
      }

      final int publicMethods = declaration.members
          .whereType<MethodDeclaration>()
          .where((method) => !method.isGetter)
          .where((method) => !method.isSetter)
          .where((method) => !method.name.lexeme.startsWith('_'))
          .length;
      if (publicMethods <= ctx.config.maxViewModelPublicMethods) {
        continue;
      }

      final int line = _lineFromOffset(file.lineInfo, declaration.offset);
      ctx.violations.add(
        QualityViolation(
          filePath: file.path,
          lineNumber: line,
          severity: Severity.warning,
          rule: name,
          reason:
              'ViewModel public methods exceeds ${ctx.config.maxViewModelPublicMethods}. Split responsibilities.',
          lineContent: 'publicMethods=$publicMethods',
        ),
      );
    }
  }
}

class _ExecutableNode {
  const _ExecutableNode({required this.offset, required this.block});

  final int offset;
  final Block block;
}

class _ExecutableCollector extends RecursiveAstVisitor<void> {
  final List<_ExecutableNode> nodes = <_ExecutableNode>[];

  @override
  void visitFunctionDeclaration(FunctionDeclaration node) {
    final FunctionBody body = node.functionExpression.body;
    if (body is BlockFunctionBody) {
      nodes.add(_ExecutableNode(offset: node.offset, block: body.block));
    }
    super.visitFunctionDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final FunctionBody body = node.body;
    if (body is BlockFunctionBody) {
      nodes.add(_ExecutableNode(offset: node.offset, block: body.block));
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitConstructorDeclaration(ConstructorDeclaration node) {
    final FunctionBody body = node.body;
    if (body is BlockFunctionBody) {
      nodes.add(_ExecutableNode(offset: node.offset, block: body.block));
    }
    super.visitConstructorDeclaration(node);
  }
}

class _ControlNestingVisitor extends RecursiveAstVisitor<void> {
  int currentDepth = 0;
  int maxDepth = 0;

  void _withDepth(void Function() action) {
    currentDepth++;
    if (currentDepth > maxDepth) {
      maxDepth = currentDepth;
    }
    action();
    currentDepth--;
  }

  @override
  void visitIfStatement(IfStatement node) {
    final AstNode? parent = node.parent;
    final bool isElseIf =
        parent is IfStatement && identical(parent.elseStatement, node);
    if (isElseIf) {
      super.visitIfStatement(node);
      return;
    }
    _withDepth(() => super.visitIfStatement(node));
  }

  @override
  void visitForStatement(ForStatement node) {
    _withDepth(() => super.visitForStatement(node));
  }

  @override
  void visitWhileStatement(WhileStatement node) {
    _withDepth(() => super.visitWhileStatement(node));
  }

  @override
  void visitDoStatement(DoStatement node) {
    _withDepth(() => super.visitDoStatement(node));
  }

  @override
  void visitSwitchStatement(SwitchStatement node) {
    _withDepth(() => super.visitSwitchStatement(node));
  }

  @override
  void visitTryStatement(TryStatement node) {
    _withDepth(() => super.visitTryStatement(node));
  }
}

class _WidgetChildrenInlineFinding {
  const _WidgetChildrenInlineFinding({
    required this.offset,
    required this.widgetType,
    required this.childrenCount,
  });

  final int offset;
  final String widgetType;
  final int childrenCount;
}

class _WidgetChildrenInlineVisitor extends RecursiveAstVisitor<void> {
  final List<_WidgetChildrenInlineFinding> findings =
      <_WidgetChildrenInlineFinding>[];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final String widgetType = node.constructorName.type.name.lexeme;
    for (final Expression argument in node.argumentList.arguments) {
      if (argument is! NamedExpression) {
        continue;
      }
      if (argument.name.label.name != 'children') {
        continue;
      }

      final Expression childrenExpression = argument.expression;
      if (childrenExpression is! ListLiteral) {
        continue;
      }

      findings.add(
        _WidgetChildrenInlineFinding(
          offset: argument.offset,
          widgetType: widgetType,
          childrenCount: childrenExpression.elements.length,
        ),
      );
    }
    super.visitInstanceCreationExpression(node);
  }
}

class StatefulDisposalRule implements QualityRule {
  @override
  String get name => 'StatefulDisposalRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    final _StatefulDisposalVisitor visitor = _StatefulDisposalVisitor();
    file.unit.accept(visitor);

    for (final _StateResourceFinding f in visitor.findings) {
      if (f.resourceFields.isEmpty) continue;

      if (f.disposeMethod == null) {
        ctx.violations.add(
          QualityViolation(
            filePath: file.path,
            lineNumber: f.classLine,
            severity: Severity.error,
            rule: name,
            reason:
                'State class with disposable resources must implement dispose().',
            lineContent: f.className,
          ),
        );
        continue;
      }

      final _DisposeBodyInfo disposeInfo = _DisposeBodyInfo.fromMethod(
        f.disposeMethod!,
      );

      // Timers/subscriptions should cancel, controllers/focusnodes should dispose.
      for (final _FieldResource r in f.resourceFields) {
        if (r.kind == _ResourceKind.timer ||
            r.kind == _ResourceKind.subscription) {
          if (!disposeInfo.cancelTargets.contains(r.name)) {
            ctx.violations.add(
              QualityViolation(
                filePath: file.path,
                lineNumber: f.disposeLine,
                severity: Severity.error,
                rule: name,
                reason:
                    '${r.kind.label} field `${r.name}` must be cancel()ed in dispose().',
                lineContent: _lineContentAt(file.lines, f.disposeLine),
              ),
            );
          }
          continue;
        }

        if (!disposeInfo.disposeTargets.contains(r.name)) {
          ctx.violations.add(
            QualityViolation(
              filePath: file.path,
              lineNumber: f.disposeLine,
              severity: Severity.error,
              rule: name,
              reason:
                  '${r.kind.label} field `${r.name}` must be dispose()d in dispose().',
              lineContent: _lineContentAt(file.lines, f.disposeLine),
            ),
          );
        }
      }
    }
  }
}

enum _ResourceKind {
  controller('Controller/FocusNode'),
  timer('Timer'),
  subscription('StreamSubscription');

  const _ResourceKind(this.label);
  final String label;
}

class _FieldResource {
  const _FieldResource({required this.name, required this.kind});

  final String name;
  final _ResourceKind kind;
}

class _StateResourceFinding {
  const _StateResourceFinding({
    required this.className,
    required this.classLine,
    required this.disposeLine,
    required this.resourceFields,
    required this.disposeMethod,
  });

  final String className;
  final int classLine;
  final int disposeLine;
  final List<_FieldResource> resourceFields;
  final MethodDeclaration? disposeMethod;
}

class _StatefulDisposalVisitor extends RecursiveAstVisitor<void> {
  final List<_StateResourceFinding> findings = <_StateResourceFinding>[];

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final ExtendsClause? ext = node.extendsClause;
    if (ext == null) return;

    final String superName = ext.superclass.name.lexeme;
    if (superName != 'State') {
      // also allow State<T> via prefixed identifier (rare)
      if (ext.superclass.name.lexeme != 'State') return;
    }

    final List<_FieldResource> resources = <_FieldResource>[];
    MethodDeclaration? disposeMethod;

    for (final ClassMember m in node.members) {
      if (m is MethodDeclaration) {
        if (m.name.lexeme == 'dispose' && m.parameters != null) {
          disposeMethod = m;
        }
      }

      if (m is FieldDeclaration) {
        for (final VariableDeclaration v in m.fields.variables) {
          final String fieldName = v.name.lexeme;
          final TypeAnnotation? t = m.fields.type;

          final String? typeName = _typeNameOf(t);
          if (typeName == null) continue;

          final _ResourceKind? kind = switch (typeName) {
            'TextEditingController' ||
            'ScrollController' ||
            'PageController' ||
            'AnimationController' ||
            'FocusNode' => _ResourceKind.controller,
            'Timer' => _ResourceKind.timer,
            'StreamSubscription' => _ResourceKind.subscription,
            _ => null,
          };

          if (kind != null) {
            resources.add(_FieldResource(name: fieldName, kind: kind));
          }
        }
      }
    }

    if (resources.isEmpty) return;

    final CompilationUnit unit = node.root as CompilationUnit;
    final LineInfo li = unit.lineInfo;
    final int classLine = li.getLocation(node.offset).lineNumber;
    final int disposeLine = disposeMethod == null
        ? classLine
        : li.getLocation(disposeMethod.offset).lineNumber;

    findings.add(
      _StateResourceFinding(
        className: node.name.lexeme,
        classLine: classLine,
        disposeLine: disposeLine,
        resourceFields: resources,
        disposeMethod: disposeMethod,
      ),
    );
  }

  String? _typeNameOf(TypeAnnotation? t) {
    if (t == null) return null;
    if (t is NamedType) {
      return t.name.lexeme;
    }
    return null;
  }
}

class _DisposeBodyInfo {
  const _DisposeBodyInfo({
    required this.disposeTargets,
    required this.cancelTargets,
  });

  final Set<String> disposeTargets;
  final Set<String> cancelTargets;

  static _DisposeBodyInfo fromMethod(MethodDeclaration method) {
    final Set<String> disposeTargets = <String>{};
    final Set<String> cancelTargets = <String>{};

    final FunctionBody body = method.body;
    if (body is! BlockFunctionBody) {
      return _DisposeBodyInfo(
        disposeTargets: disposeTargets,
        cancelTargets: cancelTargets,
      );
    }

    final _DisposeCallVisitor visitor = _DisposeCallVisitor(
      disposeTargets: disposeTargets,
      cancelTargets: cancelTargets,
    );
    body.block.accept(visitor);

    return _DisposeBodyInfo(
      disposeTargets: disposeTargets,
      cancelTargets: cancelTargets,
    );
  }
}

class _DisposeCallVisitor extends RecursiveAstVisitor<void> {
  _DisposeCallVisitor({
    required this.disposeTargets,
    required this.cancelTargets,
  });

  final Set<String> disposeTargets;
  final Set<String> cancelTargets;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final String methodName = node.methodName.name;
    if (methodName == 'dispose' || methodName == 'cancel') {
      final Expression? target = node.target;
      if (target is SimpleIdentifier) {
        final String t = target.name;
        if (methodName == 'dispose') disposeTargets.add(t);
        if (methodName == 'cancel') cancelTargets.add(t);
      }
    }
    super.visitMethodInvocation(node);
  }
}

class UiChildrenPerformanceRule implements QualityRule {
  @override
  String get name => 'UiChildrenPerformanceRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    if (!_isUiFile(file.path)) return;
    if (file.containsMarker(QualityContractConst.listChildrenMarker)) return;

    final _UiChildrenVisitor v = _UiChildrenVisitor();
    file.unit.accept(v);

    for (final int offset in v.childrenListOffsets) {
      final int line = _lineFromOffset(file.lineInfo, offset);
      ctx.violations.add(
        QualityViolation(
          filePath: file.path,
          lineNumber: line,
          severity: Severity.warning,
          rule: name,
          reason:
              'Prefer lazy list/grid (builder/pagination) instead of children: for scalable performance.',
          lineContent: _lineContentAt(file.lines, line),
        ),
      );
    }
  }
}

class _UiChildrenVisitor extends RecursiveAstVisitor<void> {
  final List<int> childrenListOffsets = <int>[];

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final String type = node.constructorName.type.name.lexeme;
    if (type != 'ListView' && type != 'GridView') {
      super.visitInstanceCreationExpression(node);
      return;
    }

    final ArgumentList args = node.argumentList;
    for (final Expression a in args.arguments) {
      if (a is! NamedExpression) continue;
      if (a.name.label.name != 'children') continue;
      childrenListOffsets.add(a.offset);
      break;
    }

    super.visitInstanceCreationExpression(node);
  }
}

class CachePolicyRule implements QualityRule {
  @override
  String get name => 'CachePolicyRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    if (!_isRepositoryOrServiceFile(file.path)) return;
    if (file.containsMarker(QualityContractConst.cachePolicyMarker)) return;

    final _CacheVisitor v = _CacheVisitor();
    file.unit.accept(v);

    if (v.cacheFields.isEmpty) return;

    // accept if file contains policy keywords or obvious invalidation methods
    final String lower = file.sourceText.toLowerCase();
    final bool hasPolicy =
        lower.contains('ttl') ||
        lower.contains('evict') ||
        lower.contains('invalidate') ||
        lower.contains('clearcache') ||
        lower.contains('clear(') ||
        lower.contains('max');

    if (hasPolicy) return;

    // If cache fields exist and no policy signals -> warn.
    ctx.violations.add(
      QualityViolation(
        filePath: file.path,
        lineNumber: 1,
        severity: Severity.warning,
        rule: name,
        reason:
            'Cache-like field detected without eviction/TTL policy. Add bounded cache policy or `${QualityContractConst.cachePolicyMarker}` with justification.',
        lineContent: file.path,
      ),
    );
  }
}

class _CacheVisitor extends RecursiveAstVisitor<void> {
  final List<String> cacheFields = <String>[];

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    for (final VariableDeclaration v in node.fields.variables) {
      final String name = v.name.lexeme;
      if (name.toLowerCase().contains('cache')) {
        cacheFields.add(name);
      }
    }
    super.visitFieldDeclaration(node);
  }
}

class StartupBudgetRule implements QualityRule {
  @override
  String get name => 'StartupBudgetRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    if (file.path != 'lib/main.dart') return;

    final _RunAppOffsetFinder finder = _RunAppOffsetFinder();
    file.unit.accept(finder);

    if (finder.runAppInvocation == null) return;

    final int runAppOffset = finder.runAppInvocation!.offset;
    final int awaitBefore = finder.awaitOffsets
        .where((o) => o < runAppOffset)
        .length;

    if (awaitBefore <= ctx.config.startupMaxAwaitBeforeRunApp) return;

    final int line = _lineFromOffset(
      file.lineInfo,
      finder.runAppInvocation!.offset,
    );
    ctx.violations.add(
      QualityViolation(
        filePath: file.path,
        lineNumber: line,
        severity: Severity.warning,
        rule: name,
        reason:
            'Startup budget risk: multiple awaited tasks before runApp. Defer non-critical work to keep cold start fast.',
        lineContent: 'await before runApp: $awaitBefore',
      ),
    );
  }
}

class _RunAppOffsetFinder extends RecursiveAstVisitor<void> {
  MethodInvocation? runAppInvocation;
  final List<int> awaitOffsets = <int>[];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name == 'runApp') {
      runAppInvocation ??= node;
    }
    super.visitMethodInvocation(node);
  }

  @override
  void visitAwaitExpression(AwaitExpression node) {
    awaitOffsets.add(node.offset);
    super.visitAwaitExpression(node);
  }
}

class IsolateJsonRule implements QualityRule {
  @override
  String get name => 'IsolateJsonRule';

  @override
  void check(QualityContext ctx, FileContext file) {
    if (!_isRepositoryOrServiceFile(file.path) &&
        !file.path.contains('/viewmodel/')) {
      return;
    }

    final _JsonDecodeVisitor v = _JsonDecodeVisitor();
    file.unit.accept(v);

    if (v.jsonDecodeOffsets.isEmpty) return;

    // If compute/Isolate.run exists, accept.
    final bool hasOffload = v.hasComputeOrIsolateRun;
    if (hasOffload) return;

    // Heuristic thresholds to reduce false positives.
    final bool tooMany =
        v.jsonDecodeOffsets.length >= ctx.config.jsonDecodeWarnThreshold;
    final bool inLoops =
        v.jsonDecodeInLoopsCount >= ctx.config.jsonDecodeLoopWarnThreshold;

    if (!tooMany && !inLoops) return;

    ctx.violations.add(
      QualityViolation(
        filePath: file.path,
        lineNumber: 1,
        severity: Severity.warning,
        rule: name,
        reason:
            'Heavy JSON parsing detected without compute()/Isolate.run(). Consider isolate offloading for smoother UI.',
        lineContent:
            'jsonDecode: ${v.jsonDecodeOffsets.length}, inLoops: ${v.jsonDecodeInLoopsCount}',
      ),
    );
  }
}

class _JsonDecodeVisitor extends RecursiveAstVisitor<void> {
  final List<int> jsonDecodeOffsets = <int>[];
  bool hasComputeOrIsolateRun = false;

  int jsonDecodeInLoopsCount = 0;

  @override
  void visitMethodInvocation(MethodInvocation node) {
    final String m = node.methodName.name;

    if (m == 'jsonDecode') {
      jsonDecodeOffsets.add(node.offset);
      if (_isInsideLoop(node)) {
        jsonDecodeInLoopsCount++;
      }
    }

    if (m == 'compute') {
      hasComputeOrIsolateRun = true;
    }

    super.visitMethodInvocation(node);
  }

  @override
  void visitPrefixedIdentifier(PrefixedIdentifier node) {
    // detect Isolate.run usage like Isolate.run(...)
    if (node.prefix.name == 'Isolate' && node.identifier.name == 'run') {
      hasComputeOrIsolateRun = true;
    }
    super.visitPrefixedIdentifier(node);
  }

  bool _isInsideLoop(AstNode node) {
    AstNode? cur = node.parent;
    while (cur != null) {
      if (cur is ForStatement || cur is WhileStatement || cur is DoStatement) {
        return true;
      }
      cur = cur.parent;
    }
    return false;
  }
}

class UnusedFilesRule {
  static const String ruleName = 'UnusedFilesRule';

  void checkUnused(
    QualityContext ctx, {
    required QualityConfig config,
    required Set<String> allPaths,
    required Map<String, Set<String>> importGraph,
  }) {
    final Set<String> roots = <String>{};

    // configured roots
    for (final String r in config.unusedRoots) {
      if (allPaths.contains(r)) roots.add(r);
    }

    // fallback / heuristic roots
    for (final String path in allPaths) {
      if (_isPotentialEntrypoint(path)) roots.add(path);
    }

    if (roots.isEmpty && allPaths.contains('lib/main.dart')) {
      roots.add('lib/main.dart');
    }

    final Set<String> reachable = <String>{};
    final Queue<String> queue = Queue<String>();

    for (final String root in roots) {
      reachable.add(root);
      queue.add(root);
    }

    while (queue.isNotEmpty) {
      final String current = queue.removeFirst();
      final Set<String> deps = importGraph[current] ?? const <String>{};
      for (final String dep in deps) {
        if (reachable.contains(dep)) continue;
        reachable.add(dep);
        queue.add(dep);
      }
    }

    final List<String> sorted = allPaths.toList()..sort();
    for (final String path in sorted) {
      if (reachable.contains(path)) continue;
      if (_isExcludedFromUnusedCheck(path, config)) continue;

      ctx.violations.add(
        QualityViolation(
          filePath: path,
          lineNumber: 1,
          severity: Severity.info,
          rule: ruleName,
          reason:
              'Potentially unused Dart file. Remove/merge or connect it to the import graph.',
          lineContent: path,
        ),
      );
    }
  }
}
