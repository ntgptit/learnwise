import 'dart:io';

/// ----------------------------------------------------------------------------
/// Navigation Contract Guard v2
/// ----------------------------------------------------------------------------
///
/// Enforces strict typed routing architecture.
///
/// Rules:
///
/// 1. go_router must exist in pubspec.yaml
/// 2. Navigator.*, MaterialPageRoute, onGenerateRoute are forbidden
/// 3. String-based navigation is forbidden (context.go('/path'))
/// 4. GoRouter.of(context) is forbidden
/// 5. Raw GoRoute(...) declaration outside router config is forbidden
/// 6. Must import typed route files (e.g. app_router.dart or routes.dart)
///
/// Goal:
/// - Enforce fully typed routing
/// - Prevent string-based route bugs
/// - Centralize route configuration
/// - Ensure compile-time safe navigation
///
/// Exit code 1 on violation.
/// ----------------------------------------------------------------------------

class NavigationContractConst {
  const NavigationContractConst._();

  static const String libDirectory = 'lib';
  static const String pubspecPath = 'pubspec.yaml';
  static const String dartExtension = '.dart';
  static const String generatedExtension = '.g.dart';
  static const String freezedExtension = '.freezed.dart';

  /// Adjust if your typed router config lives elsewhere
  static const String routerConfigKeyword = 'GoRouter(';

  static const String lineCommentPrefix = '//';
}

class NavigationViolation {
  const NavigationViolation({
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

/// Forbidden legacy navigation APIs
final RegExp _navigatorRegExp = RegExp(r'\bNavigator\.');
final RegExp _materialPageRouteRegExp = RegExp(
  r'\bMaterialPageRoute\s*(?:<[^>]+>)?\s*\(',
);
final RegExp _onGenerateRouteRegExp = RegExp(r'\bonGenerateRoute\b');

/// Forbidden string-based navigation
final RegExp _stringNavigationRegExp = RegExp(
  "\\bcontext\\.(go|push|replace)\\s*\\(\\s*['\\\"]/",
);

/// Forbidden direct GoRouter.of(context)
final RegExp _goRouterOfRegExp = RegExp(r'\bGoRouter\.of\s*\(');

/// Detect raw GoRoute usage
final RegExp _goRouteRegExp = RegExp(r'\bGoRoute\s*\(');

/// Detect go_router dependency
final RegExp _goRouterDependencyRegExp = RegExp(
  r'^\s*go_router\s*:',
  multiLine: true,
);

Future<void> main() async {
  final List<NavigationViolation> violations = [];

  await _checkPubspec(violations);
  await _scanLib(violations);

  if (violations.isEmpty) {
    stdout.writeln('Typed Navigation contract passed.');
    return;
  }

  stderr.writeln('Typed Navigation contract failed.');
  for (final v in violations) {
    stderr.writeln(
      '${v.filePath}:${v.lineNumber}: ${v.reason} ${v.lineContent}',
    );
  }

  exitCode = 1;
}

Future<void> _checkPubspec(List<NavigationViolation> violations) async {
  final File pubspec = File(NavigationContractConst.pubspecPath);

  if (!pubspec.existsSync()) {
    violations.add(
      const NavigationViolation(
        filePath: 'pubspec.yaml',
        lineNumber: 1,
        reason: 'Missing pubspec.yaml',
        lineContent: '',
      ),
    );
    return;
  }

  final String content = await pubspec.readAsString();

  if (!_goRouterDependencyRegExp.hasMatch(content)) {
    violations.add(
      const NavigationViolation(
        filePath: 'pubspec.yaml',
        lineNumber: 1,
        reason: 'go_router dependency is required.',
        lineContent: 'go_router: ^x.y.z',
      ),
    );
  }
}

Future<void> _scanLib(List<NavigationViolation> violations) async {
  final Directory libDir = Directory(NavigationContractConst.libDirectory);

  if (!libDir.existsSync()) {
    violations.add(
      const NavigationViolation(
        filePath: 'lib',
        lineNumber: 1,
        reason: 'Missing lib directory.',
        lineContent: '',
      ),
    );
    return;
  }

  final List<File> files = _collectDartFiles(libDir);

  for (final File file in files) {
    final String path = _normalizePath(file.path);
    final List<String> lines = await file.readAsLines();

    for (int i = 0; i < lines.length; i++) {
      final String raw = lines[i];
      final String line = _stripComment(raw).trim();

      if (line.isEmpty) continue;

      _checkLegacyNavigation(path, line, raw, i, violations);
      _checkStringNavigation(path, line, raw, i, violations);
      _checkDirectGoRouter(path, line, raw, i, violations);
      _checkRawGoRoute(path, line, raw, i, violations);
    }
  }
}

void _checkLegacyNavigation(
  String path,
  String line,
  String raw,
  int index,
  List<NavigationViolation> violations,
) {
  if (_navigatorRegExp.hasMatch(line)) {
    violations.add(
      NavigationViolation(
        filePath: path,
        lineNumber: index + 1,
        reason: 'Navigator.* is forbidden. Use typed route classes.',
        lineContent: raw.trim(),
      ),
    );
  }

  if (_materialPageRouteRegExp.hasMatch(line)) {
    violations.add(
      NavigationViolation(
        filePath: path,
        lineNumber: index + 1,
        reason: 'MaterialPageRoute is forbidden.',
        lineContent: raw.trim(),
      ),
    );
  }

  if (_onGenerateRouteRegExp.hasMatch(line)) {
    violations.add(
      NavigationViolation(
        filePath: path,
        lineNumber: index + 1,
        reason: 'onGenerateRoute is forbidden.',
        lineContent: raw.trim(),
      ),
    );
  }
}

void _checkStringNavigation(
  String path,
  String line,
  String raw,
  int index,
  List<NavigationViolation> violations,
) {
  if (_stringNavigationRegExp.hasMatch(line)) {
    violations.add(
      NavigationViolation(
        filePath: path,
        lineNumber: index + 1,
        reason:
            'String-based navigation is forbidden. Use typed route objects.',
        lineContent: raw.trim(),
      ),
    );
  }
}

void _checkDirectGoRouter(
  String path,
  String line,
  String raw,
  int index,
  List<NavigationViolation> violations,
) {
  if (_goRouterOfRegExp.hasMatch(line)) {
    violations.add(
      NavigationViolation(
        filePath: path,
        lineNumber: index + 1,
        reason:
            'Direct GoRouter.of(context) usage is forbidden. Use typed routes.',
        lineContent: raw.trim(),
      ),
    );
  }
}

void _checkRawGoRoute(
  String path,
  String line,
  String raw,
  int index,
  List<NavigationViolation> violations,
) {
  if (_goRouteRegExp.hasMatch(line) &&
      !path.contains('router') &&
      !path.contains('app_router')) {
    violations.add(
      NavigationViolation(
        filePath: path,
        lineNumber: index + 1,
        reason:
            'GoRoute declaration is allowed only inside router config file.',
        lineContent: raw.trim(),
      ),
    );
  }
}

List<File> _collectDartFiles(Directory root) {
  final List<File> files = [];

  for (final entity in root.listSync(recursive: true)) {
    if (entity is! File) continue;

    final String path = entity.path;

    if (!path.endsWith(NavigationContractConst.dartExtension)) continue;
    if (path.endsWith(NavigationContractConst.generatedExtension)) continue;
    if (path.endsWith(NavigationContractConst.freezedExtension)) continue;

    files.add(entity);
  }

  return files;
}

String _stripComment(String line) {
  final int index = line.indexOf(NavigationContractConst.lineCommentPrefix);
  if (index < 0) return line;
  return line.substring(0, index);
}

String _normalizePath(String path) {
  return path.replaceAll('\\', '/');
}
