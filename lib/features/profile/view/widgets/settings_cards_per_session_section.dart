import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../common/styles/app_sizes.dart';
import '../../model/profile_models.dart';
import 'settings_common_widgets.dart';

class CardsPerSessionSection extends StatelessWidget {
  const CardsPerSessionSection({
    required this.l10n,
    required this.cardsPerSession,
    required this.onChanged,
    super.key,
  });

  final AppLocalizations l10n;
  final int cardsPerSession;
  final ValueChanged<int> onChanged;

  static const double _innerSpacing = AppSizes.spacingSm;

  @override
  Widget build(BuildContext context) {
    final int normalizedCardsPerSession =
        UserStudySettings.normalizeStudyCardsPerSession(cardsPerSession);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        _CardsPerSessionHeader(l10n: l10n, cardsPerSession: cardsPerSession),
        const SizedBox(height: _innerSpacing),
        _CardsPerSessionSlider(
          l10n: l10n,
          cardsPerSession: normalizedCardsPerSession,
          onChanged: onChanged,
        ),
      ],
    );
  }
}

class _CardsPerSessionHeader extends StatelessWidget {
  const _CardsPerSessionHeader({
    required this.l10n,
    required this.cardsPerSession,
  });

  final AppLocalizations l10n;
  final int cardsPerSession;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    final TextTheme textTheme = Theme.of(context).textTheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Expanded(
          child: SettingTitleRow(
            icon: Icons.collections_bookmark_rounded,
            title: l10n.profileStudyCardsPerSessionLabel,
            containerColor: colorScheme.secondaryContainer,
            iconColor: colorScheme.onSecondaryContainer,
          ),
        ),
        _CardsCountBadge(
          label: l10n.profileStudyCardsPerSessionOption(cardsPerSession),
          textTheme: textTheme,
          colorScheme: colorScheme,
        ),
      ],
    );
  }
}

class _CardsCountBadge extends StatelessWidget {
  const _CardsCountBadge({
    required this.label,
    required this.textTheme,
    required this.colorScheme,
  });

  final String label;
  final TextTheme textTheme;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppSizes.spacingSm,
        vertical: AppSizes.spacingXs,
      ),
      decoration: BoxDecoration(
        color: colorScheme.primary,
        borderRadius: BorderRadius.circular(AppSizes.radiusMd),
      ),
      child: Text(
        label,
        style: textTheme.labelLarge?.copyWith(
          color: colorScheme.onPrimary,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _CardsPerSessionSlider extends StatelessWidget {
  const _CardsPerSessionSlider({
    required this.l10n,
    required this.cardsPerSession,
    required this.onChanged,
  });

  final AppLocalizations l10n;
  final int cardsPerSession;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        thumbColor: colorScheme.primary,
        activeTrackColor: colorScheme.primary,
        inactiveTrackColor: colorScheme.primaryContainer,
      ),
      child: Slider(
        value: cardsPerSession.toDouble(),
        min: UserStudySettings.minStudyCardsPerSession.toDouble(),
        max: UserStudySettings.maxStudyCardsPerSession.toDouble(),
        divisions: _divisions(),
        label: l10n.profileStudyCardsPerSessionOption(cardsPerSession),
        onChanged: (value) {
          final int normalizedValue =
              UserStudySettings.normalizeStudyCardsPerSession(value.round());
          onChanged(normalizedValue);
        },
      ),
    );
  }

  int _divisions() {
    return UserStudySettings.maxStudyCardsPerSession -
        UserStudySettings.minStudyCardsPerSession;
  }
}
