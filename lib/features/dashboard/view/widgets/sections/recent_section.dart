import 'package:flutter/material.dart';
import 'package:learnwise/l10n/app_localizations.dart';

import '../../../../../common/styles/app_screen_tokens.dart';
import '../../../../../common/styles/app_opacities.dart';
import '../../../../../common/widgets/widgets.dart';
import '../../../model/dashboard_models.dart';

class DashboardRecentSection extends StatelessWidget {
  const DashboardRecentSection({required this.snapshot, super.key});

  final DashboardSnapshot snapshot;

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LwSectionTitle(title: l10n.dashboardRecentTitle),
        const SizedBox(height: DashboardScreenTokens.sectionTitleGap),
        ...snapshot.recentActivities.map((activity) {
          return _RecentActivityCard(
            label: _recentLabel(l10n, activity.type),
            progress: activity.progress,
          );
        }),
      ],
    );
  }
}

class _RecentActivityCard extends StatelessWidget {
  const _RecentActivityCard({required this.label, required this.progress});

  final String label;
  final double progress;

  @override
  Widget build(BuildContext context) {
    return LwCard(
      variant: AppCardVariant.outlined,
      margin: const EdgeInsets.only(
        bottom: DashboardScreenTokens.recentItemGap,
      ),
      padding: const EdgeInsets.all(DashboardScreenTokens.recentCardPadding),
      borderRadius: BorderRadius.circular(
        DashboardScreenTokens.recentCardRadius,
      ),
      border: Border.all(
        color: Theme.of(
          context,
        ).colorScheme.outline.withValues(alpha: AppOpacities.soft15),
      ),
      child: LwSpacedColumn(
        spacing: DashboardScreenTokens.recentProgressGap,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(label),
          LwLinearProgress(value: progress),
        ],
      ),
    );
  }
}

String _recentLabel(AppLocalizations l10n, DashboardRecentActivityType type) {
  switch (type) {
    case DashboardRecentActivityType.studyCompleted:
      return l10n.dashboardRecentStudyCompleted;
    case DashboardRecentActivityType.progressUpdated:
      return l10n.dashboardRecentProgressUpdated;
    case DashboardRecentActivityType.ttsPracticed:
      return l10n.dashboardRecentTtsPracticed;
  }
}
