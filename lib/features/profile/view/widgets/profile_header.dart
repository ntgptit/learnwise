import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../model/profile_models.dart';

class ProfileHeader extends StatelessWidget {
  const ProfileHeader({
    required this.profile,
    required this.onSignOut,
    super.key,
  });

  final UserProfile profile;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Container(
      decoration: BoxDecoration(gradient: _buildGradient(context)),
      child: SafeArea(
        bottom: false,
        child: _HeaderBody(
          profile: profile,
          title: l10n.profileTitle,
          signOutTooltip: l10n.profileSignOutLabel,
          onSignOut: onSignOut,
        ),
      ),
    );
  }

  LinearGradient _buildGradient(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: <Color>[
        colorScheme.primaryContainer,
        colorScheme.secondaryContainer,
      ],
    );
  }
}

class _HeaderBody extends StatelessWidget {
  const _HeaderBody({
    required this.profile,
    required this.title,
    required this.signOutTooltip,
    required this.onSignOut,
  });

  final UserProfile profile;
  final String title;
  final String signOutTooltip;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSizes.spacingMd,
        AppSizes.spacingMd,
        AppSizes.spacingMd,
        AppSizes.size32,
      ),
      child: Column(
        children: <Widget>[
          _HeaderTopRow(
            title: title,
            signOutTooltip: signOutTooltip,
            onSignOut: onSignOut,
          ),
          const SizedBox(height: AppSizes.spacingLg),
          _HeaderAvatar(colorScheme: colorScheme),
          const SizedBox(height: AppSizes.spacingMd),
          _HeaderDisplayName(textTheme: textTheme, profile: profile),
          const SizedBox(height: AppSizes.spacingXs),
          _HeaderEmail(textTheme: textTheme, profile: profile),
          _HeaderUsername(textTheme: textTheme, profile: profile),
        ],
      ),
    );
  }
}

class _HeaderTopRow extends StatelessWidget {
  const _HeaderTopRow({
    required this.title,
    required this.signOutTooltip,
    required this.onSignOut,
  });

  final String title;
  final String signOutTooltip;
  final VoidCallback onSignOut;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          title,
          style: textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        IconButton(
          onPressed: onSignOut,
          icon: Icon(
            Icons.logout_rounded,
            color: colorScheme.onPrimaryContainer,
          ),
          tooltip: signOutTooltip,
        ),
      ],
    );
  }
}

class _HeaderAvatar extends StatelessWidget {
  const _HeaderAvatar({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppSizes.size72,
      height: AppSizes.size72,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: colorScheme.primary,
        border: Border.all(color: colorScheme.surface, width: AppSizes.size1),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Icon(
        Icons.person_rounded,
        size: AppSizes.size24,
        color: colorScheme.onPrimary,
      ),
    );
  }
}

class _HeaderDisplayName extends StatelessWidget {
  const _HeaderDisplayName({required this.textTheme, required this.profile});

  final TextTheme textTheme;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Text(
      profile.displayName,
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }
}

class _HeaderEmail extends StatelessWidget {
  const _HeaderEmail({required this.textTheme, required this.profile});

  final TextTheme textTheme;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Text(
      profile.email,
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
      ),
    );
  }
}

class _HeaderUsername extends StatelessWidget {
  const _HeaderUsername({required this.textTheme, required this.profile});

  final TextTheme textTheme;
  final UserProfile profile;

  @override
  Widget build(BuildContext context) {
    final String? username = profile.username;
    if (username == null || username.isEmpty) {
      return const SizedBox.shrink();
    }

    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Text(
      '@$username',
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
      ),
    );
  }
}
