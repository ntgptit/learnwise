import 'package:analyzer/dart/ast/ast.dart';
import 'package:analyzer/error/listener.dart';
import 'package:custom_lint_builder/custom_lint_builder.dart';

PluginBase createPlugin() {
  return _LearnwiseCustomLintPlugin();
}

class _LearnwiseCustomLintPlugin extends PluginBase {
  @override
  List<LintRule> getLintRules(CustomLintConfigs configs) {
    return const <LintRule>[_NoElseClauseRule()];
  }
}

class _NoElseClauseRule extends DartLintRule {
  const _NoElseClauseRule() : super(code: _code);

  static const LintCode _code = LintCode(
    name: 'learnwise_no_else_clause',
    problemMessage:
        '`else` clauses are forbidden. Use guard clauses with early return.',
  );

  @override
  void run(
    CustomLintResolver resolver,
    DiagnosticReporter reporter,
    CustomLintContext context,
  ) {
    if (!_isSupportedPath(resolver.path)) {
      return;
    }

    context.registry.addIfStatement((node) {
      final Statement? elseStatement = node.elseStatement;
      if (elseStatement == null) {
        return;
      }

      reporter.atNode(elseStatement, code);
    });
  }

  bool _isSupportedPath(String path) {
    final String normalizedPath = path.replaceAll('\\', '/');
    if (normalizedPath.startsWith('lib/')) {
      return true;
    }
    if (normalizedPath.startsWith('test/')) {
      return true;
    }
    if (normalizedPath.startsWith('integration_test/')) {
      return true;
    }
    return false;
  }
}
