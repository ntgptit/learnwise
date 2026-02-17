import 'dart:io';

class CommonWidgetGuardConst {
  const CommonWidgetGuardConst._();

  static const String commonWidgetDir = 'lib/common/widgets';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';

  static const List<String> forbiddenCommonFiles = <String>[
    'lib/common/widgets/audio/audio_waveform.dart',
    'lib/common/widgets/quiz/quiz_timer.dart',
    'lib/common/widgets/list/swipeable_list_item.dart',
  ];

  static const List<String> statefulWhitelist = <String>[
    'lib/common/widgets/animation/',
    'lib/common/widgets/card/flashcard_flip.dart',
    'lib/common/widgets/input/password_text_box.dart',
    'lib/common/widgets/loader/shimmer_box.dart',
    'lib/common/widgets/navigation/',
    'lib/common/widgets/buttons/app_expandable_fab.dart',
  ];
}

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

final RegExp _navigationPattern = RegExp(
  r'Navigator\.|showDialog\s*\(|showModalBottomSheet\s*\(',
);
final RegExp _throwPattern = RegExp(r'\bthrow\b');
final RegExp _statefulPattern = RegExp(
  r'class\s+\w+\s+extends\s+StatefulWidget',
);

Future<void> main() async {
  final Directory root = Directory(CommonWidgetGuardConst.commonWidgetDir);
  if (!root.existsSync()) {
    stdout.writeln(
      'Common widget guard skipped: `${CommonWidgetGuardConst.commonWidgetDir}` not found.',
    );
    return;
  }

  final List<GuardViolation> violations = <GuardViolation>[];

  for (final String forbiddenPath
      in CommonWidgetGuardConst.forbiddenCommonFiles) {
    if (File(forbiddenPath).existsSync()) {
      violations.add(
        GuardViolation(
          filePath: forbiddenPath,
          reason: 'Feature widget is not allowed in common/widgets.',
          lineNumber: 1,
          lineContent: forbiddenPath,
        ),
      );
    }
  }

  final List<File> files = _collectDartFiles(root);
  for (final File file in files) {
    final String normalizedPath = file.path.replaceAll('\\', '/');
    final List<String> lines = await file.readAsLines();

    for (int index = 0; index < lines.length; index++) {
      final String rawLine = lines[index];
      final String content = _stripLineComment(rawLine).trim();
      if (content.isEmpty) {
        continue;
      }

      if (_navigationPattern.hasMatch(content)) {
        violations.add(
          GuardViolation(
            filePath: normalizedPath,
            reason: 'Navigation is forbidden in common widgets.',
            lineNumber: index + 1,
            lineContent: rawLine.trim(),
          ),
        );
      }

      if (_throwPattern.hasMatch(content)) {
        violations.add(
          GuardViolation(
            filePath: normalizedPath,
            reason: 'Throw is forbidden in common widgets.',
            lineNumber: index + 1,
            lineContent: rawLine.trim(),
          ),
        );
      }

      if (_statefulPattern.hasMatch(content) &&
          !_isStatefulWhitelisted(normalizedPath)) {
        violations.add(
          GuardViolation(
            filePath: normalizedPath,
            reason:
                'StatefulWidget is allowed only for pure UI animation/state widgets.',
            lineNumber: index + 1,
            lineContent: rawLine.trim(),
          ),
        );
      }
    }
  }

  if (violations.isEmpty) {
    stdout.writeln('Common widget guard passed.');
    return;
  }

  stderr.writeln('Common widget guard failed.');
  stderr.writeln(
    'Please keep common widgets render-only and move feature-bound widgets to features/*/view/widgets.',
  );
  for (final GuardViolation violation in violations) {
    stderr.writeln(
      '${violation.filePath}:${violation.lineNumber}: ${violation.reason} ${violation.lineContent}',
    );
  }
  exitCode = 1;
}

List<File> _collectDartFiles(Directory root) {
  final List<File> files = <File>[];
  for (final FileSystemEntity entity in root.listSync(recursive: true)) {
    if (entity is! File) {
      continue;
    }
    final String path = entity.path;
    if (!path.endsWith(CommonWidgetGuardConst.dartExtension)) {
      continue;
    }
    if (path.endsWith(CommonWidgetGuardConst.generatedExtension)) {
      continue;
    }
    if (path.endsWith(CommonWidgetGuardConst.freezedExtension)) {
      continue;
    }
    files.add(entity);
  }
  return files;
}

String _stripLineComment(String value) {
  final int index = value.indexOf('//');
  if (index < 0) {
    return value;
  }
  return value.substring(0, index);
}

bool _isStatefulWhitelisted(String path) {
  for (final String prefix in CommonWidgetGuardConst.statefulWhitelist) {
    if (path.startsWith(prefix)) {
      return true;
    }
  }
  return false;
}
