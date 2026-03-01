import 'dart:io';

import 'package:analyzer/dart/analysis/analysis_context_collection.dart';
import 'package:analyzer/dart/analysis/results.dart';
import 'package:analyzer/dart/analysis/utilities.dart';
import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/dart/ast/visitor.dart';
import 'package:analyzer/dart/element/element.dart';
import 'package:analyzer/dart/element/type.dart';
import 'package:analyzer/source/line_info.dart';

class UiLogicSeparationGuardConst {
  const UiLogicSeparationGuardConst._();

  static const String featuresRoot = 'lib/presentation/features';
  static const String presentationFeaturesPrefix = 'lib/presentation/features/';
  static const String featureScreensMarker = '/screens/';
  static const String featureWidgetsMarker = '/widgets/';
  static const String providersMarker = '/providers/';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
  static const String generatedRouteExtension = '.gr.dart';
  static const String allowLineMarker =
      'ui-logic-separation-guard: allow-inline-logic';
  static const String allowFileMarker = 'ui-logic-separation-guard: allow-file';

  static const List<String> forbiddenImportUriFragments = <String>[
    '/data/',
    '/datasource/',
    '/datasources/',
    '/repositories/',
    '/repository/',
    '/domain/repositories/',
    '/domain/usecase/',
    '/domain/usecases/',
    '/service/',
    '/services/',
    '/network/',
    'api_client.dart',
    'api_client_impl.dart',
    'package:dio/dio.dart',
    'package:http/http.dart',
    'dart:io',
    'dart:convert',
  ];

  static const List<String> dependencyKeywords = <String>[
    'repository',
    'service',
    'usecase',
    'datasource',
    'data source',
    'apiclient',
    'api client',
  ];

  static const List<String> derivedMethodPrefixes = <String>[
    '_resolve',
    '_compute',
    '_derive',
    '_calculate',
    '_filter',
    '_sort',
    '_map',
    '_parse',
    '_normalize',
    '_validate',
    '_compare',
    '_transform',
  ];

  static const List<String> allowedUiDerivedReturnTypes = <String>[
    'Widget',
    'PreferredSizeWidget',
    'void',
    'Future<void>',
    'Color',
    'TextStyle',
    'TextTheme',
    'BoxDecoration',
    'Decoration',
    'Border',
    'BorderSide',
    'BorderRadius',
    'BorderRadiusGeometry',
    'EdgeInsets',
    'EdgeInsetsGeometry',
    'ShapeBorder',
    'Gradient',
    'Alignment',
    'AlignmentGeometry',
    'IconData',
  ];

  static const Set<String> networkRequestMethodNames = <String>{
    'get',
    'post',
    'put',
    'delete',
    'patch',
    'head',
    'read',
    'readBytes',
    'request',
    'fetch',
    'download',
    'upload',
  };
}

class UiLogicSeparationViolation {
  const UiLogicSeparationViolation({
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
  final Directory featuresDirectory = Directory(
    UiLogicSeparationGuardConst.featuresRoot,
  );
  if (!featuresDirectory.existsSync()) {
    stderr.writeln(
      'Missing `${UiLogicSeparationGuardConst.featuresRoot}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<File> sourceFiles = _collectSourceFiles(featuresDirectory);
  final List<UiLogicSeparationViolation> violations =
      <UiLogicSeparationViolation>[];
  final String featuresAbsolutePath = _toAbsoluteOsPath(featuresDirectory.path);

  final AnalysisContextCollection contextCollection = AnalysisContextCollection(
    includedPaths: <String>[featuresAbsolutePath],
  );

  for (final File sourceFile in sourceFiles) {
    final String path = _normalizePath(sourceFile.path);
    if (!_isFeatureUiPath(path)) {
      continue;
    }

    final String sourceText = await sourceFile.readAsString();
    if (sourceText.contains(UiLogicSeparationGuardConst.allowFileMarker)) {
      continue;
    }

    final List<String> lines = sourceText.split('\n');
    final _ResolvedUiUnit resolvedUiUnit = await _loadResolvedUiUnit(
      sourceFile: sourceFile,
      path: path,
      sourceText: sourceText,
      contextCollection: contextCollection,
    );

    _checkImports(
      unit: resolvedUiUnit.unit,
      path: path,
      lines: lines,
      lineInfo: resolvedUiUnit.lineInfo,
      violations: violations,
    );

    final _UiLogicSemanticVisitor visitor = _UiLogicSemanticVisitor(
      path: path,
      lines: lines,
      lineInfo: resolvedUiUnit.lineInfo,
      violations: violations,
    );
    resolvedUiUnit.unit.accept(visitor);
  }

  if (violations.isEmpty) {
    stdout.writeln('UI logic separation contract passed.');
    return;
  }

  stderr.writeln('UI logic separation contract failed.');
  for (final UiLogicSeparationViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

class _ResolvedUiUnit {
  const _ResolvedUiUnit({required this.unit, required this.lineInfo});

  final CompilationUnit unit;
  final LineInfo lineInfo;
}

Future<_ResolvedUiUnit> _loadResolvedUiUnit({
  required File sourceFile,
  required String path,
  required String sourceText,
  required AnalysisContextCollection contextCollection,
}) async {
  final String absolutePath = _toAbsoluteOsPath(sourceFile.path);
  final ResolvedUnitResult? resolved = await _tryResolveUnit(
    absolutePath: absolutePath,
    contextCollection: contextCollection,
  );
  if (resolved != null) {
    return _ResolvedUiUnit(unit: resolved.unit, lineInfo: resolved.lineInfo);
  }

  final parsed = parseString(
    content: sourceText,
    path: path,
    throwIfDiagnostics: false,
  );
  return _ResolvedUiUnit(unit: parsed.unit, lineInfo: parsed.lineInfo);
}

Future<ResolvedUnitResult?> _tryResolveUnit({
  required String absolutePath,
  required AnalysisContextCollection contextCollection,
}) async {
  try {
    final context = contextCollection.contextFor(absolutePath);
    final SomeResolvedUnitResult result = await context.currentSession
        .getResolvedUnit(absolutePath);
    if (result is ResolvedUnitResult) {
      return result;
    }
    return null;
  } catch (_) {
    return null;
  }
}

void _checkImports({
  required CompilationUnit unit,
  required String path,
  required List<String> lines,
  required LineInfo lineInfo,
  required List<UiLogicSeparationViolation> violations,
}) {
  for (final Directive directive in unit.directives) {
    if (directive is! ImportDirective) {
      continue;
    }
    final String? uri = directive.uri.stringValue;
    if (uri == null) {
      continue;
    }
    if (!_isForbiddenImportUri(uri)) {
      continue;
    }
    final int lineNumber = _lineFromOffset(lineInfo, directive.offset);
    if (_hasAllowLineMarker(lines: lines, lineNumber: lineNumber)) {
      continue;
    }
    violations.add(
      UiLogicSeparationViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason:
            'UI files must not import data/network/domain-logic dependencies directly. Route through feature providers/controllers.',
        lineContent: _lineContentAt(lines, lineNumber),
      ),
    );
  }
}

class _UiLogicSemanticVisitor extends RecursiveAstVisitor<void> {
  _UiLogicSemanticVisitor({
    required this.path,
    required this.lines,
    required this.lineInfo,
    required this.violations,
  });

  final String path;
  final List<String> lines;
  final LineInfo lineInfo;
  final List<UiLogicSeparationViolation> violations;

  @override
  void visitAnnotation(Annotation node) {
    final String annotationName = node.name.name;
    if (annotationName == 'riverpod' || annotationName == 'Riverpod') {
      _addViolation(
        node: node,
        reason:
            'UI files must not declare Riverpod providers/controllers. Move logic declaration to providers layer.',
      );
    }
    super.visitAnnotation(node);
  }

  @override
  void visitClassDeclaration(ClassDeclaration node) {
    final ExtendsClause? extendsClause = node.extendsClause;
    if (extendsClause == null) {
      super.visitClassDeclaration(node);
      return;
    }

    final String superType = extendsClause.superclass.toSource();
    if (superType.startsWith('_\$')) {
      _addViolation(
        node: node,
        reason:
            'UI files must not implement generated Riverpod notifiers. Move logic to providers layer.',
      );
    }

    super.visitClassDeclaration(node);
  }

  @override
  void visitTopLevelVariableDeclaration(TopLevelVariableDeclaration node) {
    for (final VariableDeclaration variable in node.variables.variables) {
      final Element? variableElement = variable.declaredFragment?.element;
      final DartType? declaredType = switch (variableElement) {
        VariableElement() => variableElement.type,
        _ => null,
      };
      final String declaredTypeText = _typeText(declaredType).toLowerCase();
      final String initializerTypeText = _typeText(
        variable.initializer?.staticType,
      ).toLowerCase();
      final String initializerSource =
          variable.initializer?.toSource().toLowerCase() ?? '';

      final bool looksLikeProviderDeclaration =
          _looksLikeProviderTypeText(declaredTypeText) ||
          _looksLikeProviderTypeText(initializerTypeText) ||
          _looksLikeProviderTypeText(initializerSource);

      if (!looksLikeProviderDeclaration) {
        continue;
      }

      _addViolation(
        node: variable,
        reason:
            'UI files must not declare Provider instances. Keep provider declaration in providers layer.',
      );
    }
    super.visitTopLevelVariableDeclaration(node);
  }

  @override
  void visitMethodDeclaration(MethodDeclaration node) {
    final String methodName = node.name.lexeme;
    if (_isDerivedMethodName(methodName)) {
      final String returnTypeSource = node.returnType?.toSource() ?? 'dynamic';
      if (!_isAllowedUiDerivedReturnType(returnTypeSource)) {
        _addViolation(
          node: node,
          reason:
              'UI files must not keep domain/state derivation helpers (`$methodName`). Move derivation to provider/state and pass resolved value to UI.',
        );
      }
    }
    super.visitMethodDeclaration(node);
  }

  @override
  void visitMethodInvocation(MethodInvocation node) {
    _checkJsonSerializationInvocation(node);
    _checkNetworkRequestInvocation(node);
    _checkRefDependencyInvocation(node);
    super.visitMethodInvocation(node);
  }

  @override
  void visitInstanceCreationExpression(InstanceCreationExpression node) {
    final String constructorType = node.constructorName.type.toSource();
    final String constructorTypeLower = constructorType.toLowerCase();
    final String libraryUri = _elementLibraryUri(node.constructorName.element);

    final bool isNetworkClientCtor =
        constructorTypeLower == 'dio' ||
        constructorTypeLower.endsWith('.dio') ||
        constructorTypeLower == 'httpclient' ||
        libraryUri == 'dart:io' && constructorTypeLower == 'httpclient';
    if (isNetworkClientCtor) {
      _addViolation(
        node: node,
        reason:
            'UI files must not create network clients directly. Use repository/provider abstraction.',
      );
    }

    super.visitInstanceCreationExpression(node);
  }

  void _checkJsonSerializationInvocation(MethodInvocation node) {
    final String methodName = node.methodName.name;
    if (methodName != 'jsonDecode' && methodName != 'jsonEncode') {
      return;
    }

    final String libraryUri = _elementLibraryUri(node.methodName.element);
    final bool isDartConvert =
        libraryUri == 'dart:convert' || libraryUri.isEmpty;
    if (!isDartConvert) {
      return;
    }

    _addViolation(
      node: node,
      reason:
          'UI files must not do serialization logic (`jsonEncode/jsonDecode`). Move to data/domain layer.',
    );
  }

  void _checkNetworkRequestInvocation(MethodInvocation node) {
    final String methodName = node.methodName.name;
    if (!UiLogicSeparationGuardConst.networkRequestMethodNames.contains(
      methodName,
    )) {
      return;
    }

    final String targetSource = node.target?.toSource() ?? '';
    final String targetType = _typeText(node.target?.staticType);
    final String libraryUri = _elementLibraryUri(node.methodName.element);

    final bool directHttpNamespace = targetSource == 'http';
    final bool fromHttpLibrary = libraryUri.contains('package:http/http.dart');
    final bool fromDioLibrary = libraryUri.contains('package:dio/dio.dart');
    final bool targetLooksLikeNetworkClient =
        targetType.contains('Dio') || targetType.contains('HttpClient');

    final bool isNetworkCall =
        directHttpNamespace ||
        fromHttpLibrary ||
        fromDioLibrary ||
        targetLooksLikeNetworkClient;
    if (!isNetworkCall) {
      return;
    }

    _addViolation(
      node: node,
      reason:
          'UI files must not execute HTTP requests directly. Use repository/provider abstraction.',
    );
  }

  void _checkRefDependencyInvocation(MethodInvocation node) {
    final Expression? target = node.target;
    if (target is! SimpleIdentifier || target.name != 'ref') {
      return;
    }

    final String refMethod = node.methodName.name;
    if (refMethod != 'read' && refMethod != 'watch' && refMethod != 'listen') {
      return;
    }

    final NodeList<Expression> arguments = node.argumentList.arguments;
    if (arguments.isEmpty) {
      return;
    }

    final Expression providerExpression = arguments.first;
    final String providerTypeText = _typeText(
      providerExpression.staticType,
    ).toLowerCase();
    final String providerSourceText = providerExpression
        .toSource()
        .toLowerCase();
    final String providerElementText = _elementName(
      _expressionElement(providerExpression),
    ).toLowerCase();

    final bool looksLikeDependencyProvider =
        _hasDependencyKeyword(providerTypeText) ||
        _hasDependencyKeyword(providerSourceText) ||
        _hasDependencyKeyword(providerElementText);
    if (!looksLikeDependencyProvider) {
      return;
    }

    _addViolation(
      node: node,
      reason:
          'UI files must not depend on repository/service-level providers directly. Read feature state providers only.',
    );
  }

  void _addViolation({required AstNode node, required String reason}) {
    final int lineNumber = _lineFromOffset(lineInfo, node.offset);
    if (_hasAllowLineMarker(lines: lines, lineNumber: lineNumber)) {
      return;
    }

    violations.add(
      UiLogicSeparationViolation(
        filePath: path,
        lineNumber: lineNumber,
        reason: reason,
        lineContent: _lineContentAt(lines, lineNumber),
      ),
    );
  }
}

bool _isForbiddenImportUri(String uri) {
  final String normalized = uri.toLowerCase();
  for (final String fragment
      in UiLogicSeparationGuardConst.forbiddenImportUriFragments) {
    if (normalized.contains(fragment.toLowerCase())) {
      return true;
    }
  }
  return false;
}

bool _hasDependencyKeyword(String source) {
  for (final String keyword in UiLogicSeparationGuardConst.dependencyKeywords) {
    if (source.contains(keyword)) {
      return true;
    }
  }
  return false;
}

bool _looksLikeProviderTypeText(String source) {
  final RegExp providerPattern = RegExp(
    r'\b(?:provider|stateprovider|futureprovider|streamprovider|notifierprovider|asyncnotifierprovider|statenotifierprovider|changenotifierprovider)\b',
    caseSensitive: false,
  );
  return providerPattern.hasMatch(source);
}

bool _isDerivedMethodName(String methodName) {
  if (!methodName.startsWith('_')) {
    return false;
  }
  for (final String prefix
      in UiLogicSeparationGuardConst.derivedMethodPrefixes) {
    if (!methodName.startsWith(prefix)) {
      continue;
    }
    if (methodName.length == prefix.length) {
      return true;
    }
    final String nextChar = methodName[prefix.length];
    if (RegExp(r'[A-Z]').hasMatch(nextChar)) {
      return true;
    }
  }
  return false;
}

bool _isAllowedUiDerivedReturnType(String returnTypeSource) {
  final String normalized = returnTypeSource.replaceAll(' ', '');
  for (final String allowed
      in UiLogicSeparationGuardConst.allowedUiDerivedReturnTypes) {
    if (normalized == allowed.replaceAll(' ', '')) {
      return true;
    }
  }
  return false;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(UiLogicSeparationGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(UiLogicSeparationGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(UiLogicSeparationGuardConst.freezedExtension)) {
      continue;
    }
    if (path.endsWith(UiLogicSeparationGuardConst.generatedRouteExtension)) {
      continue;
    }

    files.add(entity);
  }
  return files;
}

bool _isFeatureUiPath(String path) {
  if (!path.startsWith(
    UiLogicSeparationGuardConst.presentationFeaturesPrefix,
  )) {
    return false;
  }
  if (path.contains(UiLogicSeparationGuardConst.providersMarker)) {
    return false;
  }
  if (path.contains(UiLogicSeparationGuardConst.featureScreensMarker)) {
    return true;
  }
  if (path.contains(UiLogicSeparationGuardConst.featureWidgetsMarker)) {
    return true;
  }
  return false;
}

bool _hasAllowLineMarker({
  required List<String> lines,
  required int lineNumber,
}) {
  if (lineNumber <= 0 || lineNumber > lines.length) {
    return false;
  }
  return lines[lineNumber - 1].contains(
    UiLogicSeparationGuardConst.allowLineMarker,
  );
}

String _lineContentAt(List<String> lines, int lineNumber) {
  if (lineNumber <= 0 || lineNumber > lines.length) {
    return '';
  }
  return lines[lineNumber - 1].trim();
}

int _lineFromOffset(LineInfo lineInfo, int offset) {
  return lineInfo.getLocation(offset).lineNumber;
}

String _typeText(DartType? type) {
  if (type == null) {
    return '';
  }
  return type.getDisplayString();
}

String _elementName(Element? element) {
  if (element == null) {
    return '';
  }
  return element.name ?? '';
}

Element? _expressionElement(Expression expression) {
  if (expression is Identifier) {
    return expression.element;
  }
  if (expression is PrefixedIdentifier) {
    return expression.identifier.element;
  }
  if (expression is PropertyAccess) {
    return expression.propertyName.element;
  }
  return null;
}

String _elementLibraryUri(Element? element) {
  if (element == null) {
    return '';
  }
  final LibraryElement? library = element.library;
  if (library == null) {
    return '';
  }
  return library.uri.toString();
}

String _normalizePath(String rawPath) => rawPath.replaceAll('\\', '/');

String _toAbsoluteOsPath(String rawPath) {
  String normalized = rawPath.replaceAll('\\', Platform.pathSeparator);
  normalized = normalized.replaceAll('/', Platform.pathSeparator);

  final String absolutePath = File(normalized).absolute.path;
  if (!absolutePath.endsWith(Platform.pathSeparator)) {
    return absolutePath;
  }
  return absolutePath.substring(0, absolutePath.length - 1);
}
