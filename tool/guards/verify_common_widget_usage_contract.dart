import 'dart:io';

class CommonWidgetUsageGuardConst {
  const CommonWidgetUsageGuardConst._();

  static const String libDirectory = 'lib';
  static const String presentationFeaturesPrefix = 'lib/presentation/features/';
  static const String featureScreensMarker = '/screens/';
  static const String featureWidgetsMarker = '/widgets/';
  static const String providersMarker = '/providers/';
  static const List<String> sharedWidgetsPrefixes = <String>[
    'lib/core/widgets/',
    'lib/presentation/shared/widgets/',
  ];
  static const String coreThemesPrefix = 'lib/core/themes/';
  static const String allowMaterialWidgetOverrideMarker =
      'common-widget-usage-guard: allow-material-widget';
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
      'Use `${violation.replacement}` from shared widget directories.',
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
    if (_isSharedWidgetPath(normalizedPath)) {
      continue;
    }
    if (normalizedPath.startsWith(
      CommonWidgetUsageGuardConst.coreThemesPrefix,
    )) {
      continue;
    }
    final List<String> lines = file.readAsLinesSync();
    for (int index = 0; index < lines.length; index++) {
      final String line = _stripLineComment(lines[index]).trim();
      if (line.isEmpty) {
        continue;
      }
      if (line.contains(
        CommonWidgetUsageGuardConst.allowMaterialWidgetOverrideMarker,
      )) {
        continue;
      }
      for (final _DisallowedWidgetRule rule in rules) {
        if (rule.featureUiOnly && !_isFeatureUiPath(normalizedPath)) {
          continue;
        }
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

bool _isSharedWidgetPath(String path) {
  for (final String prefix
      in CommonWidgetUsageGuardConst.sharedWidgetsPrefixes) {
    if (path.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}

bool _isFeatureUiPath(String path) {
  if (!path.startsWith(
    CommonWidgetUsageGuardConst.presentationFeaturesPrefix,
  )) {
    return false;
  }
  if (path.contains(CommonWidgetUsageGuardConst.providersMarker)) {
    return false;
  }
  if (path.contains(CommonWidgetUsageGuardConst.featureScreensMarker)) {
    return true;
  }
  if (path.contains(CommonWidgetUsageGuardConst.featureWidgetsMarker)) {
    return true;
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
      widgetName: 'AppBar',
      replacement: 'LumosAppBar',
      pattern: r'\bAppBar\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'AlertDialog',
      replacement: 'LumosDialog/LumosPromptDialog',
      pattern: r'\bAlertDialog\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'TextField',
      replacement: 'LumosTextField/LumosTextBox/LumosTextArea/LumosSearchBar',
      pattern: r'\bTextField\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'TextFormField',
      replacement: 'LumosTextField/LumosTextBox',
      pattern: r'\bTextFormField\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'FilledButton',
      replacement: 'LumosButton (primary/secondary)',
      pattern: r'\bFilledButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'ElevatedButton',
      replacement: 'LumosButton (primary)',
      pattern: r'\bElevatedButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'OutlinedButton',
      replacement: 'LumosButton (outline)',
      pattern: r'\bOutlinedButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'TextButton',
      replacement: 'LumosButton (text)',
      pattern: r'\bTextButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'IconButton',
      replacement: 'LumosIconButton',
      pattern: r'\bIconButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'FloatingActionButton',
      replacement: 'LumosFloatingActionButton',
      pattern: r'\bFloatingActionButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'PopupMenuButton',
      replacement: 'LumosPopupMenuButton',
      pattern: r'\bPopupMenuButton(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'ActionChip',
      replacement: 'LumosActionChip',
      pattern: r'\bActionChip\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'DropdownButtonFormField',
      replacement: 'LumosDropdown',
      pattern: r'\bDropdownButtonFormField(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'RadioListTile',
      replacement: 'LumosRadioGroup',
      pattern: r'\bRadioListTile(?:\.[A-Za-z0-9_]+)?\s*\(',
    ),
    _DisallowedWidgetRule(
      widgetName: 'Icon',
      replacement: 'LumosIcon',
      pattern: r'\bIcon\s*\(',
      featureUiOnly: true,
    ),
    _DisallowedWidgetRule(
      widgetName: 'Text',
      replacement: 'LumosText/LumosInlineText',
      pattern: r'\bText\s*\(',
      featureUiOnly: true,
    ),
    _DisallowedWidgetRule(
      widgetName: 'ListTile',
      replacement: 'LumosListTile',
      pattern: r'\bListTile\s*\(',
      featureUiOnly: true,
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
    this.featureUiOnly = false,
  }) : pattern = RegExp(pattern);

  final String widgetName;
  final String replacement;
  final RegExp pattern;
  final bool featureUiOnly;
}
