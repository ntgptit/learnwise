import 'dart:io';

import 'verify_component_theme_usage_contract.dart' as component_theme_guard;
import 'verify_feature_surface_contract.dart' as feature_surface_guard;
import 'verify_shared_widget_override_contract.dart'
    as shared_widget_override_guard;

class ColorSchemeUsageGuardCompatConst {
  const ColorSchemeUsageGuardCompatConst._();

  static const String componentThemeGuard =
      'tool/guards/verify_component_theme_usage_contract.dart';
  static const String featureSurfaceGuard =
      'tool/guards/verify_feature_surface_contract.dart';
  static const String sharedWidgetOverrideGuard =
      'tool/guards/verify_shared_widget_override_contract.dart';
}

class _GuardTask {
  const _GuardTask({required this.name, required this.run});

  final String name;
  final Future<void> Function() run;
}

class _GuardResult {
  const _GuardResult({
    required this.name,
    required this.elapsed,
    required this.hasFailure,
  });

  final String name;
  final Duration elapsed;
  final bool hasFailure;
}

Future<void> main() async {
  final List<_GuardTask> guards = <_GuardTask>[
    _GuardTask(
      name: ColorSchemeUsageGuardCompatConst.componentThemeGuard,
      run: component_theme_guard.main,
    ),
    _GuardTask(
      name: ColorSchemeUsageGuardCompatConst.featureSurfaceGuard,
      run: feature_surface_guard.main,
    ),
    _GuardTask(
      name: ColorSchemeUsageGuardCompatConst.sharedWidgetOverrideGuard,
      run: shared_widget_override_guard.main,
    ),
  ];

  final List<_GuardResult> failed = <_GuardResult>[];

  for (final _GuardTask guard in guards) {
    final _GuardResult result = await _runGuard(guard);
    if (!result.hasFailure) {
      continue;
    }
    failed.add(result);
  }

  if (failed.isEmpty) {
    stdout.writeln(
      'Color scheme usage contract passed (delegated to component + feature guards).',
    );
    return;
  }

  stderr.writeln(
    'Color scheme usage contract failed (delegated to component + feature guards).',
  );
  for (final _GuardResult result in failed) {
    stderr.writeln(
      '- ${result.name} failed in ${result.elapsed.inMilliseconds}ms.',
    );
  }
  exitCode = 1;
}

Future<_GuardResult> _runGuard(_GuardTask guard) async {
  final Stopwatch stopwatch = Stopwatch()..start();
  final int previousExitCode = exitCode;
  exitCode = 0;

  try {
    await guard.run();
  } catch (error, stackTrace) {
    stderr.writeln('Guard `${guard.name}` threw an exception: $error');
    stderr.writeln(stackTrace);
    stopwatch.stop();
    exitCode = previousExitCode;
    return _GuardResult(
      name: guard.name,
      elapsed: stopwatch.elapsed,
      hasFailure: true,
    );
  }

  final bool hasFailure = exitCode != 0;
  stopwatch.stop();
  exitCode = previousExitCode;
  return _GuardResult(
    name: guard.name,
    elapsed: stopwatch.elapsed,
    hasFailure: hasFailure,
  );
}
