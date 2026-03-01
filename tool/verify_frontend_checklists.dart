import 'dart:io';

import 'guards/verify_code_quality_contract.dart' as code_quality_guard;
import 'guards/verify_common_widget_boundaries.dart'
    as common_widget_boundaries_guard;
import 'guards/verify_common_widget_usage_contract.dart'
    as common_widget_usage_guard;
import 'guards/verify_component_theme_usage_contract.dart'
    as component_theme_guard;
import 'guards/verify_feature_surface_contract.dart' as feature_surface_guard;
import 'guards/verify_navigation_go_router_contract.dart' as navigation_guard;
import 'guards/verify_opacity_constants_contract.dart' as opacity_guard;
import 'guards/verify_riverpod_annotation.dart' as riverpod_annotation_guard;
import 'guards/verify_shared_widget_override_contract.dart'
    as shared_widget_override_guard;
import 'guards/verify_shared_widgets_m3_coverage.dart'
    as shared_widgets_m3_coverage_guard;
import 'guards/verify_state_management_contract.dart' as state_management_guard;
import 'guards/verify_string_utils_contract.dart' as string_utils_guard;
import 'guards/verify_ui_constants_centralization.dart'
    as ui_constants_centralization_guard;
import 'guards/verify_ui_design_guard.dart' as ui_design_guard;
import 'guards/verify_ui_logic_separation_contract.dart'
    as ui_logic_separation_guard;

class FrontendChecklistConst {
  const FrontendChecklistConst._();

  static const String name = 'verify_frontend_checklists';
  static const String listFlag = '--list';
  static const String onlyPrefix = '--only=';
  static const String failFastFlag = '--fail-fast';
  static const String helpFlag = '--help';
  static const String helpFlagShort = '-h';
  static const String passLabel = '[PASS]';
  static const String failLabel = '[FAIL]';
  static const String runningLabel = '[RUN]';
}

class _GuardTask {
  const _GuardTask({
    required this.id,
    required this.fileName,
    required this.run,
  });

  final String id;
  final String fileName;
  final Future<void> Function() run;
}

class _GuardResult {
  const _GuardResult({
    required this.task,
    required this.elapsed,
    required this.hasFailure,
    this.error,
    this.stackTrace,
  });

  final _GuardTask task;
  final Duration elapsed;
  final bool hasFailure;
  final Object? error;
  final StackTrace? stackTrace;
}

class _CliOptions {
  const _CliOptions({
    required this.showHelp,
    required this.listOnly,
    required this.failFast,
    required this.onlyIds,
  });

  final bool showHelp;
  final bool listOnly;
  final bool failFast;
  final Set<String> onlyIds;
}

Future<void> main(List<String> args) async {
  final _CliOptions options = _parseArgs(args);
  if (options.showHelp) {
    _printUsage();
    return;
  }

  final List<_GuardTask> allTasks = _buildDefaultTasks();
  if (options.listOnly) {
    _printTaskList(allTasks);
    return;
  }

  final Set<String> unknownIds = _collectUnknownGuardIds(
    requested: options.onlyIds,
    allTasks: allTasks,
  );
  if (unknownIds.isNotEmpty) {
    stderr.writeln('Unknown guard id(s): ${unknownIds.join(', ')}');
    stderr.writeln(
      'Use `${FrontendChecklistConst.listFlag}` to see valid ids.',
    );
    exitCode = 1;
    return;
  }

  final List<_GuardTask> tasks = _selectTasks(
    allTasks: allTasks,
    onlyIds: options.onlyIds,
  );
  if (tasks.isEmpty) {
    stderr.writeln('No guard selected.');
    exitCode = 1;
    return;
  }

  stdout.writeln(
    '${FrontendChecklistConst.name}: running ${tasks.length} guard(s)...',
  );

  final List<_GuardResult> failed = <_GuardResult>[];
  for (final _GuardTask task in tasks) {
    final _GuardResult result = await _runTask(task);
    _printTaskResult(result);
    if (!result.hasFailure) {
      continue;
    }
    failed.add(result);
    if (!options.failFast) {
      continue;
    }
    break;
  }

  if (failed.isEmpty) {
    stdout.writeln(
      '${FrontendChecklistConst.name}: all ${tasks.length} guard(s) passed.',
    );
    return;
  }

  stderr.writeln(
    '${FrontendChecklistConst.name}: ${failed.length}/${tasks.length} guard(s) failed.',
  );
  for (final _GuardResult result in failed) {
    stderr.writeln(
      '- ${result.task.id} (${result.task.fileName}) in ${result.elapsed.inMilliseconds}ms',
    );
  }
  exitCode = 1;
}

List<_GuardTask> _buildDefaultTasks() {
  return <_GuardTask>[
    _GuardTask(
      id: 'riverpod-annotation',
      fileName: 'guards/verify_riverpod_annotation.dart',
      run: () => riverpod_annotation_guard.main(<String>[]),
    ),
    _GuardTask(
      id: 'state-management',
      fileName: 'guards/verify_state_management_contract.dart',
      run: state_management_guard.main,
    ),
    _GuardTask(
      id: 'ui-logic-separation',
      fileName: 'guards/verify_ui_logic_separation_contract.dart',
      run: ui_logic_separation_guard.main,
    ),
    _GuardTask(
      id: 'navigation',
      fileName: 'guards/verify_navigation_go_router_contract.dart',
      run: navigation_guard.main,
    ),
    _GuardTask(
      id: 'opacity-contract',
      fileName: 'guards/verify_opacity_constants_contract.dart',
      run: opacity_guard.main,
    ),
    _GuardTask(
      id: 'common-widget-boundaries',
      fileName: 'guards/verify_common_widget_boundaries.dart',
      run: common_widget_boundaries_guard.main,
    ),
    _GuardTask(
      id: 'common-widget-usage',
      fileName: 'guards/verify_common_widget_usage_contract.dart',
      run: () => common_widget_usage_guard.main(<String>[]),
    ),
    _GuardTask(
      id: 'ui-constants',
      fileName: 'guards/verify_ui_constants_centralization.dart',
      run: ui_constants_centralization_guard.main,
    ),
    _GuardTask(
      id: 'string-utils',
      fileName: 'guards/verify_string_utils_contract.dart',
      run: string_utils_guard.main,
    ),
    _GuardTask(
      id: 'ui-design',
      fileName: 'guards/verify_ui_design_guard.dart',
      run: ui_design_guard.main,
    ),
    _GuardTask(
      id: 'code-quality',
      fileName: 'guards/verify_code_quality_contract.dart',
      run: code_quality_guard.main,
    ),
    _GuardTask(
      id: 'component-theme',
      fileName: 'guards/verify_component_theme_usage_contract.dart',
      run: component_theme_guard.main,
    ),
    _GuardTask(
      id: 'feature-surface',
      fileName: 'guards/verify_feature_surface_contract.dart',
      run: feature_surface_guard.main,
    ),
    _GuardTask(
      id: 'shared-widget-override',
      fileName: 'guards/verify_shared_widget_override_contract.dart',
      run: shared_widget_override_guard.main,
    ),
    _GuardTask(
      id: 'shared-widgets-m3-coverage',
      fileName: 'guards/verify_shared_widgets_m3_coverage.dart',
      run: shared_widgets_m3_coverage_guard.main,
    ),
  ];
}

_CliOptions _parseArgs(List<String> args) {
  bool showHelp = false;
  bool listOnly = false;
  bool failFast = false;
  final Set<String> onlyIds = <String>{};

  for (final String arg in args) {
    if (arg == FrontendChecklistConst.helpFlag) {
      showHelp = true;
      continue;
    }
    if (arg == FrontendChecklistConst.helpFlagShort) {
      showHelp = true;
      continue;
    }
    if (arg == FrontendChecklistConst.listFlag) {
      listOnly = true;
      continue;
    }
    if (arg == FrontendChecklistConst.failFastFlag) {
      failFast = true;
      continue;
    }
    if (!arg.startsWith(FrontendChecklistConst.onlyPrefix)) {
      continue;
    }
    final String csv = arg.substring(FrontendChecklistConst.onlyPrefix.length);
    final Iterable<String> ids = csv
        .split(',')
        .map((String item) => item.trim())
        .where((String item) => item.isNotEmpty);
    onlyIds.addAll(ids);
  }

  return _CliOptions(
    showHelp: showHelp,
    listOnly: listOnly,
    failFast: failFast,
    onlyIds: onlyIds,
  );
}

Set<String> _collectUnknownGuardIds({
  required Set<String> requested,
  required List<_GuardTask> allTasks,
}) {
  if (requested.isEmpty) {
    return <String>{};
  }

  final Set<String> known = allTasks.map((task) => task.id).toSet();
  return requested.where((String id) => !known.contains(id)).toSet();
}

List<_GuardTask> _selectTasks({
  required List<_GuardTask> allTasks,
  required Set<String> onlyIds,
}) {
  if (onlyIds.isEmpty) {
    return allTasks;
  }
  return allTasks.where((task) => onlyIds.contains(task.id)).toList();
}

Future<_GuardResult> _runTask(_GuardTask task) async {
  stdout.writeln(
    '${FrontendChecklistConst.runningLabel} ${task.id} (${task.fileName})',
  );

  final Stopwatch stopwatch = Stopwatch()..start();
  final int previousExitCode = exitCode;
  exitCode = 0;

  Object? error;
  StackTrace? stackTrace;
  try {
    await task.run();
  } catch (caughtError, caughtStackTrace) {
    error = caughtError;
    stackTrace = caughtStackTrace;
  }

  final bool hasFailure = error != null || exitCode != 0;
  stopwatch.stop();
  exitCode = previousExitCode;

  return _GuardResult(
    task: task,
    elapsed: stopwatch.elapsed,
    hasFailure: hasFailure,
    error: error,
    stackTrace: stackTrace,
  );
}

void _printTaskResult(_GuardResult result) {
  if (!result.hasFailure) {
    stdout.writeln(
      '${FrontendChecklistConst.passLabel} ${result.task.id} in ${result.elapsed.inMilliseconds}ms',
    );
    return;
  }

  stderr.writeln(
    '${FrontendChecklistConst.failLabel} ${result.task.id} in ${result.elapsed.inMilliseconds}ms',
  );
  if (result.error == null) {
    return;
  }
  stderr.writeln('  Error: ${result.error}');
  if (result.stackTrace == null) {
    return;
  }
  stderr.writeln('  StackTrace: ${result.stackTrace}');
}

void _printTaskList(List<_GuardTask> tasks) {
  stdout.writeln('Available guards:');
  for (final _GuardTask task in tasks) {
    stdout.writeln('- ${task.id} (${task.fileName})');
  }
}

void _printUsage() {
  stdout.writeln(
    'Usage: dart run tool/verify_frontend_checklists.dart [options]',
  );
  stdout.writeln('Options:');
  stdout.writeln(
    '  ${FrontendChecklistConst.listFlag}            List guard ids',
  );
  stdout.writeln(
    '  ${FrontendChecklistConst.onlyPrefix}<ids>   Run only selected ids (comma separated)',
  );
  stdout.writeln(
    '  ${FrontendChecklistConst.failFastFlag}       Stop at first failure',
  );
  stdout.writeln(
    '  ${FrontendChecklistConst.helpFlag}, ${FrontendChecklistConst.helpFlagShort}       Show help',
  );
}
