import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../model/dashboard_models.dart';

class DashboardFocusSection extends StatelessWidget {
  const DashboardFocusSection({required this.snapshot, super.key});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    final ColorScheme colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: DashboardScreenTokens.focusCardHeight,
      padding: const EdgeInsets.all(DashboardScreenTokens.focusCardPadding),
      decoration: _buildDecoration(colorScheme),
      child: Row(
        children: <Widget>[
          _buildIcon(colorScheme),
          const SizedBox(width: DashboardScreenTokens.focusIconGap),
          Expanded(
            child: _FocusText(
              l10n: l10n,
              snapshot: snapshot,
              colorScheme: colorScheme,
            ),
          ),
        ],
      ),
    );
  }

  BoxDecoration _buildDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: colorScheme.primaryContainer,
      borderRadius: BorderRadius.circular(
        DashboardScreenTokens.metricCardRadius,
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
