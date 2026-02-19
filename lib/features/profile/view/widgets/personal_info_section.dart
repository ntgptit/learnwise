import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../../../common/widgets/widgets.dart';
import '../../../../core/utils/string_utils.dart';
import '../../model/profile_models.dart';

// quality-guard: allow-long-function
// Justification: Single compose function keeps personal info section layout readable.
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
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _buildSectionHeader(
          context: context,
          icon: Icons.person_outline_rounded,
          title: l10n.profilePersonalInformationTitle,
        ),
        const SizedBox(height: AppSizes.spacingSm),
        AppCard(
          variant: AppCardVariant.elevated,
          child: Column(
            children: <Widget>[
              _buildInfoTile(
                context: context,
                icon: Icons.badge_outlined,
                label: 'User ID',
                value: profile.userId.toString(),
              ),
              Divider(
                height: AppSizes.size1,
                color: colorScheme.outlineVariant,
              ),
              _buildInfoTile(
                context: context,
                icon: Icons.email_outlined,
                label: 'Email',
                value: profile.email,
              ),
              Divider(
                height: AppSizes.size1,
                color: colorScheme.outlineVariant,
              ),
              _buildInfoTile(
                context: context,
                icon: Icons.alternate_email_rounded,
                label: 'Username',
                value: profile.username ?? 'Not set',
              ),
              Divider(
                height: AppSizes.size1,
                color: colorScheme.outlineVariant,
              ),
              _buildEditSection(context, l10n),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditSection(BuildContext context, AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.all(AppSizes.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          AppTextField(
            controller: displayNameController,
            label: l10n.profileDisplayNameLabel,
            hint: l10n.profileDisplayNameHint,
          ),
          const SizedBox(height: AppSizes.spacingMd),
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: displayNameController,
            builder: (context, value, _) {
              final bool isChanged = _isDisplayNameChanged(value.text);
              return PrimaryButton(
                label: l10n.profileSaveChangesLabel,
                onPressed: isChanged ? onSave : null,
              );
            },
          ),
        ],
      ),
    );
  }

  bool _isDisplayNameChanged(String text) {
    final String? normalizedInput = StringUtils.normalizeNullable(text);
    final String normalizedProfileName = StringUtils.normalize(
      profile.displayName,
    );
    return normalizedInput != null && normalizedInput != normalizedProfileName;
  }

  Widget _buildSectionHeader({
    required BuildContext context,
    required IconData icon,
    required String title,
  }) {
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

  Widget _buildInfoTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String value,
  }) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingMd,
        vertical: AppSizes.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          Container(
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
          ),
          const SizedBox(width: AppSizes.spacingMd),
          Expanded(
            child: Column(
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
                  style: textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
