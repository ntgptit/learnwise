import 'dart:io';

import 'package:yaml/yaml.dart';

class CoverageBudgetConst {
  const CoverageBudgetConst._();

  static const String coverageFilePath = 'coverage/lcov.info';
  static const String configPath = 'coverage_guard.yaml';
  static const String defaultLayerApp = 'app';
  static const String defaultLayerCore = 'core';
  static const String defaultLayerCommon = 'common';
  static const String defaultLayerFeatures = 'features';
  static const String defaultLayerOther = 'other';
}

class CoverageBudgetConfig {
  const CoverageBudgetConfig({
    required this.minGlobalLineCoveragePercent,
    required this.minLayerCoveragePercent,
  });

  final double minGlobalLineCoveragePercent;
  final Map<String, double> minLayerCoveragePercent;

  static CoverageBudgetConfig defaults() {
    return const CoverageBudgetConfig(
      minGlobalLineCoveragePercent: 20,
      minLayerCoveragePercent: <String, double>{
        CoverageBudgetConst.defaultLayerApp: 40,
        CoverageBudgetConst.defaultLayerCore: 25,
        CoverageBudgetConst.defaultLayerCommon: 3,
        CoverageBudgetConst.defaultLayerFeatures: 25,
        CoverageBudgetConst.defaultLayerOther: 15,
      },
    );
  }

  static CoverageBudgetConfig loadOrDefault() {
    final File configFile = File(CoverageBudgetConst.configPath);
    if (!configFile.existsSync()) {
      return defaults();
    }

    final dynamic document = loadYaml(configFile.readAsStringSync());
    if (document is! YamlMap) {
      return defaults();
    }

    double minGlobalLineCoveragePercent =
        defaults().minGlobalLineCoveragePercent;
    final dynamic globalRaw = document['minGlobalLineCoveragePercent'];
    if (globalRaw is num) {
      minGlobalLineCoveragePercent = globalRaw.toDouble();
    }

    Map<String, double> minLayerCoveragePercent = Map<String, double>.from(
      defaults().minLayerCoveragePercent,
    );
    final dynamic layerRaw = document['minLayerCoveragePercent'];
    if (layerRaw is YamlMap) {
      final Map<String, double> parsed = <String, double>{};
      for (final MapEntry<dynamic, dynamic> entry in layerRaw.entries) {
        final dynamic key = entry.key;
        final dynamic value = entry.value;
        if (key is! String || value is! num) {
          continue;
        }
        parsed[key] = value.toDouble();
      }

      if (parsed.isNotEmpty) {
        minLayerCoveragePercent = parsed;
      }
    }

    return CoverageBudgetConfig(
      minGlobalLineCoveragePercent: minGlobalLineCoveragePercent,
      minLayerCoveragePercent: minLayerCoveragePercent,
    );
  }
}

class _CoverageCounter {
  _CoverageCounter({required this.coveredLines, required this.totalLines});

  int coveredLines;
  int totalLines;

  double get coveredPercent {
    if (totalLines == 0) {
      return 100;
    }
    return (coveredLines * 100) / totalLines;
  }
}

class CoverageBudgetViolation {
  const CoverageBudgetViolation({required this.scope, required this.reason});

  final String scope;
  final String reason;
}

class CoverageBudgetReport {
  const CoverageBudgetReport({
    required this.globalCounter,
    required this.layerCounters,
  });

  final _CoverageCounter globalCounter;
  final Map<String, _CoverageCounter> layerCounters;
}

Future<void> main() async {
  final CoverageBudgetConfig config = CoverageBudgetConfig.loadOrDefault();
  final File coverageFile = File(CoverageBudgetConst.coverageFilePath);

  if (!coverageFile.existsSync()) {
    stderr.writeln(
      'Missing `${CoverageBudgetConst.coverageFilePath}`. '
      'Run `flutter test --coverage` first.',
    );
    exitCode = 1;
    return;
  }

  final CoverageBudgetReport report = await _parseCoverage(coverageFile);
  final List<CoverageBudgetViolation> violations = <CoverageBudgetViolation>[];

  _collectGlobalViolation(
    report: report,
    config: config,
    violations: violations,
  );
  _collectLayerViolations(
    report: report,
    config: config,
    violations: violations,
  );

  _printSummary(report);
  if (violations.isEmpty) {
    stdout.writeln('Coverage budget guard passed.');
    return;
  }

  stderr.writeln('Coverage budget guard failed.');
  for (final CoverageBudgetViolation violation in violations) {
    stderr.writeln('${violation.scope}: ${violation.reason}');
  }
  exitCode = 1;
}

Future<CoverageBudgetReport> _parseCoverage(File coverageFile) async {
  final List<String> lines = await coverageFile.readAsLines();

  final _CoverageCounter globalCounter = _CoverageCounter(
    coveredLines: 0,
    totalLines: 0,
  );
  final Map<String, _CoverageCounter> layerCounters =
      <String, _CoverageCounter>{};

  String? currentSourceFilePath;

  for (final String rawLine in lines) {
    if (rawLine.startsWith('SF:')) {
      currentSourceFilePath = _normalizePath(rawLine.substring(3).trim());
      continue;
    }

    if (!rawLine.startsWith('DA:')) {
      continue;
    }
    if (currentSourceFilePath == null) {
      continue;
    }

    final int? hitCount = _parseHitCount(rawLine);
    if (hitCount == null) {
      continue;
    }

    _accumulate(globalCounter, hitCount);
    final String layer = _resolveLayer(currentSourceFilePath);
    final _CoverageCounter layerCounter = layerCounters.putIfAbsent(
      layer,
      () => _CoverageCounter(coveredLines: 0, totalLines: 0),
    );
    _accumulate(layerCounter, hitCount);
  }

  return CoverageBudgetReport(
    globalCounter: globalCounter,
    layerCounters: layerCounters,
  );
}

int? _parseHitCount(String line) {
  final String payload = line.substring(3);
  final List<String> parts = payload.split(',');
  if (parts.length < 2) {
    return null;
  }
  return int.tryParse(parts[1]);
}

void _accumulate(_CoverageCounter counter, int hitCount) {
  counter.totalLines++;
  if (hitCount <= 0) {
    return;
  }
  counter.coveredLines++;
}

String _resolveLayer(String sourcePath) {
  final String normalized = _normalizePath(sourcePath);
  if (normalized.startsWith('lib/app/')) {
    return CoverageBudgetConst.defaultLayerApp;
  }
  if (normalized.startsWith('lib/core/')) {
    return CoverageBudgetConst.defaultLayerCore;
  }
  if (normalized.startsWith('lib/common/')) {
    return CoverageBudgetConst.defaultLayerCommon;
  }
  if (normalized.startsWith('lib/features/')) {
    return CoverageBudgetConst.defaultLayerFeatures;
  }
  return CoverageBudgetConst.defaultLayerOther;
}

void _collectGlobalViolation({
  required CoverageBudgetReport report,
  required CoverageBudgetConfig config,
  required List<CoverageBudgetViolation> violations,
}) {
  final double globalPercent = report.globalCounter.coveredPercent;
  if (globalPercent >= config.minGlobalLineCoveragePercent) {
    return;
  }

  violations.add(
    CoverageBudgetViolation(
      scope: 'global',
      reason:
          'Line coverage ${globalPercent.toStringAsFixed(2)}% is below '
          '${config.minGlobalLineCoveragePercent.toStringAsFixed(2)}%.',
    ),
  );
}

void _collectLayerViolations({
  required CoverageBudgetReport report,
  required CoverageBudgetConfig config,
  required List<CoverageBudgetViolation> violations,
}) {
  final List<String> sortedLayers = config.minLayerCoveragePercent.keys.toList()
    ..sort();

  for (final String layer in sortedLayers) {
    final double threshold = config.minLayerCoveragePercent[layer] ?? 0;
    final _CoverageCounter counter =
        report.layerCounters[layer] ??
        _CoverageCounter(coveredLines: 0, totalLines: 0);
    final double percent = counter.coveredPercent;
    if (percent >= threshold) {
      continue;
    }

    violations.add(
      CoverageBudgetViolation(
        scope: 'layer:$layer',
        reason:
            'Line coverage ${percent.toStringAsFixed(2)}% is below '
            '${threshold.toStringAsFixed(2)}%.',
      ),
    );
  }
}

void _printSummary(CoverageBudgetReport report) {
  stdout.writeln(
    'Global line coverage: '
    '${report.globalCounter.coveredLines}/${report.globalCounter.totalLines} '
    '(${report.globalCounter.coveredPercent.toStringAsFixed(2)}%).',
  );

  final List<String> sortedLayerNames = report.layerCounters.keys.toList()
    ..sort();
  for (final String layer in sortedLayerNames) {
    final _CoverageCounter counter = report.layerCounters[layer]!;
    stdout.writeln(
      'Layer $layer: ${counter.coveredLines}/${counter.totalLines} '
      '(${counter.coveredPercent.toStringAsFixed(2)}%).',
    );
  }
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
