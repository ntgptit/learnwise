import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_opacities.dart';
import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../model/dashboard_models.dart';

class DashboardHeroSection extends StatelessWidget {
  const DashboardHeroSection({required this.snapshot, super.key});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ThemeData theme = Theme.of(context);
    final ColorScheme colorScheme = theme.colorScheme;
    final Color foregroundColor = colorScheme.onPrimaryContainer;

    return Container(
      padding: const EdgeInsets.all(DashboardScreenTokens.headerPadding),
      decoration: _buildDecoration(colorScheme),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          _HeroTitle(
            greeting: l10n.dashboardGreeting(snapshot.displayName),
            headline: l10n.dashboardHeroHeadline,
            theme: theme,
            foregroundColor: foregroundColor,
          ),
          const SizedBox(height: DashboardScreenTokens.heroGapLarge),
          _HeroStats(l10n: l10n, snapshot: snapshot),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: <Color>[
          colorScheme.primaryContainer,
          colorScheme.secondaryContainer,
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(
        DashboardScreenTokens.headerBorderRadius,
      ),
      boxShadow: <BoxShadow>[
        BoxShadow(
          color: colorScheme.shadow.withValues(alpha: AppOpacities.soft20),
          blurRadius: DashboardScreenTokens.heroShadowBlur,
          offset: const Offset(0, DashboardScreenTokens.heroShadowOffsetY),
        ),
      ],
    );
  }
}

class _HeroTitle extends StatelessWidget {
  const _HeroTitle({
    required this.greeting,
    required this.headline,
    required this.theme,
    required this.foregroundColor,
  });

  final String greeting;
  final String headline;
  final ThemeData theme;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Text(
                greeting,
                style: theme.textTheme.headlineSmall?.copyWith(
                  color: foregroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: DashboardScreenTokens.heroGapSmall),
              Text(
                headline,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: foregroundColor,
                ),
              ),
            ],
          ),
        ),
        Container(
          width: DashboardScreenTokens.heroIconContainerSize,
          height: DashboardScreenTokens.heroIconContainerSize,
          decoration: BoxDecoration(
            color: foregroundColor.withValues(alpha: AppOpacities.soft20),
            shape: BoxShape.circle,
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: Theme.of(
                  context,
                ).colorScheme.shadow.withValues(alpha: AppOpacities.soft15),
                blurRadius: DashboardScreenTokens.heroIconShadowBlur,
                offset: const Offset(
                  0,
                  DashboardScreenTokens.heroIconShadowOffsetY,
                ),
              ),
            ],
          ),
          child: Icon(
            Icons.local_fire_department_rounded,
            size: DashboardScreenTokens.heroIconSize,
            color: foregroundColor,
          ),
        ),
      ],
    );
  }
}

class _HeroStats extends StatelessWidget {
  const _HeroStats({required this.l10n, required this.snapshot});

  final AppLocalizations l10n;
  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        _HeroStatChip(
          icon: Icons.local_fire_department_outlined,
          label: l10n.dashboardStreakLabel,
          value: l10n.dashboardStreakValue(snapshot.streakDays),
          foregroundColor: Theme.of(context).colorScheme.onSecondaryContainer,
          backgroundColor: Theme.of(context).colorScheme.secondaryContainer,
        ),
        const SizedBox(width: DashboardScreenTokens.heroChipSpacing),
        _HeroStatChip(
          icon: Icons.flag_outlined,
          label: l10n.dashboardGoalProgressLabel,
          value: l10n.dashboardFocusCountLabel(snapshot.focusCardCount),
          foregroundColor: Theme.of(context).colorScheme.onTertiaryContainer,
          backgroundColor: Theme.of(context).colorScheme.tertiaryContainer,
        ),
      ],
    );
  }
}

class _HeroStatChip extends StatelessWidget {
  const _HeroStatChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color foregroundColor;
  final Color backgroundColor;

  @override
  Widget build(BuildContext context) {
    final ColorScheme colorScheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(DashboardScreenTokens.heroChipPadding),
        decoration: _buildDecoration(colorScheme),
        child: Row(
          children: <Widget>[
            Icon(icon, color: foregroundColor),
            const SizedBox(width: DashboardScreenTokens.heroChipSpacing),
            Expanded(
              child: _HeroStatText(
                label: label,
                value: value,
                foregroundColor: foregroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  BoxDecoration _buildDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: backgroundColor,
      borderRadius: BorderRadius.circular(DashboardScreenTokens.heroChipRadius),
    );
  }
}

class _HeroStatText extends StatelessWidget {
  const _HeroStatText({
    required this.label,
    required this.value,
    required this.foregroundColor,
  });

  final String label;
  final String value;
  final Color foregroundColor;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: Theme.of(context).textTheme.labelMedium?.copyWith(
            color: foregroundColor.withValues(alpha: AppOpacities.muted70),
          ),
        ),
        Text(
          value,
          style: Theme.of(context).textTheme.titleSmall?.copyWith(
            color: foregroundColor,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}
