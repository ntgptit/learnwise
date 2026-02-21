import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../app/router/app_router.dart';
import '../../../common/styles/app_sizes.dart';
import '../../../common/widgets/widgets.dart';
import '../../../core/error/app_exception.dart';
import '../model/profile_constants.dart';
import '../model/profile_models.dart';
import '../viewmodel/profile_viewmodel.dart';
import 'widgets/profile_header.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final AsyncValue<UserProfile> state = ref.watch(profileControllerProvider);
    final ProfileController controller = ref.read(
      profileControllerProvider.notifier,
    );

    return LwAppShell(
      body: SafeArea(
        child: state.when(
          data: (profile) => _buildProfileHome(
            context: context,
            l10n: l10n,
            profile: profile,
            controller: controller,
          ),
          error: (error, _) => _buildErrorState(
            l10n: l10n,
            error: error,
            controller: controller,
          ),
          loading: () => LwLoadingState(message: l10n.profileLoadingLabel),
        ),
      ),
      selectedIndex: ProfileConstants.profileNavIndex,
      onDestinationSelected: (index) {
        _onDestinationSelected(context: context, index: index);
      },
    );
  }

  Widget _buildProfileHome({
    required BuildContext context,
    required AppLocalizations l10n,
    required UserProfile profile,
    required ProfileController controller,
  }) {
    return CustomScrollView(
      slivers: <Widget>[
        SliverToBoxAdapter(
          child: ProfileHeader(profile: profile, onSignOut: controller.signOut),
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
    );
  }

  Widget _buildErrorState({
    required AppLocalizations l10n,
    required Object error,
    required ProfileController controller,
  }) {
    final String message = _resolveErrorMessage(error: error, l10n: l10n);
    return LwErrorState(
      title: l10n.profileLoadErrorTitle,
      message: message,
      retryLabel: l10n.profileRetryLabel,
      onRetry: controller.refresh,
    );
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
    if (index == ProfileConstants.profileNavIndex) {
      return;
    }
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
