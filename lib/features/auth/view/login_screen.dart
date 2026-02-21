// quality-guard: allow-long-function - phase2 legacy backlog tracked for incremental extraction.
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../app/router/app_router.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/buttons/primary_button.dart';
import '../../../common/widgets/card/app_card.dart';
import '../../../common/widgets/input/app_text_field.dart';
import '../../../common/widgets/layout/app_scaffold.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/string_utils.dart';
import '../viewmodel/auth_action_viewmodel.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController identifierController =
        useTextEditingController();
    final TextEditingController passwordController = useTextEditingController();
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
      error: (error, stackTrace) => _resolveLoginErrorMessage(error),
      loading: () => null,
    );

    return LwScaffold(
      useSafeArea: true,
      resizeToAvoidBottomInset: true,
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: LwCard(
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
                LwTextField(
                  controller: identifierController,
                  label: _LoginText.identifierLabel,
                  hint: _LoginText.identifierHint,
                  textInputType: TextInputType.emailAddress,
                  onChanged: (_) {
                    ref.read(authActionControllerProvider.notifier).clearError();
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                LwTextField(
                  controller: passwordController,
                  label: _LoginText.passwordLabel,
                  hint: _LoginText.passwordHint,
                  obscureText: true,
                  onChanged: (_) {
                    ref.read(authActionControllerProvider.notifier).clearError();
                  },
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
                LwPrimaryButton(
                  label: _LoginText.signInButton,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final String? identifier =
                              StringUtils.normalizeNullable(
                            identifierController.text,
                          );
                          final String? password =
                              StringUtils.normalizeNullable(
                            passwordController.text,
                          );
                          if (identifier == null || password == null) {
                            return;
                          }
                          await ref
                              .read(authActionControllerProvider.notifier)
                              .login(
                                identifier: identifier,
                                password: password,
                              );
                        },
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
}

String? _resolveLoginErrorMessage(Object? error) {
  if (error == null) {
    return null;
  }
  if (error is AppException) {
    return error.message;
  }
  return _LoginText.defaultError;
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
