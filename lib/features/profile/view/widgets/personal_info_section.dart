import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../core/utils/string_utils.dart';
import '../../model/profile_models.dart';

class PersonalInfoSection extends StatelessWidget {
  const PersonalInfoSection({
    required this.profile,
    required this.displayNameController,
    required this.onSave,
    super.key,
  });

  final UserProfile profile;
  final TextEditingController displayNameController;
  final VoidCallback onSave;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _SectionHeader(
          icon: Icons.person_outline_rounded,
          title: l10n.profilePersonalInformationTitle,
        ),
        const SizedBox(height: AppSizes.spacingSm),
        _PersonalInfoCard(
          profile: profile,
          displayNameController: displayNameController,
          onSave: onSave,
          l10n: l10n,
        ),
      ],
    );
  }
}

class _PersonalInfoCard extends StatelessWidget {
  const _PersonalInfoCard({
    required this.profile,
    required this.displayNameController,
    required this.onSave,
    required this.l10n,
  });

  final UserProfile profile;
  final TextEditingController displayNameController;
  final VoidCallback onSave;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return LwCard(
      variant: AppCardVariant.elevated,
      child: Column(children: _buildInfoChildren(colorScheme)),
    );
  }

  List<Widget> _buildInfoChildren(ColorScheme colorScheme) {
    return <Widget>[
      _InfoTile(
        icon: Icons.badge_outlined,
        label: 'User ID',
        value: profile.userId.toString(),
      ),
      _InfoDivider(colorScheme: colorScheme),
      _InfoTile(
        icon: Icons.email_outlined,
        label: 'Email',
        value: profile.email,
      ),
      _InfoDivider(colorScheme: colorScheme),
      _InfoTile(
        icon: Icons.alternate_email_rounded,
        label: 'Username',
        value: profile.username ?? 'Not set',
      ),
      _InfoDivider(colorScheme: colorScheme),
      _EditSection(
        profile: profile,
        displayNameController: displayNameController,
        onSave: onSave,
        l10n: l10n,
      ),
    ];
  }
}

class _EditSection extends StatelessWidget {
  const _EditSection({
    required this.profile,
    required this.displayNameController,
    required this.onSave,
    required this.l10n,
  });

  final UserProfile profile;
  final TextEditingController displayNameController;
  final VoidCallback onSave;
  final AppLocalizations l10n;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LwTextField(
            controller: displayNameController,
            label: l10n.profileDisplayNameLabel,
            hint: l10n.profileDisplayNameHint,
          ),
          const SizedBox(height: AppSizes.spacingMd),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: displayNameController,
            builder: (context, value, _) {
              final bool isChanged = _isDisplayNameChanged(
                value.text,
                profile.displayName,
              );
              return LwPrimaryButton(
                label: l10n.profileSaveChangesLabel,
                onPressed: isChanged ? onSave : null,
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isDisplayNameChanged(String text, String currentDisplayName) {
    final String? normalizedInput = StringUtils.normalizeNullable(text);
    final String normalizedProfileName = StringUtils.normalize(
      currentDisplayName,
    );
    return normalizedInput != null && normalizedInput != normalizedProfileName;
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.icon, required this.title});

  final IconData icon;
  final String title;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      children: <Widget>[
        Icon(icon, size: AppSizes.size24, color: colorScheme.primary),
        const SizedBox(width: AppSizes.spacingSm),
        Text(
          title,
          style: textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          _InfoLeadingIcon(icon: icon),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: _InfoTextContent(label: label, value: value),
          ),
        ],
      ),
    );
  }
}

class _InfoLeadingIcon extends StatelessWidget {
  const _InfoLeadingIcon({required this.icon});

  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(AppSizes.spacingXs),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppSizes.radiusSm),
      ),
      child: Icon(
        icon,
        size: AppSizes.size24,
        color: colorScheme.onSurfaceVariant,
      ),
    );
  }
}

class _InfoTextContent extends StatelessWidget {
  const _InfoTextContent({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: textTheme.labelSmall?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: AppSizes.size2),
        Text(
          value,
          style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}

class _InfoDivider extends StatelessWidget {
  const _InfoDivider({required this.colorScheme});

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Divider(height: AppSizes.size1, color: colorScheme.outlineVariant);
  }
}
