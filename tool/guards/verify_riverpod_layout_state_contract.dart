import 'dart:io';

import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/source/line_info.dart';

class RiverpodLayoutStateConst {
  const RiverpodLayoutStateConst._();

  static const String libDirectory = 'lib';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';

  static const String presentationPrefix = 'lib/presentation/';
  static const String coreWidgetsPrefix = 'lib/core/widgets/';

  static const List<String> stateScopeMarkers = <String>[
    '/providers/',
    '/viewmodel/',
    '/controllers/',
  ];

  static const List<String> stateFileSuffixes = <String>[
    '_provider.dart',
    '_providers.dart',
    '_viewmodel.dart',
    'viewmodel.dart',
    '_controller.dart',
    '_controllers.dart',
  ];

  static const String ruleNoMounted = 'RLS001';
  static const String ruleNoReadInBuild = 'RLS002';
  static const String ruleNoRefField = 'RLS003';
  static const String ruleGeneratedClassNeedsAnnotation = 'RLS004';
  static const String ruleAnnotationNeedsPart = 'RLS005';
  static const String rulePartFileMissing = 'RLS006';
  static const String ruleUnexpectedPartName = 'RLS007';
}

class RiverpodLayoutStateViolation {
  const RiverpodLayoutStateViolation({
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
}

final RegExp _riverpodAnnotationRegExp = RegExp(r'@\s*(?:riverpod|Riverpod)\b');
final RegExp _generatedRiverpodClassRegExp = RegExp(
  r'\bclass\s+\w+\s+extends\s+_\$\w+\b',
);

Future<void> main() async {
  final Directory libDirectory = Directory(
    RiverpodLayoutStateConst.libDirectory,
  );
  if (!libDirectory.existsSync()) {
    stderr.writeln(
      'Missing `${RiverpodLayoutStateConst.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(libDirectory);
  final List<RiverpodLayoutStateViolation> violations =
      <RiverpodLayoutStateViolation>[];

  for (final File sourceFile in sourceFiles) {
    final String path = _normalizePath(sourceFile.path);
    if (!_isScopedFile(path)) {
      continue;
    }

    final String sourceText = await sourceFile.readAsString();
    final List<String> lines = await sourceFile.readAsLines();
    final parsed = parseString(
      content: sourceText,
      path: path,
      throwIfDiagnostics: false,
    );

    _checkMountedUsage(
      path: path,
      lines: lines,
      lineInfo: parsed.lineInfo,
      unit: parsed.unit,
      violations: violations,
    );

    _checkRefReadInBuild(
      path: path,
      lines: lines,
      lineInfo: parsed.lineInfo,
      unit: parsed.unit,
      violations: violations,
    );

    _checkRefFields(
      path: path,
      lines: lines,
      lineInfo: parsed.lineInfo,
      unit: parsed.unit,
      violations: violations,
    );

    _checkGeneratedProviderContract(
      path: path,
      lines: lines,
      lineInfo: parsed.lineInfo,
      unit: parsed.unit,
      sourceText: sourceText,
      violations: violations,
    );
  }

  if (violations.isEmpty) {
    stdout.writeln('Riverpod layout state contract passed.');
    return;
  }

  stderr.writeln('Riverpod layout state contract failed.');
  stderr.writeln(
    'Fix guidance:\n'
    '- Remove `mounted/context.mounted` checks in UI/state flow.\n'
    '- Do not call `ref.read(...)` directly in `build`; keep it in callbacks/listeners.\n'
    '- Do not keep `WidgetRef/Ref` as instance fields.\n'
    '- Ensure `@riverpod` files declare `part \'*.g.dart\';` and generated file exists.\n',
  );

  for (final RiverpodLayoutStateViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '[${violation.ruleId}] ${violation.reason} ${violation.lineContent}',
    );
  }

  exitCode = 1;
}

void _checkMountedUsage({
  required String path,
  required List<String> lines,
  required LineInfo lineInfo,
  required CompilationUnit unit,
  required List<RiverpodLayoutStateViolation> violations,
}) {
  final _MountedUsageVisitor visitor = _MountedUsageVisitor();
  unit.accept(visitor);

  for (final int offset in visitor.offsets) {
    final int lineNumber = _lineFromOffset(lineInfo, offset);
    violations.add(
      RiverpodLayoutStateViolation(
        ruleId: RiverpodLayoutStateConst.ruleNoMounted,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            '`mounted/context.mounted` is forbidden for Riverpod layout-state flow.',
        lineContent: _lineContentAt(lines, lineNumber),
      ),
    );
  }
}

void _checkRefReadInBuild({
  required String path,
  required List<String> lines,
  required LineInfo lineInfo,
  required CompilationUnit unit,
  required List<RiverpodLayoutStateViolation> violations,
}) {
  final _BuildReadVisitor visitor = _BuildReadVisitor();
  unit.accept(visitor);

  for (final int offset in visitor.offsets) {
    final int lineNumber = _lineFromOffset(lineInfo, offset);
    violations.add(
      RiverpodLayoutStateViolation(
        ruleId: RiverpodLayoutStateConst.ruleNoReadInBuild,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Avoid `ref.read(...)` directly in `build`. Use `ref.watch(...)` or move to callback/listen.',
        lineContent: _lineContentAt(lines, lineNumber),
      ),
    );
  }
}

void _checkRefFields({
  required String path,
  required List<String> lines,
  required LineInfo lineInfo,
  required CompilationUnit unit,
  required List<RiverpodLayoutStateViolation> violations,
}) {
  final _RefFieldVisitor visitor = _RefFieldVisitor();
  unit.accept(visitor);

  for (final int offset in visitor.offsets) {
    final int lineNumber = _lineFromOffset(lineInfo, offset);
    violations.add(
      RiverpodLayoutStateViolation(
        ruleId: RiverpodLayoutStateConst.ruleNoRefField,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Do not store `WidgetRef/Ref` as an instance field. Pass `ref` as parameter.',
        lineContent: _lineContentAt(lines, lineNumber),
      ),
    );
  }
}

void _checkGeneratedProviderContract({
  required String path,
  required List<String> lines,
  required LineInfo lineInfo,
  required CompilationUnit unit,
  required String sourceText,
  required List<RiverpodLayoutStateViolation> violations,
}) {
  if (!_isStateFile(path)) {
    return;
  }

  final bool hasRiverpodAnnotation = _riverpodAnnotationRegExp.hasMatch(
    sourceText,
  );
  final bool hasGeneratedRiverpodClass = _generatedRiverpodClassRegExp.hasMatch(
    sourceText,
  );

  if (hasGeneratedRiverpodClass && !hasRiverpodAnnotation) {
    violations.add(
      RiverpodLayoutStateViolation(
        ruleId: RiverpodLayoutStateConst.ruleGeneratedClassNeedsAnnotation,
        filePath: path,
        lineNumber: 1,
        reason: 'Generated Riverpod class requires `@riverpod/@Riverpod`.',
        lineContent: path,
      ),
    );
  }

  final List<PartDirective> gPartDirectives = unit.directives
      .whereType<PartDirective>()
      .where((PartDirective directive) {
        final String? uri = directive.uri.stringValue;
        if (uri == null) {
          return false;
        }
        return uri.endsWith(RiverpodLayoutStateConst.generatedExtension);
      })
      .toList(growable: false);

  if (hasRiverpodAnnotation && gPartDirectives.isEmpty) {
    violations.add(
      RiverpodLayoutStateViolation(
        ruleId: RiverpodLayoutStateConst.ruleAnnotationNeedsPart,
        filePath: path,
        lineNumber: 1,
        reason: '`@riverpod/@Riverpod` file must declare `part \'*.g.dart\';`.',
        lineContent: path,
      ),
    );
  }

  final String expectedPartFileName =
      '${_basenameWithoutExtension(path)}.g.dart';
  if (hasRiverpodAnnotation && gPartDirectives.isNotEmpty) {
    final bool hasExpectedPart = gPartDirectives.any((PartDirective directive) {
      final String? uri = directive.uri.stringValue;
      if (uri == null) {
        return false;
      }
      return uri == expectedPartFileName;
    });

    if (!hasExpectedPart) {
      violations.add(
        RiverpodLayoutStateViolation(
          ruleId: RiverpodLayoutStateConst.ruleUnexpectedPartName,
          filePath: path,
          lineNumber: 1,
          reason:
              'Expected `part \'$expectedPartFileName\';` for this file to match generator output.',
          lineContent: path,
        ),
      );
    }
  }

  for (final PartDirective directive in gPartDirectives) {
    final String? uri = directive.uri.stringValue;
    if (uri == null) {
      continue;
    }

    final String resolvedPath = _normalizePath(_resolveRelativePath(path, uri));
    if (File(resolvedPath).existsSync()) {
      continue;
    }

    final int lineNumber = _lineFromOffset(lineInfo, directive.offset);
    violations.add(
      RiverpodLayoutStateViolation(
        ruleId: RiverpodLayoutStateConst.rulePartFileMissing,
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'Generated part file does not exist. Run build_runner to generate `$uri`.',
        lineContent: _lineContentAt(lines, lineNumber),
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

    final String normalizedPath = _normalizePath(entity.path);
    if (!normalizedPath.endsWith(RiverpodLayoutStateConst.dartExtension)) {
      continue;
    }
    if (normalizedPath.endsWith(RiverpodLayoutStateConst.generatedExtension)) {
      continue;
    }
    if (normalizedPath.endsWith(RiverpodLayoutStateConst.freezedExtension)) {
      continue;
    }

    sourceFiles.add(entity);
  }
  return sourceFiles;
}

bool _isScopedFile(String path) {
  if (path.startsWith(RiverpodLayoutStateConst.presentationPrefix)) {
    return true;
  }
  if (path.startsWith(RiverpodLayoutStateConst.coreWidgetsPrefix)) {
    return true;
  }
  if (_containsAny(path, RiverpodLayoutStateConst.stateScopeMarkers)) {
    return true;
  }
  return false;
}

bool _isStateFile(String path) {
  if (_containsAny(path, RiverpodLayoutStateConst.stateScopeMarkers)) {
    return true;
  }
  if (_endsWithAny(path, RiverpodLayoutStateConst.stateFileSuffixes)) {
    return true;
  }
  return false;
}

bool _containsAny(String value, List<String> patterns) {
  for (final String pattern in patterns) {
    if (value.contains(pattern)) {
      return true;
    }
  }
  return false;
}

bool _endsWithAny(String value, List<String> suffixes) {
  for (final String suffix in suffixes) {
    if (value.endsWith(suffix)) {
      return true;
    }
  }
  return false;
}

int _lineFromOffset(LineInfo lineInfo, int offset) {
  return lineInfo.getLocation(offset).lineNumber;
}

String _lineContentAt(List<String> lines, int lineNumber) {
  if (lineNumber <= 0) {
    return '';
  }
  if (lineNumber > lines.length) {
    return '';
  }
  return lines[lineNumber - 1].trim();
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
      if (normalized.isNotEmpty) {
        normalized.removeLast();
      }
      continue;
    }
    normalized.add(segment);
  }

  return normalized.join('/');
}

String _resolveRelativePath(String fromPath, String relative) {
  final int lastSlash = fromPath.lastIndexOf('/');
  if (lastSlash < 0) {
    return relative;
  }
  final String directory = fromPath.substring(0, lastSlash);
  return '$directory/$relative';
}

String _basenameWithoutExtension(String path) {
  final List<String> segments = path.split('/');
  if (segments.isEmpty) {
    return path;
  }

  final String fileName = segments.last;
  final int dotIndex = fileName.lastIndexOf('.');
  if (dotIndex < 0) {
    return fileName;
  }

  return fileName.substring(0, dotIndex);
}

class _MountedUsageVisitor extends RecursiveAstVisitor<void> {
  final List<int> offsets = <int>[];

  @override
  void visitSimpleIdentifier(SimpleIdentifier node) {
    if (node.name != 'mounted') {
      super.visitSimpleIdentifier(node);
      return;
    }
    if (_isDeclarationName(node)) {
      super.visitSimpleIdentifier(node);
      return;
    }
    if (_isAllowedRefMounted(node)) {
      super.visitSimpleIdentifier(node);
      return;
    }

    offsets.add(node.offset);
    super.visitSimpleIdentifier(node);
  }

  bool _isDeclarationName(SimpleIdentifier node) {
    final AstNode? parent = node.parent;
    if (parent is VariableDeclaration && identical(parent.name, node)) {
      return true;
    }
    if (parent is SimpleFormalParameter && identical(parent.name, node)) {
      return true;
    }
    if (parent is FieldFormalParameter && identical(parent.name, node)) {
      return true;
    }
    if (parent is MethodDeclaration && identical(parent.name, node)) {
      return true;
    }
    return false;
  }

  bool _isAllowedRefMounted(SimpleIdentifier node) {
    final AstNode? parent = node.parent;
    if (parent is PrefixedIdentifier &&
        identical(parent.identifier, node) &&
        parent.prefix.name == 'ref') {
      return true;
    }
    if (parent is PropertyAccess &&
        identical(parent.propertyName, node) &&
        parent.target is SimpleIdentifier &&
        (parent.target as SimpleIdentifier).name == 'ref') {
      return true;
    }
    return false;
  }
}

class _BuildReadVisitor extends RecursiveAstVisitor<void> {
  final List<int> offsets = <int>[];

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    if (node.name.lexeme != 'build') {
      super.visitMethodDeclaration(node);
      return;
    }
    if (!_hasBuildContextParam(node)) {
      super.visitMethodDeclaration(node);
      return;
    }
    if (node.body is! BlockFunctionBody) {
      super.visitMethodDeclaration(node);
      return;
    }

    final BlockFunctionBody body = node.body as BlockFunctionBody;
    final _RefReadInBuildBodyVisitor bodyVisitor = _RefReadInBuildBodyVisitor(
      buildBlock: body.block,
    );
    body.block.accept(bodyVisitor);
    offsets.addAll(bodyVisitor.offsets);

    super.visitMethodDeclaration(node);
  }

  bool _hasBuildContextParam(MethodDeclaration node) {
    final FormalParameterList? params = node.parameters;
    if (params == null) {
      return false;
    }
    if (params.parameters.isEmpty) {
      return false;
    }

    final FormalParameter first = params.parameters.first;
    if (first is! SimpleFormalParameter) {
      return false;
    }
    final TypeAnnotation? type = first.type;
    if (type is! NamedType) {
      return false;
    }
    return type.name.lexeme == 'BuildContext';
  }
}

class _RefReadInBuildBodyVisitor extends RecursiveAstVisitor<void> {
  _RefReadInBuildBodyVisitor({required this.buildBlock});

  final Block buildBlock;
  final List<int> offsets = <int>[];

  @override
  void visitMethodInvocation(MethodInvocation node) {
    if (node.methodName.name != 'read') {
      super.visitMethodInvocation(node);
      return;
    }

    final Expression? target = node.target;
    if (target is! SimpleIdentifier) {
      super.visitMethodInvocation(node);
      return;
    }
    if (target.name != 'ref') {
      super.visitMethodInvocation(node);
      return;
    }
    if (_isInsideNestedFunction(node)) {
      super.visitMethodInvocation(node);
      return;
    }

    offsets.add(node.offset);
    super.visitMethodInvocation(node);
  }

  bool _isInsideNestedFunction(AstNode node) {
    AstNode? current = node.parent;
    while (current != null && !identical(current, buildBlock)) {
      if (current is FunctionExpression) {
        return true;
      }
      current = current.parent;
    }
    return false;
  }
}

class _RefFieldVisitor extends RecursiveAstVisitor<void> {
  final List<int> offsets = <int>[];

  @override
  void visitFieldDeclaration(FieldDeclaration node) {
    final TypeAnnotation? type = node.fields.type;
    if (type is! NamedType) {
      super.visitFieldDeclaration(node);
      return;
    }

    final String typeName = type.name.lexeme;
    if (typeName != 'WidgetRef' && typeName != 'Ref') {
      super.visitFieldDeclaration(node);
      return;
    }

    for (final VariableDeclaration variable in node.fields.variables) {
      offsets.add(variable.offset);
    }

    super.visitFieldDeclaration(node);
  }
}
