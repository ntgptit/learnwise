// ---------------------------------------------------------------------------
// Common Widget Guard
// ---------------------------------------------------------------------------
//
// Purpose:
// Enforce architectural boundaries for `lib/common/widgets`.
//
// Philosophy:
// - Common widgets must be render-only.
// - No navigation logic.
// - No business logic.
// - No repository/service imports.
// - StatefulWidget allowed only for UI-only widgets (animation/input/etc).
//
// This tool is intended to be used in CI to prevent architectural erosion.
//
// Exit code:
// - 0 => pass
// - 1 => violations found
import 'dart:io';

/// Central configuration constants for Common Widget Guard.
class CommonWidgetGuardConst {
  const CommonWidgetGuardConst._();

  static const String commonWidgetDir = 'lib/common/widgets';

  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';

  /// Explicitly forbidden files under common/widgets.
  static const List<String> forbiddenCommonFiles = <String>[
    'lib/common/widgets/audio/audio_waveform.dart',
    'lib/common/widgets/quiz/quiz_timer.dart',
    'lib/common/widgets/list/swipeable_list_item.dart',
  ];

  /// Allowed StatefulWidget locations.
  static const List<String> statefulWhitelist = <String>[
    'lib/common/widgets/animation/',
    'lib/common/widgets/navigation/',
    'lib/common/widgets/card/flashcard_flip.dart',
    'lib/common/widgets/input/password_text_box.dart',
    'lib/common/widgets/loader/shimmer_box.dart',
    'lib/common/widgets/buttons/app_expandable_fab.dart',
  ];
}

/// Represents a violation detected by a guard rule.
class GuardViolation {
  const GuardViolation({
    required this.filePath,
    required this.reason,
    required this.lineNumber,
    required this.lineContent,
  });

  final String filePath;
  final String reason;
  final int lineNumber;
  final String lineContent;
}

/// Context passed to rules.
class FileContext {
  FileContext({required this.path, required this.lines});

  final String path;
  final List<String> lines;
}

/// Base class for all common widget rules.
abstract class CommonWidgetRule {
  void check(FileContext context, List<GuardViolation> violations);
}

/// ---------------------------------------------------------------------------
/// Rule 1: Forbidden File Rule
/// ---------------------------------------------------------------------------
class ForbiddenFileRule extends CommonWidgetRule {
  @override
  void check(FileContext context, List<GuardViolation> violations) {
    for (final forbidden in CommonWidgetGuardConst.forbiddenCommonFiles) {
      if (context.path == forbidden) {
        violations.add(
          GuardViolation(
            filePath: context.path,
            reason:
                'Feature-bound widget is not allowed inside common/widgets.',
            lineNumber: 1,
            lineContent: context.path,
          ),
        );
      }
    }
  }
}

/// ---------------------------------------------------------------------------
/// Rule 2: Navigation Rule
/// ---------------------------------------------------------------------------
class NavigationRule extends CommonWidgetRule {
  final RegExp _navigationPattern = RegExp(
    r'Navigator\.|showDialog\s*\(|showModalBottomSheet\s*\(|context\.push|context\.go|GoRouter',
  );

  @override
  void check(FileContext context, List<GuardViolation> violations) {
    for (int i = 0; i < context.lines.length; i++) {
      final raw = context.lines[i];
      final content = _stripComment(raw);

      if (_navigationPattern.hasMatch(content)) {
        violations.add(
          GuardViolation(
            filePath: context.path,
            reason: 'Navigation is forbidden in common widgets.',
            lineNumber: i + 1,
            lineContent: raw.trim(),
          ),
        );
      }
    }
  }
}

/// ---------------------------------------------------------------------------
/// Rule 3: Throw Rule
/// ---------------------------------------------------------------------------
class ThrowRule extends CommonWidgetRule {
  final RegExp _throwPattern = RegExp(r'\bthrow\b');

  @override
  void check(FileContext context, List<GuardViolation> violations) {
    for (int i = 0; i < context.lines.length; i++) {
      final raw = context.lines[i];
      final content = _stripComment(raw);

      if (_throwPattern.hasMatch(content)) {
        violations.add(
          GuardViolation(
            filePath: context.path,
            reason:
                'Throwing exceptions is forbidden in common widgets. Bubble errors upward.',
            lineNumber: i + 1,
            lineContent: raw.trim(),
          ),
        );
      }
    }
  }
}

/// ---------------------------------------------------------------------------
/// Rule 4: Stateful Restriction Rule
/// ---------------------------------------------------------------------------
class StatefulRule extends CommonWidgetRule {
  final RegExp _statefulPattern = RegExp(
    r'class\s+\w+\s+extends\s+StatefulWidget',
  );

  @override
  void check(FileContext context, List<GuardViolation> violations) {
    if (_isWhitelisted(context.path)) {
      return;
    }

    for (int i = 0; i < context.lines.length; i++) {
      final raw = context.lines[i];
      final content = _stripComment(raw);

      if (_statefulPattern.hasMatch(content)) {
        violations.add(
          GuardViolation(
            filePath: context.path,
            reason:
                'StatefulWidget allowed only for pure UI/animation widgets.',
            lineNumber: i + 1,
            lineContent: raw.trim(),
          ),
        );
      }
    }
  }

  bool _isWhitelisted(String path) {
    for (final prefix in CommonWidgetGuardConst.statefulWhitelist) {
      if (path.startsWith(prefix)) {
        return true;
      }
    }
    return false;
  }
}

/// ---------------------------------------------------------------------------
/// Rule 5: Import Boundary Rule
/// ---------------------------------------------------------------------------
class ImportBoundaryRule extends CommonWidgetRule {
  final RegExp _forbiddenImportPattern = RegExp(
    r'/repository/|/service/|/viewmodel/|/features/',
  );

  @override
  void check(FileContext context, List<GuardViolation> violations) {
    for (int i = 0; i < context.lines.length; i++) {
      final raw = context.lines[i];
      final content = _stripComment(raw).trim();

      if (!content.startsWith('import')) continue;

      if (_forbiddenImportPattern.hasMatch(content)) {
        violations.add(
          GuardViolation(
            filePath: context.path,
            reason:
                'Common widgets must not depend on repository/service/viewmodel/features.',
            lineNumber: i + 1,
            lineContent: raw.trim(),
          ),
        );
      }
    }
  }
}

/// ---------------------------------------------------------------------------
/// Main Entry
/// ---------------------------------------------------------------------------
Future<void> main() async {
  final Directory root = Directory(CommonWidgetGuardConst.commonWidgetDir);

  if (!root.existsSync()) {
    stdout.writeln(
      'Common widget guard skipped: `${CommonWidgetGuardConst.commonWidgetDir}` not found.',
    );
    return;
  }

  final List<CommonWidgetRule> rules = <CommonWidgetRule>[
    ForbiddenFileRule(),
    NavigationRule(),
    ThrowRule(),
    StatefulRule(),
    ImportBoundaryRule(),
  ];

  final List<GuardViolation> violations = <GuardViolation>[];

  final List<File> files = _collectDartFiles(root);

  for (final file in files) {
    final String path = _normalizePath(file.path);
    final List<String> lines = await file.readAsLines();

    final FileContext context = FileContext(path: path, lines: lines);

    for (final rule in rules) {
      rule.check(context, violations);
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('Common widget guard passed.');
    return;
  }

  stderr.writeln('Common widget guard failed.');
  stderr.writeln(
    'Keep common widgets render-only. Move feature-bound logic to features/*.',
  );

  for (final violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: '
      '${violation.reason} ${violation.lineContent}',
    );
  }

  exitCode = 1;
}

/// Collect Dart source files under root.
List<File> _collectDartFiles(Directory root) {
  final List<File> files = <File>[];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;

    final String path = _normalizePath(entity.path);

    if (!path.endsWith(CommonWidgetGuardConst.dartExtension)) continue;
    if (path.endsWith(CommonWidgetGuardConst.generatedExtension)) continue;
    if (path.endsWith(CommonWidgetGuardConst.freezedExtension)) continue;

    files.add(entity);
  }

  return files;
}

/// Normalize file path to forward-slash format.
String _normalizePath(String path) => path.replaceAll('\\', '/');

/// Strip single-line comment.
String _stripComment(String value) {
  final int index = value.indexOf('//');
  if (index < 0) return value;
  return value.substring(0, index);
}
