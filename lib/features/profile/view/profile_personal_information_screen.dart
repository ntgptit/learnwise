import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/app_router.dart';
import '../../../common/styles/app_durations.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/error/app_exception.dart';
import '../../../core/utils/string_utils.dart';
import '../model/profile_constants.dart';
import '../model/profile_models.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'widgets/personal_information/personal_info_section.dart';

class ProfilePersonalInformationScreen extends HookConsumerWidget {
  const ProfilePersonalInformationScreen({super.key});

  @override
  // quality-guard: allow-long-function - page template wiring keeps hooks callbacks and profile state mapping cohesive in one screen entrypoint.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<UserProfile> state = ref.watch(profileControllerProvider);
    final ProfileController controller = ref.read(
      profileControllerProvider.notifier,
    );
    final ScrollController scrollController = useScrollController();
    final TextEditingController displayNameController =
        useTextEditingController();
    final ObjectRef<int?> boundUserIdRef = useRef<int?>(null);
    final LwPageContentState contentState = _resolveContentState(state);
    final UserProfile? profile = _resolveProfile(state);
    final String errorMessage = _resolveErrorMessageFromState(
      l10n: l10n,
      state: state,
    );
    useEffect(() {
      final UserProfile? data = profile;
      if (data == null) {
        return null;
      }
      _bindDisplayName(
        profile: data,
        displayNameController: displayNameController,
        boundUserIdRef: boundUserIdRef,
      );
      return null;
    }, <Object?>[profile?.userId, profile?.displayName, displayNameController]);
    final VoidCallback onTapBack = useCallback(() {
      _onTapBack(context);
    }, <Object?>[context]);
    final VoidCallback onRefresh = useCallback(() {
      _refresh(controller);
    }, <Object?>[controller]);
    final VoidCallback onRefreshAndScrollToTop = useCallback(() {
      _refreshAndScrollToTop(
        controller: controller,
        scrollController: scrollController,
      );
    }, <Object?>[controller, scrollController]);
    final VoidCallback onSave = useCallback(() {
      unawaited(
        _submitProfileUpdate(
          controller: controller,
          displayNameController: displayNameController,
        ),
      );
    }, <Object?>[controller, displayNameController]);

    return LwPageTemplate(
      title: l10n.profilePersonalInformationTitle,
      appBarLeadingAction: LwPageLeadingAction.back,
      body: _ProfilePersonalInformationBody(
        profile: profile,
        scrollController: scrollController,
        displayNameController: displayNameController,
        controller: controller,
        onSave: onSave,
      ),
      selectedIndex: ProfileConstants.profileNavIndex,
      contentState: contentState,
      loadingMessage: l10n.profileLoadingLabel,
      errorTitle: l10n.profileLoadErrorTitle,
      errorMessage: errorMessage,
      errorRetryLabel: l10n.profileRetryLabel,
      contentPadding: EdgeInsets.zero,
      onTapBack: onTapBack,
      onRetry: onRefresh,
      onRefreshAndScrollToTop: onRefreshAndScrollToTop,
      onDestinationSelected: (index) {
        _onDestinationSelected(context: context, index: index);
      },
    );
  }

  void _onTapBack(BuildContext context) {
    if (context.canPop()) {
      context.pop();
      return;
    }
    const ProfileRoute().go(context);
  }

  void _onDestinationSelected({
    required BuildContext context,
    required int index,
  }) {
    if (index == ProfileConstants.dashboardNavIndex) {
      const DashboardRoute().go(context);
      return;
    }
    if (index == ProfileConstants.foldersNavIndex) {
      const FoldersRoute().go(context);
      return;
    }
    const ProfileRoute().go(context);
  }

  LwPageContentState _resolveContentState(AsyncValue<UserProfile> state) {
    return state.when(
      data: (_) => LwPageContentState.content,
      error: (error, stackTrace) => LwPageContentState.error,
      loading: () => LwPageContentState.loading,
    );
  }

  UserProfile? _resolveProfile(AsyncValue<UserProfile> state) {
    return state.when(
      data: (profile) => profile,
      error: (error, stackTrace) => null,
      loading: () => null,
    );
  }

  String _resolveErrorMessageFromState({
    required AppLocalizations l10n,
    required AsyncValue<UserProfile> state,
  }) {
    return state.when(
      data: (_) => l10n.profileDefaultErrorMessage,
      error: (error, stackTrace) {
        return _resolveErrorMessage(error: error, l10n: l10n);
      },
      loading: () => l10n.profileDefaultErrorMessage,
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

  Future<void> _submitProfileUpdate({
    required ProfileController controller,
    required TextEditingController displayNameController,
  }) async {
    final String? displayName = StringUtils.normalizeNullable(
      displayNameController.text,
    );
    if (displayName == null) {
      return;
    }
    await controller.updateProfile(displayName: displayName);
  }

  void _bindDisplayName({
    required UserProfile profile,
    required TextEditingController displayNameController,
    required ObjectRef<int?> boundUserIdRef,
  }) {
    if (boundUserIdRef.value == profile.userId &&
        displayNameController.text == profile.displayName) {
      return;
    }
    boundUserIdRef.value = profile.userId;
    displayNameController.value = TextEditingValue(
      text: profile.displayName,
      selection: TextSelection.collapsed(offset: profile.displayName.length),
    );
  }

  void _refresh(ProfileController controller) {
    unawaited(controller.refresh());
  }

  void _refreshAndScrollToTop({
    required ProfileController controller,
    required ScrollController scrollController,
  }) {
    if (scrollController.hasClients) {
      unawaited(
        scrollController.animateTo(
          0,
          duration: AppDurations.animationFast,
          curve: AppMotionCurves.decelerateCubic,
        ),
      );
    }
    _refresh(controller);
  }
}

class _ProfilePersonalInformationBody extends StatelessWidget {
  const _ProfilePersonalInformationBody({
    required this.profile,
    required this.scrollController,
    required this.displayNameController,
    required this.controller,
    required this.onSave,
  });

  final UserProfile? profile;
  final ScrollController scrollController;
  final TextEditingController displayNameController;
  final ProfileController controller;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final UserProfile? resolvedProfile = profile;
    if (resolvedProfile == null) {
      return const SizedBox.shrink();
    }
    final double bottomSafeArea = MediaQuery.paddingOf(context).bottom;
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: CustomScrollView(
        controller: scrollController,
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: <Widget>[
          SliverPadding(
            padding: EdgeInsets.fromLTRB(
              AppSizes.spacingMd,
              AppSizes.spacingMd,
              AppSizes.spacingMd,
              AppSizes.spacingMd + bottomSafeArea,
            ),
            sliver: SliverToBoxAdapter(
              child: PersonalInfoSection(
                profile: resolvedProfile,
                displayNameController: displayNameController,
                onSave: onSave,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
