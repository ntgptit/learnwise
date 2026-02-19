// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/buttons/primary_button.dart';
import '../../../common/widgets/card/app_card.dart';
import '../../../common/widgets/input/app_text_field.dart';
import '../../../common/widgets/layout/app_scaffold.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/string_utils.dart';
import '../viewmodel/auth_action_viewmodel.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final TextEditingController _identifierController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _identifierController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _identifierController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AsyncValue<void> actionState = ref.watch(
      authActionControllerProvider,
    );
    final bool isSubmitting = actionState.when(
      data: (_) => false,
      error: (_, stackTrace) => false,
      loading: () => true,
    );
    final String? errorMessage = actionState.when(
      data: (_) => null,
      error: (error, stackTrace) => _resolveErrorMessage(error),
      loading: () => null,
    );

    return AppScaffold(
      useSafeArea: true,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: AppCard(
            variant: AppCardVariant.elevated,
            padding: const EdgeInsets.all(AppSizes.spacingLg),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                Text(
                  _LoginText.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingSm),
                Text(
                  _LoginText.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingLg),
                AppTextField(
                  controller: _identifierController,
                  label: _LoginText.identifierLabel,
                  hint: _LoginText.identifierHint,
                  textInputType: TextInputType.emailAddress,
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                AppTextField(
                  controller: _passwordController,
                  label: _LoginText.passwordLabel,
                  hint: _LoginText.passwordHint,
                  obscureText: true,
                  onChanged: (_) => _clearError(),
                ),
                if (errorMessage != null) ...<Widget>[
                  const SizedBox(height: AppSizes.spacingMd),
                  Text(
                    errorMessage,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: AppSizes.spacingLg),
                PrimaryButton(
                  label: _LoginText.signInButton,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : _submitLogin,
                ),
                const SizedBox(height: AppSizes.spacingSm),
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => const RegisterRoute().go(context),
                  child: const Text(_LoginText.registerAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _submitLogin() async {
    final String? identifier = StringUtils.normalizeNullable(
      _identifierController.text,
    );
    final String? password = StringUtils.normalizeNullable(
      _passwordController.text,
    );
    if (identifier == null || password == null) {
      return;
    }
    await ref
        .read(authActionControllerProvider.notifier)
        .login(identifier: identifier, password: password);
  }

  void _clearError() {
    ref.read(authActionControllerProvider.notifier).clearError();
  }

  String? _resolveErrorMessage(Object? error) {
    if (error == null) {
      return null;
    }
    if (error is AppException) {
      return error.message;
    }
    return _LoginText.defaultError;
  }
}

class _LoginText {
  const _LoginText._();

  static const String title = 'Welcome back';
  static const String subtitle = 'Sign in to continue your study session';
  static const String identifierLabel = 'Email or username';
  static const String identifierHint = 'you@example.com or your username';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'Enter password';
  static const String signInButton = 'Sign in';
  static const String registerAction = 'Create an account';
  static const String defaultError = 'Unable to sign in. Please try again.';
}
