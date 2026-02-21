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

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final TextEditingController displayNameController =
        useTextEditingController();
    final TextEditingController emailController = useTextEditingController();
    final TextEditingController usernameController = useTextEditingController();
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
      error: (error, stackTrace) => _resolveRegisterErrorMessage(error),
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
                  _RegisterText.title,
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingSm),
                Text(
                  _RegisterText.subtitle,
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSizes.spacingLg),
                LwTextField(
                  controller: displayNameController,
                  label: _RegisterText.displayNameLabel,
                  hint: _RegisterText.displayNameHint,
                  onChanged: (_) {
                    ref.read(authActionControllerProvider.notifier).clearError();
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                LwTextField(
                  controller: emailController,
                  label: _RegisterText.emailLabel,
                  hint: _RegisterText.emailHint,
                  textInputType: TextInputType.emailAddress,
                  onChanged: (_) {
                    ref.read(authActionControllerProvider.notifier).clearError();
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                LwTextField(
                  controller: usernameController,
                  label: _RegisterText.usernameLabel,
                  hint: _RegisterText.usernameHint,
                  onChanged: (_) {
                    ref.read(authActionControllerProvider.notifier).clearError();
                  },
                ),
                const SizedBox(height: AppSizes.spacingMd),
                LwTextField(
                  controller: passwordController,
                  label: _RegisterText.passwordLabel,
                  hint: _RegisterText.passwordHint,
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
                  label: _RegisterText.registerButton,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting
                      ? null
                      : () async {
                          final String? displayName =
                              StringUtils.normalizeNullable(
                            displayNameController.text,
                          );
                          final String? email = StringUtils.normalizeNullable(
                            emailController.text,
                          );
                          final String? username =
                              StringUtils.normalizeNullable(
                            usernameController.text,
                          );
                          final String? password =
                              StringUtils.normalizeNullable(
                            passwordController.text,
                          );
                          if (email == null || password == null) {
                            return;
                          }
                          final String normalizedDisplayName = displayName ?? '';
                          await ref
                              .read(authActionControllerProvider.notifier)
                              .register(
                                email: email,
                                username: username,
                                password: password,
                                displayName: normalizedDisplayName,
                              );
                        },
                ),
                const SizedBox(height: AppSizes.spacingSm),
                TextButton(
                  onPressed: isSubmitting
                      ? null
                      : () => const LoginRoute().go(context),
                  child: const Text(_RegisterText.signInAction),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String? _resolveRegisterErrorMessage(Object? error) {
  if (error == null) {
    return null;
  }
  if (error is AppException) {
    return error.message;
  }
  return _RegisterText.defaultError;
}

class _RegisterText {
  const _RegisterText._();

  static const String title = 'Create account';
  static const String subtitle = 'Register your first LearnWise user';
  static const String displayNameLabel = 'Display name';
  static const String displayNameHint = 'Your name';
  static const String emailLabel = 'Email';
  static const String emailHint = 'you@example.com';
  static const String usernameLabel = 'Username (optional)';
  static const String usernameHint = 'Choose a unique username';
  static const String passwordLabel = 'Password';
  static const String passwordHint = 'At least 8 characters';
  static const String registerButton = 'Register';
  static const String signInAction = 'Already have an account? Sign in';
  static const String defaultError = 'Unable to register. Please try again.';
}
