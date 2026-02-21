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
import '../model/profile_constants.dart';
import '../model/profile_models.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'widgets/overview/profile_header.dart';

class ProfileScreen extends HookConsumerWidget {
  const ProfileScreen({super.key});

  @override
  // quality-guard: allow-long-function - profile template wiring keeps hooks callbacks and template state mapping cohesive.
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<UserProfile> state = ref.watch(profileControllerProvider);
    final ProfileController controller = ref.read(
      profileControllerProvider.notifier,
    );
    final ScrollController scrollController = useScrollController();
    final LwPageContentState contentState = _resolveContentState(state);
    final UserProfile? profile = _resolveProfile(state);
    final String errorMessage = _resolveErrorMessageFromState(
      l10n: l10n,
      state: state,
    );
    final VoidCallback onRefresh = useCallback(() {
      _refresh(controller);
    }, <Object?>[controller]);
    final VoidCallback onRefreshAndScrollToTop = useCallback(() {
      _refreshAndScrollToTop(
        controller: controller,
        scrollController: scrollController,
      );
    }, <Object?>[controller, scrollController]);

    return LwPageTemplate(
      body: _ProfileBody(
        profile: profile,
        l10n: l10n,
        controller: controller,
        scrollController: scrollController,
      ),
      selectedIndex: ProfileConstants.profileNavIndex,
      contentState: contentState,
      loadingMessage: l10n.profileLoadingLabel,
      errorTitle: l10n.profileLoadErrorTitle,
      errorMessage: errorMessage,
      errorRetryLabel: l10n.profileRetryLabel,
      onRetry: onRefresh,
      onRefreshAndScrollToTop: onRefreshAndScrollToTop,
      onDestinationSelected: (index) {
        _onDestinationSelected(context: context, index: index);
      },
    );
  }

  void _onDestinationSelected({
    required BuildContext context,
    required int index,
  }) {
    final StatefulNavigationShellState navigationShell =
        StatefulNavigationShell.of(context);
    if (index == navigationShell.currentIndex) {
      return;
    }
    navigationShell.goBranch(index);
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

class _ProfileBody extends StatelessWidget {
  const _ProfileBody({
    required this.profile,
    required this.l10n,
    required this.controller,
    required this.scrollController,
  });

  final UserProfile? profile;
  final AppLocalizations l10n;
  final ProfileController controller;
  final ScrollController scrollController;

  @override
  Widget build(BuildContext context) {
    final UserProfile? resolvedProfile = profile;
    if (resolvedProfile == null) {
      return const SizedBox.shrink();
    }
    return RefreshIndicator(
      onRefresh: controller.refresh,
      child: CustomScrollView(
        controller: scrollController,
        slivers: <Widget>[
          SliverToBoxAdapter(
            child: ProfileHeader(
              profile: resolvedProfile,
              onSignOut: controller.signOut,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(AppSizes.spacingMd),
            sliver: SliverList(
              delegate: SliverChildListDelegate(<Widget>[
                _ProfileMenuCard(
                  icon: Icons.person_outline_rounded,
                  title: l10n.profilePersonalInformationTitle,
                  onTap: () => const ProfilePersonalInfoRoute().go(context),
                ),
                const SizedBox(height: AppSizes.spacingMd),
                _ProfileMenuCard(
                  icon: Icons.tune_rounded,
                  title: l10n.profileSettingsTitle,
                  onTap: () => const ProfileSettingsRoute().go(context),
                ),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileMenuCard extends StatelessWidget {
  const _ProfileMenuCard({
    required this.icon,
    required this.title,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;
    return LwCard(
      variant: AppCardVariant.elevated,
      child: ListTile(
        leading: Icon(icon, color: colorScheme.primary, size: AppSizes.size24),
        title: Text(
          title,
          style: textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w600),
        ),
        trailing: Icon(
          Icons.chevron_right_rounded,
          color: colorScheme.onSurfaceVariant,
          size: AppSizes.size24,
        ),
        onTap: onTap,
      ),
    );
  }
}
