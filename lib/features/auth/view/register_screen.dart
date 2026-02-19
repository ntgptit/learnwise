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

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  late final TextEditingController _displayNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _usernameController;
  late final TextEditingController _passwordController;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
    _emailController = TextEditingController();
    _usernameController = TextEditingController();
    _passwordController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
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
                  controller: _displayNameController,
                  label: _RegisterText.displayNameLabel,
                  hint: _RegisterText.displayNameHint,
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                LwTextField(
                  controller: _emailController,
                  label: _RegisterText.emailLabel,
                  hint: _RegisterText.emailHint,
                  textInputType: TextInputType.emailAddress,
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                LwTextField(
                  controller: _usernameController,
                  label: _RegisterText.usernameLabel,
                  hint: _RegisterText.usernameHint,
                  onChanged: (_) => _clearError(),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                LwTextField(
                  controller: _passwordController,
                  label: _RegisterText.passwordLabel,
                  hint: _RegisterText.passwordHint,
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
                LwPrimaryButton(
                  label: _RegisterText.registerButton,
                  isLoading: isSubmitting,
                  onPressed: isSubmitting ? null : _submitRegister,
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

  Future<void> _submitRegister() async {
    final String? displayName = StringUtils.normalizeNullable(
      _displayNameController.text,
    );
    final String? email = StringUtils.normalizeNullable(_emailController.text);
    final String? username = StringUtils.normalizeNullable(
      _usernameController.text,
    );
    final String? password = StringUtils.normalizeNullable(
      _passwordController.text,
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
    return _RegisterText.defaultError;
  }
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
