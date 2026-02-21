import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../model/dashboard_models.dart';

class DashboardFocusSection extends StatelessWidget {
  const DashboardFocusSection({required this.snapshot, super.key});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return LwCard(
      variant: AppCardVariant.filled,
      padding: const EdgeInsets.all(DashboardScreenTokens.focusCardPadding),
      backgroundColor: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(
        DashboardScreenTokens.metricCardRadius,
      ),
      child: SizedBox(
        height: DashboardScreenTokens.focusCardHeight,
        child: LwSpacedRow(
          spacing: DashboardScreenTokens.focusIconGap,
          children: <Widget>[
            _buildIcon(colorScheme),
            Expanded(
              child: _FocusText(
                l10n: l10n,
                snapshot: snapshot,
                colorScheme: colorScheme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Icon _buildIcon(ColorScheme colorScheme) {
    return Icon(
      Icons.track_changes_outlined,
      size: DashboardScreenTokens.focusIconSize,
      color: colorScheme.onPrimaryContainer,
    );
  }
}

class _FocusText extends StatelessWidget {
  const _FocusText({
    required this.l10n,
    required this.snapshot,
    required this.colorScheme,
  });

  final AppLocalizations l10n;
  final DashboardSnapshot snapshot;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: <Widget>[
        Text(
          l10n.dashboardTodayFocusTitle,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
        ),
        const SizedBox(height: DashboardScreenTokens.focusTextGap),
        Text(
          l10n.dashboardFocusCountLabel(snapshot.focusCardCount),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: colorScheme.onPrimaryContainer,
          ),
        ),
      ],
    );
  }
}
