import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/string_utils.dart';
import '../model/profile_models.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'widgets/personal_info_section.dart';

class ProfilePersonalInformationScreen extends ConsumerStatefulWidget {
  const ProfilePersonalInformationScreen({super.key});

  @override
  ConsumerState<ProfilePersonalInformationScreen> createState() =>
      _ProfilePersonalInformationScreenState();
}

class _ProfilePersonalInformationScreenState
    extends ConsumerState<ProfilePersonalInformationScreen> {
  late final TextEditingController _displayNameController;
  int? _boundUserId;

  @override
  void initState() {
    super.initState();
    _displayNameController = TextEditingController();
  }

  @override
  void dispose() {
    _displayNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<UserProfile> state = ref.watch(profileControllerProvider);
    final ProfileController controller = ref.read(
      profileControllerProvider.notifier,
    );

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profilePersonalInformationTitle)),
      body: SafeArea(
        child: state.when(
          data: (profile) {
            _bindDisplayName(profile);
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSizes.spacingMd),
              child: PersonalInfoSection(
                profile: profile,
                displayNameController: _displayNameController,
                onSave: () => _submitProfileUpdate(controller: controller),
              ),
            );
          },
          error: (error, _) => _buildErrorState(
            l10n: l10n,
            error: error,
            controller: controller,
          ),
          loading: () => LoadingState(message: l10n.profileLoadingLabel),
        ),
      ),
    );
  }

  Widget _buildErrorState({
    required AppLocalizations l10n,
    required Object error,
    required ProfileController controller,
  }) {
    final String message = _resolveErrorMessage(error: error, l10n: l10n);
    return ErrorState(
      title: l10n.profileLoadErrorTitle,
      message: message,
      retryLabel: l10n.profileRetryLabel,
      onRetry: controller.refresh,
    );
  }

  Future<void> _submitProfileUpdate({
    required ProfileController controller,
  }) async {
    final String? displayName = StringUtils.normalizeNullable(
      _displayNameController.text,
    );
    if (displayName == null) {
      return;
    }
    await controller.updateProfile(displayName: displayName);
  }

  void _bindDisplayName(UserProfile profile) {
    if (_boundUserId == profile.userId &&
        _displayNameController.text == profile.displayName) {
      return;
    }
    _boundUserId = profile.userId;
    _displayNameController.value = TextEditingValue(
      text: profile.displayName,
      selection: TextSelection.collapsed(offset: profile.displayName.length),
    );
  }

  String _resolveErrorMessage({
    required Object error,
    required AppLocalizations l10n,
  }) {
    if (error is AppException) {
      return error.message;
    }
    return l10n.profileDefaultErrorMessage;
  }
}
