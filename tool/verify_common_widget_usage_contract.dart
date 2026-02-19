import 'dart:io';

class CommonWidgetUsageGuardConst {
  const CommonWidgetUsageGuardConst._();

  static const String libDirectory = 'lib';
  static const String commonWidgetsPrefix = 'lib/common/widgets/';
  static const String baselinePath = 'tool/common_widget_usage_baseline.txt';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';
}

class CommonWidgetUsageViolation {
  const CommonWidgetUsageViolation({
    required this.id,
    required this.path,
    required this.line,
    required this.widgetName,
    required this.replacement,
  });

  final String id;
  final String path;
  final int line;
  final String widgetName;
  final String replacement;
}

Future<void> main(List<String> args) async {
  final bool writeBaseline = args.contains('--write-baseline');
  final Directory libDirectory = Directory(
    CommonWidgetUsageGuardConst.libDirectory,
  );
  if (!libDirectory.existsSync()) {
    stderr.writeln(
      'Missing `${CommonWidgetUsageGuardConst.libDirectory}` directory.',
    );
    exitCode = 1;
    return;
  }

  final List<CommonWidgetUsageViolation> allViolations = _collectViolations(
    libDirectory: libDirectory,
  );
  if (writeBaseline) {
    _writeBaseline(allViolations);
    stdout.writeln(
      'Wrote baseline with ${allViolations.length} entries to `${CommonWidgetUsageGuardConst.baselinePath}`.',
    );
    return;
  }

  final Set<String> baselineIds = _loadBaseline();
  final List<CommonWidgetUsageViolation> regressions =
      <CommonWidgetUsageViolation>[];
  for (final CommonWidgetUsageViolation violation in allViolations) {
    if (baselineIds.contains(violation.id)) {
      continue;
    }
    regressions.add(violation);
  }

  final Set<String> staleBaselineIds = _collectStaleBaselineIds(
    allViolations: allViolations,
    baselineIds: baselineIds,
  );
  if (regressions.isEmpty) {
    _printStaleBaselineHint(staleBaselineIds);
    stdout.writeln('Common widget usage contract passed.');
    return;
  }

  stderr.writeln('Common widget usage contract failed.');
  for (final CommonWidgetUsageViolation violation in regressions) {
    stderr.writeln(
      '${violation.path}:${violation.line}: '
      'Disallowed Flutter widget `${violation.widgetName}`. '
      'Use `${violation.replacement}` from `lib/common/widgets`.',
    );
  }
  _printStaleBaselineHint(staleBaselineIds);
  exitCode = 1;
}

List<CommonWidgetUsageViolation> _collectViolations({
  required Directory libDirectory,
}) {
  final List<CommonWidgetUsageViolation> violations =
      <CommonWidgetUsageViolation>[];
  final List<File> files = _collectSourceFiles(libDirectory);
  final List<_DisallowedWidgetRule> rules = _disallowedRules();

  for (final File file in files) {
    final String normalizedPath = _normalizePath(file.path);
    if (normalizedPath.startsWith(
      CommonWidgetUsageGuardConst.commonWidgetsPrefix,
    )) {
      continue;
    }
    final List<String> lines = file.readAsLinesSync();
    for (int index = 0; index < lines.length; index++) {
      final String line = _stripLineComment(lines[index]).trim();
      if (line.isEmpty) {
        continue;
      }
      for (final _DisallowedWidgetRule rule in rules) {
        if (!rule.pattern.hasMatch(line)) {
          continue;
        }
        final int lineNumber = index + 1;
        final String id = '$normalizedPath:$lineNumber:${rule.widgetName}';
        violations.add(
          CommonWidgetUsageViolation(
            id: id,
            path: normalizedPath,
            line: lineNumber,
            widgetName: rule.widgetName,
            replacement: rule.replacement,
          ),
        );
      }
    }
  }

  return violations;
}

List<File> _collectSourceFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final String path = _normalizePath(entity.path);
    if (!path.endsWith(CommonWidgetUsageGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(CommonWidgetUsageGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(CommonWidgetUsageGuardConst.freezedExtension)) {
      continue;
    }
    files.add(entity);
  }
  return files;
}

String _stripLineComment(String line) {
  final int index = line.indexOf('//');
  if (index < 0) {
    return line;
  }
  return line.substring(0, index);
}

List<_DisallowedWidgetRule> _disallowedRules() {
  return <_DisallowedWidgetRule>[
    _DisallowedWidgetRule(
      widgetName: 'TextField',
      replacement: 'AppTextField/TextBox/TextArea/SearchField',
      pattern: r'\bTextField\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'TextFormField',
      replacement: 'TextBox',
      pattern: r'\bTextFormField\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'FilledButton',
      replacement: 'PrimaryButton/TonalButton/ActionButton',
      pattern: r'\bFilledButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'ElevatedButton',
      replacement: 'PrimaryButton',
      pattern: r'\bElevatedButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'OutlinedButton',
      replacement: 'SecondaryButton',
      pattern: r'\bOutlinedButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'TextButton',
      replacement: 'AppTextButton',
      pattern: r'\bTextButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'IconButton',
      replacement: 'AppIconButton/CircleButton',
      pattern: r'\bIconButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'FloatingActionButton',
      replacement: 'AppFab',
      pattern: r'\bFloatingActionButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
  ];
}

Set<String> _loadBaseline() {
  final File baselineFile = File(CommonWidgetUsageGuardConst.baselinePath);
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

void _writeBaseline(List<CommonWidgetUsageViolation> violations) {
  final File baselineFile = File(CommonWidgetUsageGuardConst.baselinePath);
  final List<String> ids =
      violations.map((violation) => violation.id).toSet().toList()..sort();
  baselineFile.writeAsStringSync('${ids.join('\n')}\n');
}

Set<String> _collectStaleBaselineIds({
  required List<CommonWidgetUsageViolation> allViolations,
  required Set<String> baselineIds,
}) {
  final Set<String> violationIds = allViolations
      .map((violation) => violation.id)
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

void _printStaleBaselineHint(Set<String> staleBaselineIds) {
  if (staleBaselineIds.isEmpty) {
    return;
  }
  final List<String> sortedStaleIds = staleBaselineIds.toList()..sort();
  stdout.writeln(
    'Stale baseline entries detected (${sortedStaleIds.length}). '
    'Consider cleaning `${CommonWidgetUsageGuardConst.baselinePath}`.',
  );
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}

class _DisallowedWidgetRule {
  _DisallowedWidgetRule({
    required this.widgetName,
    required this.replacement,
    required String pattern,
  }) : pattern = RegExp(pattern);

  final String widgetName;
  final String replacement;
  final RegExp pattern;
}
