import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../model/profile_models.dart';

// quality-guard: allow-long-function
// Justification: Header composition is intentionally in one build tree for visual coherence.
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: <Color>[
            colorScheme.primaryContainer,
            colorScheme.secondaryContainer,
          ],
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSizes.spacingMd,
            AppSizes.spacingMd,
            AppSizes.spacingMd,
            AppSizes.size32,
          ),
          child: Column(
            children: <Widget>[
              _buildHeaderRow(context, l10n, colorScheme, textTheme),
              const SizedBox(height: AppSizes.spacingLg),
              _buildAvatar(colorScheme),
              const SizedBox(height: AppSizes.spacingMd),
              _buildDisplayName(textTheme, colorScheme),
              const SizedBox(height: AppSizes.spacingXs),
              _buildEmail(textTheme, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeaderRow(
    BuildContext context,
    AppLocalizations l10n,
    ColorScheme colorScheme,
    TextTheme textTheme,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Text(
          l10n.profileTitle,
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
          tooltip: l10n.profileSignOutLabel,
        ),
      ],
    );
  }

  Widget _buildAvatar(ColorScheme colorScheme) {
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

  Widget _buildDisplayName(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      profile.displayName,
      style: textTheme.titleLarge?.copyWith(
        fontWeight: FontWeight.bold,
        color: colorScheme.onPrimaryContainer,
      ),
    );
  }

  Widget _buildEmail(TextTheme textTheme, ColorScheme colorScheme) {
    return Text(
      profile.email,
      style: textTheme.bodyMedium?.copyWith(
        color: colorScheme.onPrimaryContainer.withValues(alpha: 0.8),
      ),
    );
  }
}
