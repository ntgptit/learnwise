import 'dart:io';

import 'package:yaml/yaml.dart';

class TestPyramidGuardConst {
  const TestPyramidGuardConst._();

  static const String featuresDirectory = 'lib/features';
  static const String featureTestsDirectory = 'test/features';
  static const String integrationTestsDirectory = 'integration_test';
  static const String configPath = 'test_pyramid_guard.yaml';
  static const String baselinePath = 'tool/test_pyramid_baseline.txt';

  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
}

class TestPyramidGuardConfig {
  const TestPyramidGuardConfig({
    required this.minViewModelTestsPerFeature,
    required this.minDomainTestsPerFeature,
    required this.minViewTestsPerFeature,
    required this.requireIntegrationTest,
    required this.minIntegrationTests,
  });

  final int minViewModelTestsPerFeature;
  final int minDomainTestsPerFeature;
  final int minViewTestsPerFeature;
  final bool requireIntegrationTest;
  final int minIntegrationTests;

  static TestPyramidGuardConfig defaults() {
    return const TestPyramidGuardConfig(
      minViewModelTestsPerFeature: 1,
      minDomainTestsPerFeature: 1,
      minViewTestsPerFeature: 1,
      requireIntegrationTest: true,
      minIntegrationTests: 1,
    );
  }

  static TestPyramidGuardConfig loadOrDefault() {
    final File configFile = File(TestPyramidGuardConst.configPath);
    if (!configFile.existsSync()) {
      return defaults();
    }

    final dynamic document = loadYaml(configFile.readAsStringSync());
    if (document is! YamlMap) {
      return defaults();
    }

    final int minViewModelTestsPerFeature = _readInt(
      document: document,
      key: 'minViewModelTestsPerFeature',
      fallback: defaults().minViewModelTestsPerFeature,
    );
    final int minDomainTestsPerFeature = _readInt(
      document: document,
      key: 'minDomainTestsPerFeature',
      fallback: defaults().minDomainTestsPerFeature,
    );
    final int minViewTestsPerFeature = _readInt(
      document: document,
      key: 'minViewTestsPerFeature',
      fallback: defaults().minViewTestsPerFeature,
    );

    bool requireIntegrationTest = defaults().requireIntegrationTest;
    final dynamic integrationRequiredRaw = document['requireIntegrationTest'];
    if (integrationRequiredRaw is bool) {
      requireIntegrationTest = integrationRequiredRaw;
    }

    final int minIntegrationTests = _readInt(
      document: document,
      key: 'minIntegrationTests',
      fallback: defaults().minIntegrationTests,
    );

    return TestPyramidGuardConfig(
      minViewModelTestsPerFeature: minViewModelTestsPerFeature,
      minDomainTestsPerFeature: minDomainTestsPerFeature,
      minViewTestsPerFeature: minViewTestsPerFeature,
      requireIntegrationTest: requireIntegrationTest,
      minIntegrationTests: minIntegrationTests,
    );
  }
}

class FeatureShape {
  const FeatureShape({
    required this.name,
    required this.hasViewModel,
    required this.hasDomainLogic,
    required this.hasView,
  });

  final String name;
  final bool hasViewModel;
  final bool hasDomainLogic;
  final bool hasView;
}

class FeatureTestShape {
  const FeatureTestShape({
    required this.viewModelTests,
    required this.domainTests,
    required this.viewTests,
  });

  final int viewModelTests;
  final int domainTests;
  final int viewTests;
}

class TestPyramidViolation {
  const TestPyramidViolation({
    required this.id,
    required this.scope,
    required this.reason,
  });

  final String id;
  final String scope;
  final String reason;
}

Future<void> main(List<String> args) async {
  final bool writeBaseline = args.contains('--write-baseline');
  final TestPyramidGuardConfig config = TestPyramidGuardConfig.loadOrDefault();

  final Directory featuresDirectory = Directory(
    TestPyramidGuardConst.featuresDirectory,
  );
  if (!featuresDirectory.existsSync()) {
    stderr.writeln(
      'Missing `${TestPyramidGuardConst.featuresDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<FeatureShape> features = _collectFeatureShapes(featuresDirectory);
  if (features.isEmpty) {
    stdout.writeln('Test pyramid guard skipped: no feature folders found.');
    return;
  }

  final Map<String, FeatureTestShape> featureTestShapes =
      _collectFeatureTestShapes(
        featureNames: features
            .map((FeatureShape feature) => feature.name)
            .toList(),
      );
  final int integrationTests = _countIntegrationTests();

  final List<TestPyramidViolation> allViolations = _collectPyramidViolations(
    features: features,
    featureTestShapes: featureTestShapes,
    integrationTests: integrationTests,
    config: config,
  );

  if (writeBaseline) {
    _writeBaseline(allViolations);
    stdout.writeln(
      'Wrote baseline with ${allViolations.length} entries '
      'to `${TestPyramidGuardConst.baselinePath}`.',
    );
    return;
  }

  final Set<String> baselineIds = _loadBaseline();
  final List<TestPyramidViolation> regressionViolations =
      _collectRegressionViolations(
        allViolations: allViolations,
        baselineIds: baselineIds,
      );
  final Set<String> staleBaselineIds = _collectStaleBaselineIds(
    allViolations: allViolations,
    baselineIds: baselineIds,
  );

  _printSummary(
    features: features,
    allViolations: allViolations,
    staleBaselineIds: staleBaselineIds,
    integrationTests: integrationTests,
  );

  if (regressionViolations.isEmpty) {
    stdout.writeln('Test pyramid guard passed.');
    return;
  }

  stderr.writeln('Test pyramid guard failed.');
  for (final TestPyramidViolation violation in regressionViolations) {
    stderr.writeln('${violation.scope}: ${violation.reason}');
  }

  exitCode = 1;
}

List<FeatureShape> _collectFeatureShapes(Directory featuresDirectory) {
  final List<FeatureShape> features = <FeatureShape>[];
  final List<FileSystemEntity> children = featuresDirectory.listSync();
  final List<Directory> featureDirectories =
      children.whereType<Directory>().toList()
        ..sort((Directory a, Directory b) => a.path.compareTo(b.path));

  for (final Directory featureDirectory in featureDirectories) {
    final String featureName = featureDirectory
        .uri
        .pathSegments[featureDirectory.uri.pathSegments.length - 2];
    final List<String> filePaths = _collectDartPaths(featureDirectory);
    if (filePaths.isEmpty) {
      continue;
    }

    final bool hasViewModel = filePaths.any(
      (String path) => path.contains('/viewmodel/'),
    );
    final bool hasDomainLogic = filePaths.any(
      (String path) =>
          path.contains('/repository/') ||
          path.contains('/service/') ||
          path.contains('/engine/'),
    );
    final bool hasView = filePaths.any(
      (String path) => path.contains('/view/'),
    );

    features.add(
      FeatureShape(
        name: featureName,
        hasViewModel: hasViewModel,
        hasDomainLogic: hasDomainLogic,
        hasView: hasView,
      ),
    );
  }

  return features;
}

Map<String, FeatureTestShape> _collectFeatureTestShapes({
  required List<String> featureNames,
}) {
  final Map<String, FeatureTestShape> result = <String, FeatureTestShape>{};
  for (final String featureName in featureNames) {
    final Directory featureTestDirectory = Directory(
      '${TestPyramidGuardConst.featureTestsDirectory}/$featureName',
    );

    if (!featureTestDirectory.existsSync()) {
      result[featureName] = const FeatureTestShape(
        viewModelTests: 0,
        domainTests: 0,
        viewTests: 0,
      );
      continue;
    }

    final List<String> testPaths = _collectDartPaths(featureTestDirectory)
        .where((String path) => path.endsWith('_test.dart'))
        .toList(growable: false);

    int viewModelTests = 0;
    int domainTests = 0;
    int viewTests = 0;

    for (final String testPath in testPaths) {
      final String fileName = testPath.split('/').last;
      if (fileName.contains('viewmodel')) {
        viewModelTests++;
      }
      if (_isDomainTestFile(fileName)) {
        domainTests++;
      }
      if (_isViewTestFile(path: testPath, fileName: fileName)) {
        viewTests++;
      }
    }

    result[featureName] = FeatureTestShape(
      viewModelTests: viewModelTests,
      domainTests: domainTests,
      viewTests: viewTests,
    );
  }
  return result;
}

bool _isDomainTestFile(String fileName) {
  if (fileName.contains('repository')) {
    return true;
  }
  if (fileName.contains('service')) {
    return true;
  }
  if (fileName.contains('engine')) {
    return true;
  }
  return false;
}

bool _isViewTestFile({required String path, required String fileName}) {
  if (path.contains('/view/')) {
    return true;
  }
  if (fileName.contains('_flow_test.dart')) {
    return true;
  }
  if (fileName.contains('_screen_test.dart')) {
    return true;
  }
  return false;
}

int _countIntegrationTests() {
  final Directory integrationDirectory = Directory(
    TestPyramidGuardConst.integrationTestsDirectory,
  );
  if (!integrationDirectory.existsSync()) {
    return 0;
  }

  final List<String> integrationPaths = _collectDartPaths(integrationDirectory);
  final int count = integrationPaths
      .where((String path) => path.endsWith('_test.dart'))
      .length;
  return count;
}

List<TestPyramidViolation> _collectPyramidViolations({
  required List<FeatureShape> features,
  required Map<String, FeatureTestShape> featureTestShapes,
  required int integrationTests,
  required TestPyramidGuardConfig config,
}) {
  final List<TestPyramidViolation> violations = <TestPyramidViolation>[];

  for (final FeatureShape feature in features) {
    final FeatureTestShape tests =
        featureTestShapes[feature.name] ??
        const FeatureTestShape(viewModelTests: 0, domainTests: 0, viewTests: 0);

    if (feature.hasViewModel &&
        tests.viewModelTests < config.minViewModelTestsPerFeature) {
      violations.add(
        TestPyramidViolation(
          id: 'feature:${feature.name}:missing_viewmodel_tests',
          scope: 'feature:${feature.name}',
          reason:
              'Missing minimum viewmodel tests '
              '(${tests.viewModelTests}/${config.minViewModelTestsPerFeature}).',
        ),
      );
    }

    if (feature.hasDomainLogic &&
        tests.domainTests < config.minDomainTestsPerFeature) {
      violations.add(
        TestPyramidViolation(
          id: 'feature:${feature.name}:missing_domain_tests',
          scope: 'feature:${feature.name}',
          reason:
              'Missing minimum domain tests '
              '(${tests.domainTests}/${config.minDomainTestsPerFeature}).',
        ),
      );
    }

    if (feature.hasView && tests.viewTests < config.minViewTestsPerFeature) {
      violations.add(
        TestPyramidViolation(
          id: 'feature:${feature.name}:missing_view_tests',
          scope: 'feature:${feature.name}',
          reason:
              'Missing minimum view/flow tests '
              '(${tests.viewTests}/${config.minViewTestsPerFeature}).',
        ),
      );
    }
  }

  final bool hasViewFeature = features.any(
    (FeatureShape feature) => feature.hasView,
  );
  if (!config.requireIntegrationTest) {
    return violations;
  }
  if (!hasViewFeature) {
    return violations;
  }
  if (integrationTests >= config.minIntegrationTests) {
    return violations;
  }

  violations.add(
    TestPyramidViolation(
      id: 'global:missing_integration_tests',
      scope: 'global',
      reason:
          'Missing minimum integration tests '
          '($integrationTests/${config.minIntegrationTests}).',
    ),
  );
  return violations;
}

Set<String> _loadBaseline() {
  final File baselineFile = File(TestPyramidGuardConst.baselinePath);
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

void _writeBaseline(List<TestPyramidViolation> violations) {
  final File baselineFile = File(TestPyramidGuardConst.baselinePath);
  final List<String> sortedIds =
      violations
          .map((TestPyramidViolation violation) => violation.id)
          .toSet()
          .toList()
        ..sort();
  baselineFile.writeAsStringSync('${sortedIds.join('\n')}\n');
}

List<TestPyramidViolation> _collectRegressionViolations({
  required List<TestPyramidViolation> allViolations,
  required Set<String> baselineIds,
}) {
  final List<TestPyramidViolation> regressions = <TestPyramidViolation>[];
  for (final TestPyramidViolation violation in allViolations) {
    if (baselineIds.contains(violation.id)) {
      continue;
    }
    regressions.add(violation);
  }
  return regressions;
}

Set<String> _collectStaleBaselineIds({
  required List<TestPyramidViolation> allViolations,
  required Set<String> baselineIds,
}) {
  final Set<String> violationIds = allViolations
      .map((TestPyramidViolation violation) => violation.id)
      .toSet();

  final Set<String> staleIds = <String>{};
  for (final String baselineId in baselineIds) {
    if (violationIds.contains(baselineId)) {
      continue;
    }
    staleIds.add(baselineId);
  }
  return staleIds;
}

void _printSummary({
  required List<FeatureShape> features,
  required List<TestPyramidViolation> allViolations,
  required Set<String> staleBaselineIds,
  required int integrationTests,
}) {
  stdout.writeln(
    'Test pyramid summary: features=${features.length}, '
    'violations=${allViolations.length}, '
    'integration_tests=$integrationTests.',
  );

  if (staleBaselineIds.isEmpty) {
    return;
  }

  final List<String> sortedStaleIds = staleBaselineIds.toList()..sort();
  stdout.writeln(
    'Stale baseline entries detected (${sortedStaleIds.length}). '
    'Consider cleaning `${TestPyramidGuardConst.baselinePath}`.',
  );
  for (final String staleId in sortedStaleIds) {
    stdout.writeln('  - $staleId');
  }
}

List<String> _collectDartPaths(Directory directory) {
  final List<String> paths = <String>[];
  for (final FileSystemEntity entity in directory.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }

    final String path = _normalizePath(entity.path);
    if (!path.endsWith(TestPyramidGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(TestPyramidGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(TestPyramidGuardConst.freezedExtension)) {
      continue;
    }

    paths.add(path);
  }
  return paths;
}

int _readInt({
  required YamlMap document,
  required String key,
  required int fallback,
}) {
  final dynamic raw = document[key];
  if (raw is int) {
    return raw;
  }
  if (raw is String) {
    final int? parsed = int.tryParse(raw);
    if (parsed != null) {
      return parsed;
    }
  }
  return fallback;
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
