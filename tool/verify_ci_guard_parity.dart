import 'dart:io';

class CiGuardParityConst {
  const CiGuardParityConst._();

  static const String toolDirectory = 'tool';
  static const String workflowPath = '.github/workflows/flutter_ci.yml';
  static const String verifyPrefix = 'verify_';
  static const String dartExtension = '.dart';
  static const String ciCommandPrefix = 'dart run tool/';
}

class CiGuardParityViolation {
  const CiGuardParityViolation({required this.reason, required this.guardName});

  final String reason;
  final String guardName;
}

Future<void> main() async {
  final Directory toolDirectory = Directory(CiGuardParityConst.toolDirectory);
  if (!toolDirectory.existsSync()) {
    stderr.writeln('Missing `${CiGuardParityConst.toolDirectory}` directory.');
    exitCode = 1;
    return;
  }

  final File workflowFile = File(CiGuardParityConst.workflowPath);
  if (!workflowFile.existsSync()) {
    stderr.writeln(
      'Missing `${CiGuardParityConst.workflowPath}` workflow file.',
    );
    exitCode = 1;
    return;
  }

  final Set<String> localGuards = _collectLocalGuards(toolDirectory);
  final String workflowSource = await workflowFile.readAsString();
  final Set<String> ciGuards = _collectWorkflowGuards(workflowSource);

  final List<CiGuardParityViolation> violations = <CiGuardParityViolation>[];
  _collectMissingInCi(
    localGuards: localGuards,
    ciGuards: ciGuards,
    violations: violations,
  );
  _collectOrphanInCi(
    localGuards: localGuards,
    ciGuards: ciGuards,
    violations: violations,
  );

  if (violations.isEmpty) {
    stdout.writeln('CI guard parity passed.');
    return;
  }

  stderr.writeln('CI guard parity failed.');
  for (final CiGuardParityViolation violation in violations) {
    stderr.writeln('${violation.reason} ${violation.guardName}');
  }
  exitCode = 1;
}

Set<String> _collectLocalGuards(Directory toolDirectory) {
  final Set<String> guards = <String>{};
  final List<FileSystemEntity> entities = toolDirectory.listSync();

  for (final FileSystemEntity entity in entities) {
    if (entity is! File) {
      continue;
    }

    final String name = entity.uri.pathSegments.last;
    if (!name.startsWith(CiGuardParityConst.verifyPrefix)) {
      continue;
    }
    if (!name.endsWith(CiGuardParityConst.dartExtension)) {
      continue;
    }
    guards.add(name);
  }

  return guards;
}

Set<String> _collectWorkflowGuards(String workflowSource) {
  final Set<String> guards = <String>{};
  final RegExp commandRegExp = RegExp(
    r'dart\s+run\s+tool/(verify_[A-Za-z0-9_]+\.dart)\b',
  );

  for (final RegExpMatch match in commandRegExp.allMatches(workflowSource)) {
    final String? guard = match.group(1);
    if (guard == null) {
      continue;
    }
    guards.add(guard);
  }

  return guards;
}

void _collectMissingInCi({
  required Set<String> localGuards,
  required Set<String> ciGuards,
  required List<CiGuardParityViolation> violations,
}) {
  final List<String> sortedLocalGuards = localGuards.toList()..sort();
  for (final String localGuard in sortedLocalGuards) {
    if (ciGuards.contains(localGuard)) {
      continue;
    }

    violations.add(
      CiGuardParityViolation(
        reason:
            'Guard script is not enforced in CI (`${CiGuardParityConst.ciCommandPrefix}` missing):',
        guardName: localGuard,
      ),
    );
  }
}

void _collectOrphanInCi({
  required Set<String> localGuards,
  required Set<String> ciGuards,
  required List<CiGuardParityViolation> violations,
}) {
  final List<String> sortedCiGuards = ciGuards.toList()..sort();
  for (final String ciGuard in sortedCiGuards) {
    if (localGuards.contains(ciGuard)) {
      continue;
    }

    violations.add(
      CiGuardParityViolation(
        reason: 'Workflow references a missing guard script:',
        guardName: ciGuard,
      ),
    );
  }
}
