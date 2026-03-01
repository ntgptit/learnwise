import 'dart:io';

class FeatureArchitectureGuardConst {
  const FeatureArchitectureGuardConst._();

  static const String featuresRoot = 'lib/presentation/features';
  static const String dartExtension = '.dart';
  static const String lineCommentPrefix = '//';

  static const String providersDir = 'providers';
  static const String statesDir = 'states';
  static const String screensDir = 'screens';
  static const String widgetsDir = 'widgets';
  static const String blocksDir = 'blocks';
  static const String dialogsDir = 'dialogs';
  static const String widgetStatesDir = 'states';

  static const List<String> forbiddenUiImportSnippets = <String>[
    '/data/',
    '/repositories/',
    '/datasources/',
  ];

  static const String allowProviderUiDiToken =
      'feature-architecture-guard: allow_ui_di';
}

class ArchitectureViolation {
  const ArchitectureViolation({
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
  final Directory root = Directory(FeatureArchitectureGuardConst.featuresRoot);
  if (!root.existsSync()) {
    stderr.writeln(
      'Missing `${FeatureArchitectureGuardConst.featuresRoot}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<Directory> featureDirs = root
      .listSync()
      .whereType<Directory>()
      .toList(growable: false);

  final List<ArchitectureViolation> violations = <ArchitectureViolation>[];

  for (final Directory featureDir in featureDirs) {
    await _checkFeature(featureDir, violations);
  }

  if (violations.isEmpty) {
    stdout.writeln('Feature architecture contract passed.');
    return;
  }

  stderr.writeln('Feature architecture contract failed.');
  for (final ArchitectureViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

Future<void> _checkFeature(
  Directory featureDir,
  List<ArchitectureViolation> violations,
) async {
  final String featurePath = _normalizePath(featureDir.path);
  final String featureName = featurePath.split('/').last;
  final String featureClassPrefix = _toPascalCase(featureName);

  final Directory providers = Directory(
    '${featureDir.path}/${FeatureArchitectureGuardConst.providersDir}',
  );
  final Directory screens = Directory(
    '${featureDir.path}/${FeatureArchitectureGuardConst.screensDir}',
  );
  final Directory screenWidgets = Directory(
    '${featureDir.path}/${FeatureArchitectureGuardConst.screensDir}/'
    '${FeatureArchitectureGuardConst.widgetsDir}',
  );

  final Directory providerStates = Directory(
    '${providers.path}/${FeatureArchitectureGuardConst.statesDir}',
  );
  final Directory widgetsBlocks = Directory(
    '${screenWidgets.path}/${FeatureArchitectureGuardConst.blocksDir}',
  );
  final Directory widgetsDialogs = Directory(
    '${screenWidgets.path}/${FeatureArchitectureGuardConst.dialogsDir}',
  );
  final Directory widgetsStates = Directory(
    '${screenWidgets.path}/${FeatureArchitectureGuardConst.widgetStatesDir}',
  );

  _requireDirectory(
    providers,
    violations,
    featurePath,
    'Missing providers/ directory.',
  );
  _requireDirectory(
    providerStates,
    violations,
    featurePath,
    'Missing providers/states/ directory.',
  );
  _requireDirectory(
    screens,
    violations,
    featurePath,
    'Missing screens/ directory.',
  );
  _requireDirectory(
    screenWidgets,
    violations,
    featurePath,
    'Missing screens/widgets/ directory.',
  );
  _requireDirectory(
    widgetsBlocks,
    violations,
    featurePath,
    'Missing screens/widgets/blocks/ directory.',
  );
  _requireDirectory(
    widgetsDialogs,
    violations,
    featurePath,
    'Missing screens/widgets/dialogs/ directory.',
  );
  _requireDirectory(
    widgetsStates,
    violations,
    featurePath,
    'Missing screens/widgets/states/ directory.',
  );

  final File providerFile = File(
    '${providers.path}/${featureName}_provider.dart',
  );
  final File stateFile = File(
    '${providerStates.path}/${featureName}_state.dart',
  );
  final File screenFile = File('${screens.path}/${featureName}_screen.dart');
  final File contentFile = File('${screens.path}/${featureName}_content.dart');

  _requireFile(
    providerFile,
    violations,
    featurePath,
    'Missing providers/${featureName}_provider.dart.',
  );
  _requireFile(
    stateFile,
    violations,
    featurePath,
    'Missing providers/states/${featureName}_state.dart.',
  );
  _requireFile(
    screenFile,
    violations,
    featurePath,
    'Missing screens/${featureName}_screen.dart.',
  );
  _requireFile(
    contentFile,
    violations,
    featurePath,
    'Missing screens/${featureName}_content.dart.',
  );

  await _checkProviderFile(
    providerFile: providerFile,
    featureClassPrefix: featureClassPrefix,
    violations: violations,
  );
  await _checkStateFile(
    stateFile: stateFile,
    featureClassPrefix: featureClassPrefix,
    violations: violations,
  );
  await _checkScreenFile(
    screenFile: screenFile,
    screenWidgetsDir: screenWidgets,
    providerFile: providerFile,
    featureName: featureName,
    featureClassPrefix: featureClassPrefix,
    violations: violations,
  );
  await _checkContentFile(
    contentFile: contentFile,
    featureClassPrefix: featureClassPrefix,
    violations: violations,
  );
  await _checkUiBoundary(screens, violations);
  await _checkNoTextConstantClass(
    featureDir: featureDir,
    violations: violations,
  );
}

void _requireDirectory(
  Directory directory,
  List<ArchitectureViolation> violations,
  String filePath,
  String reason,
) {
  if (directory.existsSync()) {
    return;
  }
  violations.add(
    ArchitectureViolation(
      filePath: filePath,
      lineNumber: 1,
      reason: reason,
      lineContent: filePath,
    ),
  );
}

void _requireFile(
  File file,
  List<ArchitectureViolation> violations,
  String filePath,
  String reason,
) {
  if (file.existsSync()) {
    return;
  }
  violations.add(
    ArchitectureViolation(
      filePath: filePath,
      lineNumber: 1,
      reason: reason,
      lineContent: filePath,
    ),
  );
}

Future<void> _checkProviderFile({
  required File providerFile,
  required String featureClassPrefix,
  required List<ArchitectureViolation> violations,
}) async {
  if (!providerFile.existsSync()) {
    return;
  }

  final String path = _normalizePath(providerFile.path);
  final List<String> lines = await providerFile.readAsLines();
  final String content = lines.join('\n');
  final bool allowProviderUiImport = content.contains(
    FeatureArchitectureGuardConst.allowProviderUiDiToken,
  );

  if (!content.contains('@Riverpod') && !content.contains('@riverpod')) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason: 'Provider file must use @Riverpod/@riverpod annotation.',
        lineContent: path,
      ),
    );
  }

  if (!content.contains("part '") || !content.contains('.g.dart')) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason: 'Provider file must declare generated part .g.dart.',
        lineContent: path,
      ),
    );
  }

  final String expectedAsyncProviderClass =
      '${featureClassPrefix}AsyncController';
  final String expectedSyncProviderClass = '${featureClassPrefix}Controller';
  final bool hasAsyncController = RegExp(
    'class\\s+$expectedAsyncProviderClass\\s+extends\\s+_\\\$'
    '$expectedAsyncProviderClass\\b',
  ).hasMatch(content);
  final bool hasSyncController = RegExp(
    'class\\s+$expectedSyncProviderClass\\s+extends\\s+_\\\$'
    '$expectedSyncProviderClass\\b',
  ).hasMatch(content);
  if (!hasAsyncController && !hasSyncController) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason:
            'Provider class name must be `${featureClassPrefix}AsyncController` or `${featureClassPrefix}Controller` and extend generated base.',
        lineContent: path,
      ),
    );
  }

  for (int i = 0; i < lines.length; i++) {
    final String line = _stripLineComment(lines[i]).trim();
    if (!line.startsWith('import ')) {
      continue;
    }
    if (line.contains('package:flutter/') && !allowProviderUiImport) {
      violations.add(
        ArchitectureViolation(
          filePath: path,
          lineNumber: i + 1,
          reason: 'Provider layer must not depend on Flutter UI packages.',
          lineContent: lines[i].trim(),
        ),
      );
    }
  }
}

Future<void> _checkStateFile({
  required File stateFile,
  required String featureClassPrefix,
  required List<ArchitectureViolation> violations,
}) async {
  if (!stateFile.existsSync()) {
    return;
  }

  final String path = _normalizePath(stateFile.path);
  final String content = await stateFile.readAsString();

  if (!content.contains('@freezed')) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason: 'State file must use Freezed (@freezed).',
        lineContent: path,
      ),
    );
  }

  if (!content.contains("part '") || !content.contains('.freezed.dart')) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason: 'State file must declare generated part .freezed.dart.',
        lineContent: path,
      ),
    );
  }

  final String expectedStateClass = '${featureClassPrefix}State';
  if (!RegExp(
    'abstract\\s+class\\s+$expectedStateClass\\s+with\\s+_\\\$'
    '$expectedStateClass\\b',
  ).hasMatch(content)) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason:
            'State class name must be `${featureClassPrefix}State` and use generated mixin.',
        lineContent: path,
      ),
    );
  }
}

Future<void> _checkScreenFile({
  required File screenFile,
  required Directory screenWidgetsDir,
  required File providerFile,
  required String featureName,
  required String featureClassPrefix,
  required List<ArchitectureViolation> violations,
}) async {
  if (!screenFile.existsSync()) {
    return;
  }

  final String path = _normalizePath(screenFile.path);
  final String content = await screenFile.readAsString();
  final String expectedScreenClass = '${featureClassPrefix}Screen';
  if (!RegExp('class\\s+$expectedScreenClass\\b').hasMatch(content)) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason: 'Screen class name must be `${featureClassPrefix}Screen`.',
        lineContent: path,
      ),
    );
  }

  final bool hasProviderWatch = content.contains('ref.watch(');
  if (!hasProviderWatch) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason:
            'Screen file must orchestrate state by reading provider (ref.watch).',
        lineContent: path,
      ),
    );
  }

  bool hasNavigationWidget =
      content.contains('NavigationBar(') || content.contains('NavigationRail(');
  if (!hasNavigationWidget) {
    hasNavigationWidget = await _hasNavigationWidgetInWidgets(screenWidgetsDir);
  }
  if (!hasNavigationWidget) {
    if (!content.contains('AsyncValue<')) {
      violations.add(
        ArchitectureViolation(
          filePath: path,
          lineNumber: 1,
          reason: 'Screen file must orchestrate AsyncValue state.',
          lineContent: path,
        ),
      );
    }

    final bool hasAsyncRender =
        content.contains('.when(') || content.contains('.whenWithLoading(');
    if (!hasAsyncRender) {
      violations.add(
        ArchitectureViolation(
          filePath: path,
          lineNumber: 1,
          reason:
              'Screen file must render AsyncValue with .when/.whenWithLoading.',
          lineContent: path,
        ),
      );
    }
  }

  await _checkTabPageDiAndFineGrained(
    screenPath: path,
    screenContent: content,
    providerFile: providerFile,
    featureName: featureName,
    violations: violations,
  );
}

Future<bool> _hasNavigationWidgetInWidgets(Directory screenWidgetsDir) async {
  if (!screenWidgetsDir.existsSync()) {
    return false;
  }

  final List<FileSystemEntity> entities = screenWidgetsDir.listSync(
    recursive: true,
  );
  for (final FileSystemEntity entity in entities) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(FeatureArchitectureGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      continue;
    }

    final String content = await entity.readAsString();
    final bool hasNavigationBar = content.contains('NavigationBar(');
    if (hasNavigationBar) {
      return true;
    }
    final bool hasNavigationRail = content.contains('NavigationRail(');
    if (hasNavigationRail) {
      return true;
    }
  }
  return false;
}

Future<void> _checkContentFile({
  required File contentFile,
  required String featureClassPrefix,
  required List<ArchitectureViolation> violations,
}) async {
  if (!contentFile.existsSync()) {
    return;
  }

  final String path = _normalizePath(contentFile.path);
  final String content = await contentFile.readAsString();
  final String expectedContentClass = '${featureClassPrefix}Content';
  if (!RegExp('class\\s+$expectedContentClass\\b').hasMatch(content)) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason: 'Content class name must be `${featureClassPrefix}Content`.',
        lineContent: path,
      ),
    );
  }

  if (content.contains('AsyncValue<')) {
    violations.add(
      ArchitectureViolation(
        filePath: path,
        lineNumber: 1,
        reason: 'Content file must not orchestrate AsyncValue directly.',
        lineContent: path,
      ),
    );
  }
}

Future<void> _checkUiBoundary(
  Directory screensDir,
  List<ArchitectureViolation> violations,
) async {
  if (!screensDir.existsSync()) {
    return;
  }

  final List<FileSystemEntity> entities = screensDir.listSync(recursive: true);
  for (final FileSystemEntity entity in entities) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(FeatureArchitectureGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      continue;
    }

    final List<String> lines = await entity.readAsLines();
    for (int i = 0; i < lines.length; i++) {
      final String line = _stripLineComment(lines[i]).trim();
      if (!line.startsWith('import ')) {
        continue;
      }

      for (final String forbidden
          in FeatureArchitectureGuardConst.forbiddenUiImportSnippets) {
        if (!line.contains(forbidden)) {
          continue;
        }
        violations.add(
          ArchitectureViolation(
            filePath: path,
            lineNumber: i + 1,
            reason:
                'UI layer (screens/widgets) must not import data/repository/datasource.',
            lineContent: lines[i].trim(),
          ),
        );
      }
    }
  }
}

String _stripLineComment(String line) {
  final int commentIndex = line.indexOf(
    FeatureArchitectureGuardConst.lineCommentPrefix,
  );
  if (commentIndex < 0) {
    return line;
  }
  return line.substring(0, commentIndex);
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

Future<void> _checkTabPageDiAndFineGrained({
  required String screenPath,
  required String screenContent,
  required File providerFile,
  required String featureName,
  required List<ArchitectureViolation> violations,
}) async {
  final bool hasNavWidgets =
      screenContent.contains('NavigationBar(') ||
      screenContent.contains('NavigationRail(');
  if (!hasNavWidgets) {
    return;
  }

  final String featureCamel = _toCamelCase(featureName);
  final String selectedIndexProvider = '${featureCamel}SelectedIndexProvider';
  final String selectedTabProvider = '${featureCamel}SelectedTabProvider';
  final String tabPageProvider = '${featureCamel}TabPageProvider';

  if (!screenContent.contains(selectedIndexProvider)) {
    violations.add(
      ArchitectureViolation(
        filePath: screenPath,
        lineNumber: 1,
        reason:
            'Fine-grained rule: screen with Navigation must use `${featureCamel}SelectedIndexProvider`.',
        lineContent: screenPath,
      ),
    );
  }
  if (!screenContent.contains(selectedTabProvider)) {
    violations.add(
      ArchitectureViolation(
        filePath: screenPath,
        lineNumber: 1,
        reason:
            'Fine-grained rule: screen with Navigation must use `${featureCamel}SelectedTabProvider`.',
        lineContent: screenPath,
      ),
    );
  }
  if (!screenContent.contains(tabPageProvider)) {
    violations.add(
      ArchitectureViolation(
        filePath: screenPath,
        lineNumber: 1,
        reason:
            'Tab/Page DI rule: screen with Navigation must use `${featureCamel}TabPageProvider`.',
        lineContent: screenPath,
      ),
    );
  }

  if (RegExp(r'switch\s*\(\s*selectedIndex\s*\)').hasMatch(screenContent) ||
      RegExp(r'if\s*\(\s*selectedIndex\s*==').hasMatch(screenContent)) {
    violations.add(
      ArchitectureViolation(
        filePath: screenPath,
        lineNumber: 1,
        reason:
            'Tab/Page DI rule: do not hardcode selectedIndex switch/if in screen. Move mapping to provider.',
        lineContent: screenPath,
      ),
    );
  }

  if (!providerFile.existsSync()) {
    violations.add(
      ArchitectureViolation(
        filePath: screenPath,
        lineNumber: 1,
        reason:
            'Tab/Page DI rule: missing provider file to host selectedIndex/title/page derived providers.',
        lineContent: screenPath,
      ),
    );
    return;
  }

  final String providerPath = _normalizePath(providerFile.path);
  final String providerContent = await providerFile.readAsString();
  final List<String> requiredProviderFns = <String>[
    '${featureCamel}SelectedIndex(',
    '${featureCamel}SelectedTab(',
    '${featureCamel}TabPage(',
  ];
  for (final String requiredFn in requiredProviderFns) {
    if (providerContent.contains(requiredFn)) {
      continue;
    }
    violations.add(
      ArchitectureViolation(
        filePath: providerPath,
        lineNumber: 1,
        reason:
            'Tab/Page DI rule: provider must declare `${requiredFn.substring(0, requiredFn.length - 1)}`.',
        lineContent: providerPath,
      ),
    );
  }
}

Future<void> _checkNoTextConstantClass({
  required Directory featureDir,
  required List<ArchitectureViolation> violations,
}) async {
  final List<FileSystemEntity> entities = featureDir.listSync(recursive: true);
  for (final FileSystemEntity entity in entities) {
    if (entity is! File) {
      continue;
    }
    final String path = _normalizePath(entity.path);
    if (!path.endsWith(FeatureArchitectureGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith('.g.dart') || path.endsWith('.freezed.dart')) {
      continue;
    }

    final List<String> lines = await entity.readAsLines();
    for (int i = 0; i < lines.length; i++) {
      final String line = _stripLineComment(lines[i]).trim();
      if (!RegExp(r'class\s+\w*ScreenText\b').hasMatch(line)) {
        continue;
      }
      violations.add(
        ArchitectureViolation(
          filePath: path,
          lineNumber: i + 1,
          reason:
              'Do not define ScreenText constants. Use l10n (AppLocalizations) for user-visible text.',
          lineContent: lines[i].trim(),
        ),
      );
    }
  }
}

String _toPascalCase(String value) {
  final List<String> parts = value
      .split(RegExp(r'[_\-\s]+'))
      .where((String part) => part.isNotEmpty)
      .toList(growable: false);
  return parts
      .map(
        (String part) =>
            '${part[0].toUpperCase()}${part.substring(1).toLowerCase()}',
      )
      .join();
}

String _toCamelCase(String value) {
  final String pascal = _toPascalCase(value);
  if (pascal.isEmpty) {
    return pascal;
  }
  return '${pascal[0].toLowerCase()}${pascal.substring(1)}';
}
